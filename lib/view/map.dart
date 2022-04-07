// ignore_for_file: file_names, prefer_const_constructors


import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Map extends StatefulWidget {
  const Map({Key? key}) : super(key: key);
  static String routeName = "/map";

  @override
  State<Map> createState() => _BodyMapState();
}

class _BodyMapState extends State<Map> {
  GoogleMapController? mapController;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  static const _initialCameraPosition = CameraPosition(
    target: LatLng(-8.895732, -36.4940915),
    zoom: 15,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: const DefaultAppBar(),
      body: Column(
        // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Center(
            child: SizedBox(
              height: 82.h,
              // width: double.infinity,
              child: GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: _initialCameraPosition,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
