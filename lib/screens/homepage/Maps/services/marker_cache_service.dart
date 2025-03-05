import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../utils/Models/Feed.dart';
import 'package:latlong2/latlong.dart';

class MarkerCacheManager extends CacheManager {
  static const key = 'markerCache';
  static MarkerCacheManager? _instance;
  static const Duration _maxAge = Duration(hours: 1);

  factory MarkerCacheManager() {
    _instance ??= MarkerCacheManager._();
    return _instance!;
  }

  MarkerCacheManager._()
      : super(
          Config(
            key,
            stalePeriod: _maxAge,
            maxNrOfCacheObjects: 100,
            repo: JsonCacheInfoRepository(databaseName: key),
            fileService: HttpFileService(),
          ),
        );

  static const String markersJsonKey = 'markers_json_cache';
  static const String markerImagePrefix = 'marker_image_';

  /// Caches marker data in JSON format
  Future<void> cacheMarkerData(List<dynamic> markersJson) async {
    // Convert image_file to complete URLs before caching
    final markersWithUrls = markersJson.map((marker) {
      if (marker['image_file'] != null) {
        marker = Map<String, dynamic>.from(marker);
        marker['image_url'] = Supabase.instance.client.storage
            .from('assets')
            .getPublicUrl('marker_images/${marker['image_file']}');
      }
      return marker;
    }).toList();

    final jsonString = jsonEncode(markersWithUrls);
    await putFile(
      markersJsonKey,
      Uint8List.fromList(utf8.encode(jsonString)),
      key: markersJsonKey,
      maxAge: _maxAge,
    );
    debugPrint('Cached ${markersJson.length} markers with URLs');
  }

  /// Retrieves cached marker data
  Future<List<dynamic>?> getCachedMarkerData() async {
    try {
      final fileInfo = await getFileFromCache(markersJsonKey);
      if (fileInfo != null) {
        final jsonString = await fileInfo.file.readAsString();
        final markersJson = jsonDecode(jsonString) as List<dynamic>;
        debugPrint('Loaded ${markersJson.length} markers from cache');
        return markersJson;
      }
    } catch (e) {
      debugPrint('Error loading markers from cache: $e');
    }
    return null;
  }

  /// Caches a marker image and returns the cached file path
  Future<String?> cacheMarkerImage(String imageUrl) async {
    try {
      final fileInfo = await downloadFile(
        imageUrl,
        key: '$markerImagePrefix$imageUrl',
      );
      return fileInfo.file.path;
    } catch (e) {
      debugPrint('Error caching marker image: $e');
      return null;
    }
  }

  /// Gets a cached marker image
  Future<Image?> getCachedMarkerImage(String imageUrl) async {
    try {
      final fileInfo = await getFileFromCache('$markerImagePrefix$imageUrl');
      if (fileInfo != null) {
        return Image.file(fileInfo.file);
      }
    } catch (e) {
      debugPrint('Error loading cached marker image: $e');
    }
    return null;
  }

  /// Converts marker JSON to MapMarker objects
  Future<List<MapMarker>> convertJsonToMarkers(
      List<dynamic> markersJson) async {
    final List<MapMarker> markers = [];

    for (var markerData in markersJson) {
      Image? markerImage;
      final imageUrl = markerData['image_url'] as String?;

      if (imageUrl != null) {
        markerImage = await getCachedMarkerImage(imageUrl);
      }

      markers.add(MapMarker(
        id: markerData['id'],
        position: LatLng(
          (markerData['latitude'] as num).toDouble(),
          (markerData['longitude'] as num).toDouble(),
        ),
        content: Content(
          body: markerData['title'],
          description: markerData['description'],
          color: Color(markerData['color'] is String
              ? int.parse(markerData['color'])
              : markerData['color'] as int),
          txtcolor: Color(markerData['text_color'] is String
              ? int.parse(markerData['text_color'])
              : markerData['text_color'] as int),
          image: markerImage,
        ),
        createdAt: DateTime.parse(markerData['created_at']),
      ));
    }

    return markers;
  }
}
