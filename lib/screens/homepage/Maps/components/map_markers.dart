import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import '../../../../constants.dart';
import '../../../../utils/Models/Feed.dart';
import 'marker_dialogs.dart';

class MapMarkerLayer extends StatelessWidget {
  final List<MapMarker> markers;
  final Function(MapMarker) onMarkerUpdated;
  final Function(String) onMarkerDeleted;
  final Color selectedMarkerColor;
  final Color selectedTextColor;
  final Function(Color, Color) onColorsSelected;

  const MapMarkerLayer({
    super.key,
    required this.markers,
    required this.onMarkerUpdated,
    required this.onMarkerDeleted,
    required this.selectedMarkerColor,
    required this.selectedTextColor,
    required this.onColorsSelected,
  });

  @override
  Widget build(BuildContext context) {
    return MarkerLayer(
      markers: markers.map((marker) {
        return Marker(
          width: 150.0,
          height: 80.0,
          point: marker.position,
          child: GestureDetector(
            onTap: () => _showMarkerDetails(context, marker),
            onLongPress: () => _showMarkerOptions(context, marker),
            child: _buildMarkerWidget(marker),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMarkerWidget(MapMarker marker) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: marker.content.color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Constants.blackColor.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(6),
          child: Icon(
            Icons.location_on,
            color: marker.content.txtcolor,
            size: 24.0,
          ),
        ),
        Flexible(
          child: Container(
            constraints: const BoxConstraints(
              maxWidth: 140,
            ),
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: marker.content.color,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              marker.content.body,
              style: TextStyle(
                color: marker.content.txtcolor,
                fontWeight: FontWeight.w500,
                fontSize: 12,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              softWrap: true,
            ),
          ),
        ),
      ],
    );
  }

  void _showMarkerDetails(BuildContext context, MapMarker marker) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Constants.blackColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 4,
              width: 40,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Constants.creamColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            if (marker.content.image != null)
              Container(
                height: 200,
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: marker.content.image!,
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    marker.content.body,
                    style: TextStyle(
                      color: marker.content.txtcolor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (marker.content.description?.isNotEmpty ?? false)
                    Text(
                      marker.content.description!,
                      style: const TextStyle(
                        color: Constants.creamColor,
                        fontSize: 16,
                      ),
                    ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Constants.creamColor,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${marker.position.latitude.toStringAsFixed(6)}, ${marker.position.longitude.toStringAsFixed(6)}',
                        style: const TextStyle(
                          color: Constants.creamColor,
                          fontSize: 14,
                        ),
                      ),
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

  void _showMarkerOptions(BuildContext context, MapMarker marker) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Constants.blackColor,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.edit, color: Constants.creamColor),
                  title: const Text(
                    'Edit Marker',
                    style: TextStyle(color: Constants.whiteColor),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    MarkerDialogs.showEditMarkerDialog(
                      context: context,
                      marker: marker,
                      selectedMarkerColor: selectedMarkerColor,
                      selectedTextColor: selectedTextColor,
                      onMarkerUpdated: onMarkerUpdated,
                      onColorsSelected: onColorsSelected,
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete, color: Constants.redColor),
                  title: const Text(
                    'Delete Marker',
                    style: TextStyle(color: Constants.redColor),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    MarkerDialogs.showDeleteMarkerDialog(
                      context: context,
                      markerId: marker.id,
                      onMarkerDeleted: () => onMarkerDeleted(marker.id),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
