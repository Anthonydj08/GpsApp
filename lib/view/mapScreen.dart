// ignore_for_file: file_names, prefer_const_constructors

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gps_app/controller/localController.dart';
import 'package:gps_app/controller/rotaController.dart';
import 'package:gps_app/model/localModel.dart';
import 'package:gps_app/model/rotaModel.dart';
import 'package:location/location.dart';
import 'package:sizer/sizer.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart' as Geocoding;

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);
  static String routeName = "/map";

  @override
  State<MapScreen> createState() => _BodyMapState();
}

class _BodyMapState extends State<MapScreen> {
  GoogleMapController? mapController;
  RotaController rotaController = RotaController();
  LocalController localController = LocalController();

  late LocalModel local;
  late RotaModel rota;
  LatLng _origem = const LatLng(0.0, 0.0);
  LatLng _destino = const LatLng(0.0, 0.0);

  Map<MarkerId, Marker> markers = {};
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  String googleAPiKey = 'AIzaSyA_ztUeRrky_gYmsbnsKnfE6tOPGC_ABhg';

  late LatLng SOURCE_LOCATION = LatLng(-8.874906, -36.462927);
  late LatLng DEST_LOCATION = LatLng(-8.876484, -36.474340);
  late String localInicio = '';
  late String localDestino = '';
  late String distanciaTotal = '';

  late Geocoding.Placemark localAtual = Geocoding.Placemark();

  @override
  void initState() {
    super.initState();

    /// origin marker
    _addMarker(LatLng(SOURCE_LOCATION.latitude, SOURCE_LOCATION.longitude),
        "origin", BitmapDescriptor.defaultMarker);

    /// destination marker
    _addMarker(LatLng(DEST_LOCATION.latitude, DEST_LOCATION.longitude),
        "destination", BitmapDescriptor.defaultMarkerWithHue(90));
    _getPolyline();
  }

  _addMarker(LatLng position, String id, BitmapDescriptor descriptor) {
    MarkerId markerId = MarkerId(id);
    Marker marker =
        Marker(markerId: markerId, icon: descriptor, position: position);
    markers[markerId] = marker;
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _getUserLocation();
  }

  _getPolyline() async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        'AIzaSyA_ztUeRrky_gYmsbnsKnfE6tOPGC_ABhg',
        PointLatLng(SOURCE_LOCATION.latitude, SOURCE_LOCATION.longitude),
        PointLatLng(DEST_LOCATION.latitude, DEST_LOCATION.longitude),
        travelMode: TravelMode.driving);
    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
    }
    double distancia = 0.0;
    for (var i = 0; i < polylineCoordinates.length - 1; i++) {
      distancia += calculaDistancia(
          polylineCoordinates[i].latitude,
          polylineCoordinates[i].longitude,
          polylineCoordinates[i + 1].latitude,
          polylineCoordinates[i + 1].longitude);
    }
    distanciaTotal = distancia.toStringAsFixed(2);
    _addPolyLine();
  }

  double calculaDistancia(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  _addPolyLine() {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
        polylineId: id, color: Colors.red, points: polylineCoordinates);
    polylines[id] = polyline;
    setState(() {});
  }

  Future<void> _getFirstAndLastLocation() async {
    localController.listarLocais().then(
      (value) {
        //get first local
        local = value[0];
        final lastLocal = value[value.length - 1];
        setState(() {
          _origem = LatLng(
              double.parse(local.latitude), double.parse(local.longitude));
          _destino = LatLng(double.parse(lastLocal.latitude),
              double.parse(lastLocal.longitude));
        });
      },
    );
  }

  Future<void> _getUserLocation() async {
    setState(
      () {
        var inicio = Geocoding.placemarkFromCoordinates(
            SOURCE_LOCATION.latitude, SOURCE_LOCATION.longitude,
            localeIdentifier: "pt_BR");
        var fim = Geocoding.placemarkFromCoordinates(
            DEST_LOCATION.latitude, DEST_LOCATION.longitude,
            localeIdentifier: "pt_BR");

        inicio.then((value) {
          Geocoding.Placemark place = value[0];
          localInicio = place.street!;
        });
        fim.then((value) {
          Geocoding.Placemark place = value[0];
          localDestino = place.street!;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Ultima Rota",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Center(
            child: SizedBox(
              width: 90.w,
              height: 8.h,
              child: Card(
                color: Color.fromARGB(255, 233, 233, 233),
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: Color.fromARGB(255, 128, 128, 128),
                    width: 0.1.w,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.location_on,
                        color: Color.fromARGB(255, 128, 128, 128),
                      ),
                      Expanded(
                        child: Text(
                          '$localInicio',
                          style: TextStyle(
                            fontSize: 2.h,
                            color: Color.fromARGB(255, 128, 128, 128),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Center(
            child: SizedBox(
              width: 90.w,
              height: 8.h,
              child: Card(
                color: Color.fromARGB(255, 233, 233, 233),
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: Color.fromARGB(255, 128, 128, 128),
                    width: 0.1.w,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.location_on,
                        color: Color.fromARGB(255, 128, 128, 128),
                      ),
                      Expanded(
                        child: Text(
                          '$localDestino',
                          style: TextStyle(
                            fontSize: 2.h,
                            color: Color.fromARGB(255, 128, 128, 128),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Center(
            child: SizedBox(
              height: 62.h,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                    target: LatLng(
                        SOURCE_LOCATION.latitude, SOURCE_LOCATION.longitude),
                    zoom: 15),
                myLocationEnabled: true,
                tiltGesturesEnabled: true,
                compassEnabled: true,
                scrollGesturesEnabled: true,
                zoomGesturesEnabled: true,
                onMapCreated: _onMapCreated,
                markers: Set<Marker>.of(markers.values),
                polylines: Set<Polyline>.of(polylines.values),
              ),
            ),
          ),
          Center(
            child: Text(
              "Distância total: $distanciaTotal" + " km",
              style: TextStyle(fontSize: 20),
            ),
          )
        ],
      ),
    );
  }
}
