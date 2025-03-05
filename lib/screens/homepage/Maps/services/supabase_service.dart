import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../utils/Models/Feed.dart';
import 'marker_cache_service.dart';

class SupabaseService {
  static final supabase = Supabase.instance.client;
  static final _markerCache = MarkerCacheManager();
  static bool _isComparingCache = false;

  // Compare and update cache in background
  static Future<void> compareAndUpdateCache(
      Function(List<MapMarker>) onMarkersUpdated) async {
    if (_isComparingCache) return; // Prevent multiple simultaneous comparisons
    _isComparingCache = true;

    try {
      final cachedMarkersJson = await _markerCache.getCachedMarkerData();
      if (cachedMarkersJson == null) {
        _isComparingCache = false;
        return;
      }

      final supabaseResponse =
          await supabase.from('markers').select().order('created_at');

      // Compare if cache is outdated
      final isCacheOutdated =
          _isCacheOutdated(cachedMarkersJson, supabaseResponse);

      if (isCacheOutdated) {
        debugPrint('Cache is outdated, updating...');
        await _markerCache.cacheMarkerData(supabaseResponse);
        final updatedMarkers =
            await _markerCache.convertJsonToMarkers(supabaseResponse);
        onMarkersUpdated(updatedMarkers);
      } else {
        debugPrint('Cache is up to date');
      }
    } catch (e) {
      debugPrint('Error comparing cache: $e');
    } finally {
      _isComparingCache = false;
    }
  }

  // Helper to check if cache is outdated
  static bool _isCacheOutdated(
      List<dynamic> cachedData, List<dynamic> freshData) {
    if (cachedData.length != freshData.length) return true;

    for (var i = 0; i < cachedData.length; i++) {
      final cached = cachedData[i];
      final fresh = freshData[i];

      // Compare relevant fields
      if (cached['id'] != fresh['id'] ||
          cached['title'] != fresh['title'] ||
          cached['description'] != fresh['description'] ||
          cached['image_file'] != fresh['image_file'] ||
          cached['color'] != fresh['color'] ||
          cached['text_color'] != fresh['text_color'] ||
          cached['latitude'] != fresh['latitude'] ||
          cached['longitude'] != fresh['longitude']) {
        return true;
      }
    }
    return false;
  }

  // Upload image to Supabase storage
  static Future<String> uploadMarkerImage(String imagePath) async {
    try {
      final file = File(imagePath);
      final fileExt = imagePath.split('.').last;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      await supabase.storage
          .from('assets')
          .upload('marker_images/$fileName', file);
      return fileName;
    } catch (e) {
      debugPrint('Error uploading image: $e');
      rethrow;
    }
  }

  // Get image from Supabase storage with caching
  static Future<Image?> getMarkerImage(String fileName) async {
    try {
      final imageUrl = supabase.storage
          .from('assets')
          .getPublicUrl('marker_images/$fileName');

      // Try to get image from cache first
      final cachedImage = await _markerCache.getCachedMarkerImage(imageUrl);
      if (cachedImage != null) {
        return cachedImage;
      }

      // If not in cache, download and cache it
      final imagePath = await _markerCache.cacheMarkerImage(imageUrl);
      if (imagePath != null) {
        return Image.file(File(imagePath));
      }

      return Image.network(imageUrl);
    } catch (e) {
      debugPrint('Error getting image: $e');
      return null;
    }
  }

  // Save marker to Supabase database and update cache
  static Future<void> saveMarker(
      MapMarker marker, String? imageFileName) async {
    try {
      final response = await supabase.from('markers').insert({
        'latitude': marker.position.latitude,
        'longitude': marker.position.longitude,
        'title': marker.content.body,
        'description': marker.content.description,
        'image_file': imageFileName,
        'created_at': marker.createdAt.toIso8601String(),
        'color': marker.content.color.value,
        'text_color': marker.content.txtcolor.value,
      }).select();

      // Update the marker's ID with the UUID generated by Supabase
      if (response.isNotEmpty) {
        marker.id = response[0]['id'];
      }

      // Update cache after successful save
      final markersJson = await supabase.from('markers').select();
      await _markerCache.cacheMarkerData(markersJson);
    } catch (e) {
      debugPrint('Error saving marker: $e');
      rethrow;
    }
  }

  // Get all markers from cache or Supabase
  static Future<List<MapMarker>> getMarkers() async {
    try {
      // Try to get markers from cache first
      final cachedMarkersJson = await _markerCache.getCachedMarkerData();
      if (cachedMarkersJson != null) {
        debugPrint('Using cached markers');
        return await _markerCache.convertJsonToMarkers(cachedMarkersJson);
      }

      // If not in cache, fetch from Supabase
      debugPrint('Fetching markers from Supabase');
      final response =
          await supabase.from('markers').select().order('created_at');

      // Cache the response
      await _markerCache.cacheMarkerData(response);

      return await _markerCache.convertJsonToMarkers(response);
    } catch (e) {
      debugPrint('Error getting markers: $e');
      return [];
    }
  }

  // Delete marker and update cache
  static Future<void> deleteMarker(String markerId) async {
    try {
      final marker = await supabase
          .from('markers')
          .select('image_file')
          .eq('id', markerId)
          .single();

      // Delete image if exists
      final imageFile = marker['image_file'] as String?;
      if (imageFile != null) {
        await supabase.storage
            .from('assets')
            .remove(['marker_images/$imageFile']);
      }

      // Delete marker record
      await supabase.from('markers').delete().eq('id', markerId);

      // Update cache after successful delete
      final markersJson = await supabase.from('markers').select();
      await _markerCache.cacheMarkerData(markersJson);
    } catch (e) {
      debugPrint('Error deleting marker: $e');
      rethrow;
    }
  }

  // Update marker and cache
  static Future<void> updateMarker(
      MapMarker marker, String? imageFileName) async {
    try {
      final updateData = {
        'latitude': marker.position.latitude,
        'longitude': marker.position.longitude,
        'title': marker.content.body,
        'description': marker.content.description,
        'color': marker.content.color.value,
        'text_color': marker.content.txtcolor.value,
      };

      if (imageFileName != null) {
        updateData['image_file'] = imageFileName;
      }

      final response = await supabase
          .from('markers')
          .update(updateData)
          .eq('id', marker.id)
          .select();

      debugPrint('Update response: $response');

      // Update cache after successful update
      final markersJson = await supabase.from('markers').select();
      await _markerCache.cacheMarkerData(markersJson);
    } catch (e) {
      debugPrint('Error updating marker: $e');
      rethrow;
    }
  }
}
