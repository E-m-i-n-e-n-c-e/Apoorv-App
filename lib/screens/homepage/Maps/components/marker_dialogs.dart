import 'package:apoorv_app/screens/homepage/Maps/services/supabase_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import '../../../../constants.dart';
import '../../../../utils/Models/Feed.dart';
import 'color_picker_dialog.dart';

class MarkerDialogs {
  static Future<void> showAddMarkerDialog({
    required BuildContext context,
    required LatLng position,
    required Color selectedMarkerColor,
    required Color selectedTextColor,
    required Function(MapMarker) onMarkerAdded,
    required Function(Color, Color) onColorsSelected,
  }) async {
    String title = '';
    String description = '';
    String? imageFileName;
    Image? markerImage;

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Constants.blackColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTextField(
                      label: 'Title',
                      hint: 'Enter location name',
                      onChanged: (value) => title = value,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      label: 'Description',
                      hint: 'Enter location description',
                      onChanged: (value) => description = value,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    if (markerImage != null) _buildImagePreview(markerImage!),
                    _buildActionButtons(
                      context: context,
                      onImagePicked: () async {
                        final result = await _pickImage();
                        if (result != null) {
                          imageFileName = result.$1;
                          setState(() {
                            markerImage = result.$2;
                          });
                        }
                      },
                      onColorsPicked: () async {
                        await showDialog(
                          context: context,
                          builder: (context) => ColorPickerDialog(
                            initialMarkerColor: selectedMarkerColor,
                            initialTextColor: selectedTextColor,
                            onColorsSelected: onColorsSelected,
                          ),
                        );
                      },
                      onSave: () async {
                        if (title.isNotEmpty) {
                          final marker = MapMarker(
                            id: '', // Let Supabase generate the UUID
                            position: position,
                            content: Content(
                              body: title,
                              color: selectedMarkerColor,
                              txtcolor: selectedTextColor,
                              image: markerImage,
                              description: description,
                            ),
                            createdAt: DateTime.now(),
                          );

                          try {
                            await SupabaseService.saveMarker(
                                marker, imageFileName);
                            onMarkerAdded(marker);
                            if (context.mounted) {
                              Navigator.of(context).pop();
                            }
                          } catch (e) {
                            if (context.mounted) {
                              _showErrorSnackBar(
                                  context, 'Failed to save marker: $e');
                            }
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  static Future<void> showEditMarkerDialog({
    required BuildContext context,
    required MapMarker marker,
    required Color selectedMarkerColor,
    required Color selectedTextColor,
    required Function(MapMarker) onMarkerUpdated,
    required Function(Color, Color) onColorsSelected,
  }) async {
    String title = marker.content.body;
    String description = marker.content.description ?? '';
    String? imageFileName;
    Image? markerImage = marker.content.image;
    Color markerColor = marker.content.color;
    Color textColor = marker.content.txtcolor;

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Constants.blackColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTextField(
                      label: 'Title',
                      initialValue: title,
                      onChanged: (value) => title = value,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      label: 'Description',
                      initialValue: description,
                      onChanged: (value) => description = value,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    if (markerImage != null) _buildImagePreview(markerImage!),
                    _buildActionButtons(
                      context: context,
                      onImagePicked: () async {
                        final result = await _pickImage();
                        if (result != null) {
                          imageFileName = result.$1;
                          setState(() {
                            markerImage = result.$2;
                          });
                        }
                      },
                      onColorsPicked: () async {
                        await showDialog(
                          context: context,
                          builder: (context) => ColorPickerDialog(
                            initialMarkerColor: markerColor,
                            initialTextColor: textColor,
                            onColorsSelected: (newMarkerColor, newTextColor) {
                              markerColor = newMarkerColor;
                              textColor = newTextColor;
                              onColorsSelected(newMarkerColor, newTextColor);
                            },
                          ),
                        );
                      },
                      onSave: () async {
                        if (title.isNotEmpty) {
                          final updatedMarker = MapMarker(
                            id: marker.id,
                            position: marker.position,
                            content: Content(
                              body: title,
                              color: markerColor,
                              txtcolor: textColor,
                              image: markerImage,
                              description: description,
                            ),
                            createdAt: marker.createdAt,
                          );

                          try {
                            await SupabaseService.updateMarker(
                                updatedMarker, imageFileName);
                            onMarkerUpdated(updatedMarker);
                            if (context.mounted) {
                              Navigator.of(context).pop();
                            }
                          } catch (e) {
                            if (context.mounted) {
                              _showErrorSnackBar(
                                  context, 'Failed to update marker: $e');
                            }
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  static Future<void> showDeleteMarkerDialog({
    required BuildContext context,
    required String markerId,
    required Function() onMarkerDeleted,
  }) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Constants.blackColor,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Delete Marker',
                  style: TextStyle(
                    color: Constants.whiteColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Are you sure you want to delete this marker?',
                  style: TextStyle(color: Constants.creamColor),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Constants.creamColor),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Constants.redColor,
                        foregroundColor: Constants.whiteColor,
                      ),
                      onPressed: () async {
                        try {
                          await SupabaseService.deleteMarker(markerId);
                          onMarkerDeleted();
                          if (context.mounted) {
                            Navigator.of(context).pop();
                          }
                        } catch (e) {
                          if (context.mounted) {
                            _showErrorSnackBar(
                                context, 'Failed to delete marker: $e');
                          }
                        }
                      },
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget _buildTextField({
    required String label,
    String? hint,
    String? initialValue,
    required Function(String) onChanged,
    int? maxLines,
  }) {
    return TextField(
      controller: initialValue != null
          ? TextEditingController(text: initialValue)
          : null,
      style: const TextStyle(color: Constants.whiteColor),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: Constants.creamColor),
        hintStyle: const TextStyle(color: Constants.creamColor),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Constants.redColor),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Constants.whiteColor),
        ),
      ),
      maxLines: maxLines,
      onChanged: onChanged,
    );
  }

  static Widget _buildImagePreview(Image image) {
    return Container(
      height: 120,
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: image,
      ),
    );
  }

  static Widget _buildActionButtons({
    required BuildContext context,
    required Function() onImagePicked,
    required Function() onColorsPicked,
    required Function() onSave,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(
              onPressed: onImagePicked,
              icon: const Icon(Icons.image, color: Constants.creamColor),
              label: const Text(
                'Add Image',
                style: TextStyle(color: Constants.creamColor),
              ),
            ),
            TextButton.icon(
              onPressed: onColorsPicked,
              icon: const Icon(Icons.color_lens, color: Constants.creamColor),
              label: const Text(
                'Colors',
                style: TextStyle(color: Constants.creamColor),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Constants.creamColor),
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Constants.redColor,
                foregroundColor: Constants.whiteColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: onSave,
              child: const Text('Save'),
            ),
          ],
        ),
      ],
    );
  }

  static Future<(String, Image)?> _pickImage() async {
    final ImagePicker imagePicker = ImagePicker();
    final XFile? image = await imagePicker.pickImage(
      source: ImageSource.gallery,
    );
    if (image != null) {
      try {
        final imageFileName =
            await SupabaseService.uploadMarkerImage(image.path);
        final newImage = await SupabaseService.getMarkerImage(imageFileName);
        if (newImage != null) {
          return (imageFileName, newImage);
        }
      } catch (e) {
        debugPrint('Failed to upload image: $e');
      }
    }
    return null;
  }

  static void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
