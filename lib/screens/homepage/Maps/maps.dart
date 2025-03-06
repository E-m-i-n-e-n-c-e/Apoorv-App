import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';
import '../../../../../constants.dart';
import '../../../../../utils/Models/Feed.dart';
import 'services/supabase_service.dart';
import 'components/map_markers.dart';
import 'components/academic_block_markers.dart';
import 'components/marker_dialogs.dart';
import 'services/map_cache_service.dart';
import 'screens/event_details.dart';
import 'screens/all_events.dart';

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
  static const routeName = '/maps';
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
  int selectedDay = 1;
  MapMarker? selectedMarker;
  List<Event> filteredEvents = [];

  @override
  void initState() {
    super.initState();
    _initializeMarkers();
  }

  void _initializeMarkers() async {
    await _loadMarkers();
    // Start background cache comparison
    unawaited(SupabaseService.compareAndUpdateCache(_updateMarkers));
  }

  Future<void> _loadMarkers() async {
    final loadedMarkers = await SupabaseService.getMarkersWithEvents();

    setState(() {
      // Combine with mock data
      markers = loadedMarkers;
    });
  }

  void _updateMarkers() async {
    await _loadMarkers();

    // If a marker was selected, update the filtered events
    if (selectedMarker != null) {
      _updateFilteredEvents();
    }
  }

  void _handleMarkerUpdate(MapMarker updatedMarker) {
    setState(() {
      final index = markers.indexWhere((m) => m.id == updatedMarker.id);
      if (index != -1) {
        markers[index] = updatedMarker;

        // If this was the selected marker, update it and the filtered events
        if (selectedMarker != null && selectedMarker!.id == updatedMarker.id) {
          selectedMarker = updatedMarker;
          _updateFilteredEvents();
        }
      }
    });
  }

  void _handleMarkerDelete(String markerId) {
    setState(() {
      markers.removeWhere((m) => m.id == markerId);

      // If this was the selected marker, clear the selection
      if (selectedMarker != null && selectedMarker!.id == markerId) {
        selectedMarker = null;
        filteredEvents = [];
      }
    });
  }

  void _handleEventAdded(Event event) {
    // Find the marker this event belongs to
    final index = markers.indexWhere((m) => m.id == event.locationId);
    if (index != -1) {
      final marker = markers[index];
      final updatedEvents = [...marker.events, event];

      final updatedMarker = MapMarker(
        id: marker.id,
        locationName: marker.locationName,
        position: marker.position,
        markerColor: marker.markerColor,
        textColor: marker.textColor,
        events: updatedEvents,
        createdAt: marker.createdAt,
      );

      setState(() {
        markers[index] = updatedMarker;

        // If this was the selected marker, update it and the filtered events
        if (selectedMarker != null && selectedMarker!.id == marker.id) {
          selectedMarker = updatedMarker;
          _updateFilteredEvents();
        }
      });
    }
  }

  void _handleEventUpdated(Event updatedEvent) {
    // Find the marker this event belongs to
    final markerIndex =
        markers.indexWhere((m) => m.id == updatedEvent.locationId);
    if (markerIndex != -1) {
      final marker = markers[markerIndex];
      final eventIndex =
          marker.events.indexWhere((e) => e.id == updatedEvent.id);

      if (eventIndex != -1) {
        final updatedEvents = List<Event>.from(marker.events);
        updatedEvents[eventIndex] = updatedEvent;

        final updatedMarker = MapMarker(
          id: marker.id,
          locationName: marker.locationName,
          position: marker.position,
          markerColor: marker.markerColor,
          textColor: marker.textColor,
          events: updatedEvents,
          createdAt: marker.createdAt,
        );

        setState(() {
          markers[markerIndex] = updatedMarker;

          // If this was the selected marker, update it and the filtered events
          if (selectedMarker != null && selectedMarker!.id == marker.id) {
            selectedMarker = updatedMarker;
            _updateFilteredEvents();
          }
        });
      }
    }
  }

  void _handleEventDeleted(String eventId) {
    // Find the marker containing this event
    for (int i = 0; i < markers.length; i++) {
      final marker = markers[i];
      final eventIndex = marker.events.indexWhere((e) => e.id == eventId);

      if (eventIndex != -1) {
        final updatedEvents = List<Event>.from(marker.events)
          ..removeAt(eventIndex);

        final updatedMarker = MapMarker(
          id: marker.id,
          locationName: marker.locationName,
          position: marker.position,
          markerColor: marker.markerColor,
          textColor: marker.textColor,
          events: updatedEvents,
          createdAt: marker.createdAt,
        );

        setState(() {
          markers[i] = updatedMarker;

          // If this was the selected marker, update it and the filtered events
          if (selectedMarker != null && selectedMarker!.id == marker.id) {
            selectedMarker = updatedMarker;
            _updateFilteredEvents();
          }
        });

        break;
      }
    }
  }

  void _handleColorSelection(Color markerColor, Color textColor) {
    setState(() {
      selectedMarkerColor = markerColor;
      selectedTextColor = textColor;
    });
  }

  void _handleMarkerTapped(MapMarker marker) {
    setState(() {
      selectedMarker = marker;
      _updateFilteredEvents();
    });

    _showEventBottomSheet();
  }

  void _updateFilteredEvents() {
    if (selectedMarker != null) {
      final dayEvents = selectedMarker!.events
          .where((event) => event.day == selectedDay)
          .toList();

      // Sort events by time
      dayEvents.sort((a, b) => a.time.compareTo(b.time));

      setState(() {
        filteredEvents = dayEvents;
      });
    }
  }

  void _showEventBottomSheet() {
    if (selectedMarker == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(builder: (context, setModalState) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Constants.blackColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 10),
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Constants.creamColor.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  // Location name
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            selectedMarker!.locationName,
                            style: const TextStyle(
                              color: Constants.whiteColor,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline,
                              color: Constants.redColor),
                          onPressed: () {
                            Navigator.pop(context);
                            MarkerDialogs.showAddEventDialog(
                              context: context,
                              locationId: selectedMarker!.id,
                              locationName: selectedMarker!.locationName,
                              selectedColor: selectedMarkerColor,
                              selectedTextColor: selectedTextColor,
                              onEventAdded: _handleEventAdded,
                              onColorsSelected: _handleColorSelection,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  // Day selector
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildDaySelectorForBottomSheet(setModalState),
                  ),
                  const SizedBox(height: 16),
                  // Events list
                  Expanded(
                    child: filteredEvents.isEmpty
                        ? _buildNoEventsMessage()
                        : _buildEventsList(scrollController),
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }

  // New method specifically for the bottom sheet
  Widget _buildDaySelectorForBottomSheet(StateSetter setModalState) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [1, 2, 3].map((day) {
        final isSelected = day == selectedDay;
        return GestureDetector(
          onTap: () {
            // Update both the parent state and the modal state
            setState(() {
              selectedDay = day;
            });

            // Update the modal state to reflect the change
            setModalState(() {
              // This will rebuild just the bottom sheet with the new day
            });

            // Update filtered events
            _updateFilteredEvents();
          },
          child: Container(
            width: 80,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? Constants.redColor : Constants.blackColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? Constants.redColor : Constants.creamColor,
              ),
            ),
            child: Center(
              child: Text(
                'Day $day',
                style: TextStyle(
                  color:
                      isSelected ? Constants.whiteColor : Constants.creamColor,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNoEventsMessage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.event_busy,
            color: Constants.creamColor,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'No events on Day $selectedDay',
            style: const TextStyle(
              color: Constants.creamColor,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              MarkerDialogs.showAddEventDialog(
                context: context,
                locationId: selectedMarker!.id,
                locationName: selectedMarker!.locationName,
                selectedColor: selectedMarkerColor,
                selectedTextColor: selectedTextColor,
                onEventAdded: _handleEventAdded,
                onColorsSelected: _handleColorSelection,
              );
            },
            icon: const Icon(Icons.add, color: Constants.redColor),
            label: const Text(
              'Add Event',
              style: TextStyle(color: Constants.redColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsList(ScrollController scrollController) {
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: filteredEvents.length,
      itemBuilder: (context, index) {
        final event = filteredEvents[index];
        return _buildEventCard(event);
      },
    );
  }

  Widget _buildEventCard(Event event) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context); // Close the bottom sheet
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDetailsScreen(
              event: event,
              locationName: selectedMarker!.locationName,
              onEventUpdated: _handleEventUpdated,
              onEventDeleted: _handleEventDeleted,
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        color: event.color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (event.image != null)
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    color: Colors.black,
                    width: double.infinity,
                    height: 150,
                    child: Center(
                      child: event.image,
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          event.title,
                          style: TextStyle(
                            color: event.txtcolor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: Icon(Icons.more_vert, color: event.txtcolor),
                        onSelected: (value) {
                          if (value == 'edit') {
                            Navigator.pop(context); // Close bottom sheet
                            MarkerDialogs.showEditEventDialog(
                              context: context,
                              event: event,
                              locationName: selectedMarker!.locationName,
                              onEventUpdated: _handleEventUpdated,
                              onColorsSelected: _handleColorSelection,
                            );
                          } else if (value == 'delete') {
                            Navigator.pop(context); // Close bottom sheet
                            MarkerDialogs.showDeleteEventDialog(
                              context: context,
                              eventId: event.id,
                              onEventDeleted: () =>
                                  _handleEventDeleted(event.id),
                            );
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                const Icon(Icons.edit,
                                    color: Constants.creamColor),
                                const SizedBox(width: 8),
                                Text('Edit',
                                    style: TextStyle(color: event.txtcolor)),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                const Icon(Icons.delete,
                                    color: Constants.redColor),
                                const SizedBox(width: 8),
                                Text('Delete',
                                    style: TextStyle(color: event.txtcolor)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (event.description != null &&
                      event.description!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        event.description!,
                        style: TextStyle(
                          color: event.txtcolor.withOpacity(0.8),
                        ),
                      ),
                    ),
                  Row(
                    children: [
                      Icon(Icons.access_time, color: event.txtcolor, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        event.time,
                        style: TextStyle(
                          color: event.txtcolor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 16),
                      if (event.roomNumber.isNotEmpty) ...[
                        Icon(Icons.room, color: event.txtcolor, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          event.roomNumber,
                          style: TextStyle(
                            color: event.txtcolor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
    // Filter out academic block markers (BB, BC, BD) for regular marker layer
    final regularMarkers = markers.where((marker) {
      final name = marker.locationName;
      return !(name.startsWith('BB') ||
          name.startsWith('BC') ||
          name.startsWith('BD'));
    }).toList();

    // Get academic block markers for the academic block layer
    final academicMarkers = markers.where((marker) {
      final name = marker.locationName;
      return name.startsWith('BB') ||
          name.startsWith('BC') ||
          name.startsWith('BD');
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('APOORV 2025 Map'),
        backgroundColor: Constants.blackColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.event, color: Constants.redColor),
            tooltip: 'View All Events',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AllEventsScreen(
                    markers: markers,
                    onEventUpdated: _handleEventUpdated,
                    onEventDeleted: _handleEventDeleted,
                  ),
                ),
              );
            },
          ),
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

                await MarkerDialogs.showAddLocationDialog(
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
              // Regular markers (non-academic blocks)
              MapMarkerLayer(
                markers: regularMarkers,
                onMarkerTapped: _handleMarkerTapped,
                onMarkerUpdated: _handleMarkerUpdate,
                onMarkerDeleted: _handleMarkerDelete,
                onEventAdded: _handleEventAdded,
                onEventUpdated: _handleEventUpdated,
                onEventDeleted: _handleEventDeleted,
              ),
              // Academic block markers (BB, BC, BD)
              AcademicBlockMarkers(
                markers: academicMarkers,
                onMarkerTapped: _handleMarkerTapped,
              ),
            ],
          ),
          _buildZoomControls(),
          // Add a legend for the academic blocks
          Positioned(
            left: 16,
            bottom: 60,
            child: _buildAcademicBlockLegend(),
          ),
        ],
      ),
    );
  }

  Widget _buildAcademicBlockLegend() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Constants.blackColor.withOpacity(0.8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Constants.creamColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Academic Block',
            style: TextStyle(
              color: Constants.whiteColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Constants.redColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                'Grouped Rooms',
                style: TextStyle(
                  color: Constants.creamColor,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
