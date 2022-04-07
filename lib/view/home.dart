import 'package:flutter/material.dart';
import 'package:gps_app/constants.dart';
import 'package:gps_app/model/localModel.dart';
import 'package:geocoding/geocoding.dart' as Geocoding;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import 'package:sizer/sizer.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);
  static String routeName = "/home";

  @override
  State<Home> createState() => _BodyState();
}

class _BodyState extends State<Home> {
  late LocationData _userLocation;
  late Location _location;
  late LocalModel local;
  String street = "";
  LatLng _local = const LatLng(0.0, 0.0);
  late GoogleMapController _googleMapController;
  String tempo = "00:00:00";
  late final stopwatch = Stopwatch();

  _BodyState();

  @override
  void dispose() async {
    super.dispose();
    _googleMapController.dispose();
  }

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _verificaPermissoes() async {
    _location = Location();

    bool _serviceEnabled = await _location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    PermissionStatus _permissionGranted = await _location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
  }

  Future<void> _getUserLocation() async {
    _verificaPermissoes();
    Location location = Location();
    _userLocation = await location.getLocation();
    String street = "";
    _local = LatLng(_userLocation.latitude!, _userLocation.longitude!);
    Future<List<Geocoding.Placemark>> places;

    setState(
      () {
        places = Geocoding.placemarkFromCoordinates(
            _userLocation.latitude!, _userLocation.longitude!,
            localeIdentifier: "pt_BR");
        places.then(
          (value) {
            Geocoding.Placemark place = value[0];
            _local = LatLng(_userLocation.latitude!, _userLocation.longitude!);
            street = place.street!;
          },
        );
      },
    );
  }

  _watchStart() {
    stopwatch.start();
  }

  _watchStop() {
    stopwatch.stop();
    tempo = stopwatch.elapsed.toString();
    stopwatch.reset();
  }

  void _createdMap(GoogleMapController controller) {
    _googleMapController = controller;
    _location.onLocationChanged.listen((event) {
      _local = LatLng(event.latitude!, event.longitude!);
      _googleMapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: _local,
            zoom: 15.0,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      //build map view

      body: SingleChildScrollView(
        child: SizedBox(
          height: 100.h,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: 2.h,
                  horizontal: 1.h,
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 61.h,
                  child: Card(
                    color: kPrimaryLightColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(2.h),
                      side: BorderSide(
                        color: kPrimaryLightColor,
                        width: 0.5.w,
                      ),
                    ),
                    child: InkWell(
                      child: Column(
                        children: [
                          SizedBox(
                            height: 55.h,
                            child: GoogleMap(
                              initialCameraPosition: CameraPosition(
                                target: _local,
                              ),
                              mapType: MapType.normal,
                              myLocationEnabled: true,
                              myLocationButtonEnabled: false,
                              zoomControlsEnabled: false,
                              onMapCreated: (controller) =>
                                  _createdMap(controller),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                            child: Text(street,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      splashColor: kPrimaryColor.withAlpha(30),
                      onTap: () {},
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        /* child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Home test',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ), */
      ),
    );
  }
}
