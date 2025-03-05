import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class Content {
  const Content({
    required this.txtcolor,
    required this.body,
    required this.color, // marker color
    this.image,
    this.description,
  });
  final String body;
  final Color color;
  final Color txtcolor;
  final Image? image;
  final String? description;
}

class MapMarker {
  String id;
  final LatLng position;
  final Content content;
  final DateTime createdAt;

  MapMarker({
    required this.id,
    required this.position,
    required this.content,
    required this.createdAt,
  });
}
