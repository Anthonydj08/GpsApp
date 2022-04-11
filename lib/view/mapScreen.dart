import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gps_app/model/localModel.dart';
import 'package:sizer/sizer.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart' as Geocoding;

class MapScreen extends StatefulWidget {
  final List<LocalModel> locais;

  const MapScreen({Key? key, required this.locais}) : super(key: key);
  static String routeName = "/map";

  @override
  State<MapScreen> createState() => _BodyMapState();
}

class _BodyMapState extends State<MapScreen> {
  GoogleMapController? mapController;

  Map<MarkerId, Marker> markers = {};
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  String googleAPiKey = 'AIzaSyA_ztUeRrky_gYmsbnsKnfE6tOPGC_ABhg';

  late String localInicio = '';
  late String localDestino = '';
  late String distanciaTotal = '';

  late List<LocalModel> locais = [];

  List<PolylineWayPoint> wayPoints = [];
  late PointLatLng inicio;
  late PointLatLng destino;

  //obj json inicio
  var jsonInicio = {
    "latInicio": '',
    "lngInicio": '',
    "latDestino": '',
    "lngDestino": '',
  };

  @override
  void initState() {
    super.initState();
    locais = widget.locais;

    //primeiro local
    var primeiroLocal = locais[0];
    var ultimoLocal = locais[locais.length - 1];
    jsonInicio = {
      "latInicio": primeiroLocal.latitude.toString(),
      "lngInicio": primeiroLocal.longitude.toString(),
      "latDestino": ultimoLocal.latitude.toString(),
      "lngDestino": ultimoLocal.longitude.toString(),
    };
    _setWayPoints();

    /// origin marker
    _addMarker(
        LatLng(double.parse(primeiroLocal.latitude),
            double.parse(primeiroLocal.longitude)),
        "origin",
        BitmapDescriptor.defaultMarkerWithHue(90));

    /// destination marker
    _addMarker(
        LatLng(double.parse(ultimoLocal.latitude),
            double.parse(ultimoLocal.longitude)),
        "destination",
        BitmapDescriptor.defaultMarker);

    _getPolyline();
  }

  _setWayPoints() {
    inicio = PointLatLng(double.parse(jsonInicio['latInicio']!),
        double.parse(jsonInicio['lngInicio']!));
    destino = PointLatLng(double.parse(jsonInicio['latDestino']!),
        double.parse(jsonInicio['lngDestino']!));
    for (var i = 0; i < locais.length; i++) {
      if (i > 0 && i < locais.length - 1) {
        wayPoints.add(PolylineWayPoint(
            location: locais[i].latitude + ',' + locais[i].longitude));
      }
    }
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
        googleAPiKey, inicio, destino,
        wayPoints: wayPoints, travelMode: TravelMode.walking);
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
    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(
        polylineId: id, color: Colors.red, points: polylineCoordinates);
    polylines[id] = polyline;
    setState(() {});
  }

  Future<void> _getUserLocation() async {
    setState(
      () {
        var inicio = Geocoding.placemarkFromCoordinates(
            double.parse(jsonInicio['latInicio']!),
            double.parse(jsonInicio['lngInicio']!),
            localeIdentifier: "pt_BR");
        var fim = Geocoding.placemarkFromCoordinates(
            double.parse(jsonInicio['latDestino']!),
            double.parse(jsonInicio['lngDestino']!),
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
        title: Text(
          "Rota ${widget.locais[0].idRota}",
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
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
                color: const Color.fromARGB(255, 233, 233, 233),
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: const Color.fromARGB(255, 128, 128, 128),
                    width: 0.1.w,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  child: Row(
                    children: <Widget>[
                      const Icon(
                        Icons.location_on,
                        color: Color.fromARGB(255, 128, 128, 128),
                      ),
                      Expanded(
                        child: Text(
                          localInicio,
                          style: TextStyle(
                            fontSize: 2.h,
                            color: const Color.fromARGB(255, 128, 128, 128),
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
                color: const Color.fromARGB(255, 233, 233, 233),
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: const Color.fromARGB(255, 128, 128, 128),
                    width: 0.1.w,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  child: Row(
                    children: <Widget>[
                      const Icon(
                        Icons.location_on,
                        color: Color.fromARGB(255, 128, 128, 128),
                      ),
                      Expanded(
                        child: Text(
                          localDestino,
                          style: TextStyle(
                            fontSize: 2.h,
                            color: const Color.fromARGB(255, 128, 128, 128),
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
                      double.parse(jsonInicio['latInicio']!),
                      double.parse(jsonInicio['lngInicio']!),
                    ),
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
              "Distância total: $distanciaTotal km",
              style: const TextStyle(fontSize: 20),
            ),
          )
        ],
      ),
    );
  }
}
