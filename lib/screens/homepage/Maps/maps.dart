import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';
import '../../../constants.dart';
import '../../../utils/Models/Feed.dart';
import '../../../utils/dummy_data/mock_data.dart';
import 'services/supabase_service.dart';
import 'components/map_markers.dart';
import 'components/marker_dialogs.dart';
import 'services/map_cache_service.dart';

// Map boundaries and zoom constraints
const minZoom = 17.0;
const maxZoom = 21.0;
const initialZoom = 17.5;

const minLat = 9.750682; // Southwest corner latitude
const maxLat = 9.758735; // Northeast corner latitude
const minLong = 76.646042; // Southwest corner longitude
const maxLong = 76.653665; // Northeast corner longitude

final mapBounds = LatLngBounds(
  const LatLng(minLat, minLong), // Southwest corner
  const LatLng(maxLat, maxLong), // Northeast corner
);

// Define zoom levels to cache
final zoomLevelsToCache = {
  initialZoom.floor() - 1,
  initialZoom.floor(),
  initialZoom.ceil(),
  initialZoom.ceil() + 1,
};

class MapsScreen extends StatefulWidget {
  const MapsScreen({super.key});

  @override
  State<MapsScreen> createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> {
  final MapController mapController = MapController();
  bool _isSatelliteMode = true;
  List<MapMarker> markers = [];
  Color selectedMarkerColor = Constants.redColor;
  Color selectedTextColor = Constants.whiteColor;

  @override
  void initState() {
    super.initState();
    _loadMarkers();
    // Start background cache comparison
    unawaited(SupabaseService.compareAndUpdateCache(_updateMarkers));
  }

  Future<void> _loadMarkers() async {
    final loadedMarkers = await SupabaseService.getMarkers();
    setState(() {
      markers = loadedMarkers + mapMarkers; // Combining with mock data
    });
  }

  void _updateMarkers(List<MapMarker> updatedMarkers) {
    if (mounted) {
      setState(() {
        markers = updatedMarkers + mapMarkers; // Combining with mock data
      });
    }
  }

  void _handleMarkerUpdate(MapMarker updatedMarker) {
    setState(() {
      final index = markers.indexWhere((m) => m.id == updatedMarker.id);
      if (index != -1) {
        markers[index] = updatedMarker;
      }
    });
  }

  void _handleMarkerDelete(String markerId) {
    setState(() {
      markers.removeWhere((m) => m.id == markerId);
    });
  }

  void _handleColorSelection(Color markerColor, Color textColor) {
    setState(() {
      selectedMarkerColor = markerColor;
      selectedTextColor = textColor;
    });
  }

  Widget _buildZoomControls() {
    return Positioned(
      right: 16,
      bottom: 60,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'zoomIn',
            mini: true,
            backgroundColor: Constants.blackColor,
            onPressed: () {
              final currentZoom = mapController.camera.zoom;
              if (currentZoom < maxZoom) {
                mapController.move(
                  mapController.camera.center,
                  currentZoom + 1,
                );
              }
            },
            child: const Icon(Icons.add, color: Constants.redColor),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'zoomOut',
            mini: true,
            backgroundColor: Constants.blackColor,
            onPressed: () {
              final currentZoom = mapController.camera.zoom;
              if (currentZoom > minZoom) {
                mapController.move(
                  mapController.camera.center,
                  currentZoom - 1,
                );
              }
            },
            child: const Icon(Icons.remove, color: Constants.redColor),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('APOORV 2024 Map'),
        backgroundColor: Constants.blackColor,
        actions: [
          IconButton(
            icon: Icon(_isSatelliteMode ? Icons.map : Icons.satellite),
            color: Constants.redColor,
            onPressed: () {
              setState(() {
                _isSatelliteMode = !_isSatelliteMode;
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: const LatLng(9.754969, 76.650201),
              initialZoom: initialZoom,
              onTap: (tapPosition, point) async {
                if (!mapBounds.contains(point)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Please select a location within the campus boundaries.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                await MarkerDialogs.showAddMarkerDialog(
                  context: context,
                  position: point,
                  selectedMarkerColor: selectedMarkerColor,
                  selectedTextColor: selectedTextColor,
                  onMarkerAdded: (marker) {
                    setState(() {
                      markers.add(marker);
                    });
                  },
                  onColorsSelected: _handleColorSelection,
                );
              },
              minZoom: minZoom,
              maxZoom: maxZoom,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
              keepAlive: true,
              backgroundColor: Constants.blackColor,
              cameraConstraint: CameraConstraint.contain(bounds: mapBounds),
            ),
            children: [
              TileLayer(
                urlTemplate: _isSatelliteMode
                    ? 'https://mt1.google.com/vt/lyrs=s&x={x}&y={y}&z={z}'
                    : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
                tileProvider:
                    CachedTileProvider(zoomLevelsToCache: zoomLevelsToCache),
                minZoom: minZoom,
                maxZoom: maxZoom,
                keepBuffer: 8,
              ),
              MapMarkerLayer(
                markers: markers,
                onMarkerUpdated: _handleMarkerUpdate,
                onMarkerDeleted: _handleMarkerDelete,
                selectedMarkerColor: selectedMarkerColor,
                selectedTextColor: selectedTextColor,
                onColorsSelected: _handleColorSelection,
              ),
            ],
          ),
          _buildZoomControls(),
        ],
      ),
    );
  }
}
