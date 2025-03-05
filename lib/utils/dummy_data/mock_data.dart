import 'package:apoorv_app/utils/Models/Feed.dart';
import 'package:latlong2/latlong.dart';
import '../../../constants.dart';
import 'package:flutter/material.dart';

final dummy = [
  Content(
    body: "Nami is Going to Start Soon, Please Gather at AB 201",
    color: Constants.creamColor,
    txtcolor: const Color.fromARGB(255, 0, 0, 0),
    image: Image.asset("./assets/images/string_and_keys.png"),
  ),
  const Content(
    body: "Treasure Hunt is Going to Start Soon, Please Gather at AB 201",
    color: Constants.creamColor,
    txtcolor: Constants.blackColor,
  ),
  const Content(
    body: "Rehne do is Going to Start Soon, Please Gather at BA 201",
    color: Constants.redColorAlt,
    txtcolor: Constants.whiteColor,
  ),
  const Content(
    body: "One Piece is Going to Start Soon, Please Gather at AB 201",
    color: Color.fromARGB(207, 92, 88, 88),
    txtcolor: Constants.whiteColor,
  ),
];

final mapMarkers = [
  MapMarker(
    id: "1",
    position: const LatLng(9.754969, 76.650201), // College center point
    content: Content(
      body: "Main Stage - APOORV 2024",
      color: Constants.redColor,
      txtcolor: Constants.whiteColor,
      image: Image.asset("./assets/images/string_and_keys.png"),
    ),
    createdAt: DateTime.now(),
  ),
  MapMarker(
    id: "2",
    position: const LatLng(9.755500, 76.649800),
    content: Content(
      body: "Food Court",
      color: Constants.creamColor,
      txtcolor: const Color.fromARGB(255, 106, 42, 42),
      image: Image.asset("./assets/images/wolf.png"),
    ),
    createdAt: DateTime.now(),
  ),
  MapMarker(
    id: "3",
    position: const LatLng(9.754500, 76.650500),
    content: const Content(
      body: "Gaming Arena",
      color: Constants.redColorAlt,
      txtcolor: Constants.whiteColor,
    ),
    createdAt: DateTime.now(),
  ),
];
