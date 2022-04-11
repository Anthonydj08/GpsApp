import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gps_app/constants.dart';
import 'package:gps_app/controller/localController.dart';
import 'package:gps_app/controller/rotaController.dart';
import 'package:gps_app/model/localModel.dart';
import 'package:geocoding/geocoding.dart' as Geocoding;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gps_app/model/rotaModel.dart';
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
  late RotaModel rota;
  String street = "";
  LatLng _local = const LatLng(0.0, 0.0);
  late GoogleMapController _googleMapController;
  late bool click = false;
  String tempo = "00:00:00";
  late final stopwatch = Stopwatch();
  RotaController rotaController = RotaController();
  LocalController localController = LocalController();
  String status = 'Parado';
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

  void startServiceInAndroid() async {
    if (Platform.isAndroid) {
      var method = const MethodChannel("com.example.gps_app.messages");
      String data = await method.invokeMethod("startService");
      debugPrint(data);
    }
  }

  void stopServiceInAndroid() async {
    if (Platform.isAndroid) {
      var method = const MethodChannel("com.example.gps_app.messages");
      String data = await method.invokeMethod("stopService");
      debugPrint(data);
    }
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
    print(_local);

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
    stopwatch.reset();
    stopwatch.start();
    Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(
        () {
          tempo = stopwatch.elapsed.inHours.toString().padLeft(2, '0') +
              ":" +
              (stopwatch.elapsed.inMinutes % 60).toString().padLeft(2, '0') +
              ":" +
              (stopwatch.elapsed.inSeconds % 60).toString().padLeft(2, '0');
        },
      );
    });
  }

  _watchStop() {
    stopwatch.stop();
  }

  _novaRota() {
    _watchStart();
    DateTime newDate = DateTime.now();
    String date = newDate.day.toString().padLeft(2, '0') +
        "/" +
        newDate.month.toString().padLeft(2, '0') +
        "/" +
        newDate.year.toString();

    rota = RotaModel(titulo: date, tempo: tempo);
    rotaController.salvarRota(rota);

    rotaController.listarRotas().then(
      (value) {
        rota = value[value.length - 1];
      },
    );
    localController.listarLocais().then(
      (value) {
        local = value[value.length - 1];
      },
    );
  }

  _finalizaRota() async {
    _watchStop();
    rota = await rotaController.buscarUltimaRota();
    var editRota = RotaModel(
      id: rota.id,
      titulo: rota.titulo,
      tempo: tempo,
    );
    rotaController.atualizarRota(editRota, tempo);
  }

  _novoLocal() async {
    rota = await rotaController.buscarUltimaRota();
    int idRota = rota.id!;
    local = LocalModel(
      latitude: _userLocation.latitude!.toString(),
      longitude: _userLocation.longitude!.toString(),
      idRota: idRota,
    );
    localController.salvarLocal(local);
  }

  _ButtomClick() {
    click == false ? click = true : click = false;
    if (click == true) {
      _novaRota();
      _novoLocal();
    }
    _novaPosicao();
  }

  _novaPosicao() {
    if (click == true) {
      Timer(
        const Duration(seconds: 60),
        () => [_getUserLocation(), _novoLocal(), _novaPosicao()],
      );
      status = 'Em execução';
    } else {
      _finalizaRota();
      status = 'Parado';
    }
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
        title: const Text(
          "Home",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
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
                      side: BorderSide(
                        color: kPrimaryLightColor,
                        width: 0.5.w,
                      ),
                    ),
                    child: InkWell(
                      child: Column(
                        children: [
                          SizedBox(
                            height: 60.h,
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
                          //add button
                        ],
                      ),
                      splashColor: kPrimaryColor.withAlpha(30),
                      onTap: () {},
                    ),
                  ),
                ),
              ),
              Center(
                child: SizedBox(
                  width: 60.w,
                  height: 11.h,
                  child: Card(
                    color: const Color.fromARGB(255, 212, 212, 212),
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
                            height: 10.h,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  click == true ? 'Parar' : 'Iniciar',
                                  style: TextStyle(
                                    fontSize: 20.sp,
                                    color: click == true
                                        ? const Color.fromARGB(255, 255, 35, 35)
                                        : const Color.fromARGB(255, 21, 255, 52),
                                  ),
                                ),
                                Icon(
                                  click == true ? Icons.stop : Icons.play_arrow,
                                  color: click == true
                                      ? const Color.fromARGB(255, 255, 35, 35)
                                      : const Color.fromARGB(255, 21, 255, 52),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      splashColor: kPrimaryColor.withAlpha(30),
                      onTap: () {
                        _getUserLocation();
                        _ButtomClick();
                        click == true ? startServiceInAndroid() : stopServiceInAndroid();
                      },
                    ),
                  ),
                ),
              ),
              //text with status localização
              Center(
                child: Text(
                  "Status da captura: $status",
                  style: const TextStyle(fontSize: 15),
                ),
              ),
              Center(
                child: Text(
                  "Tempo de captura: $tempo",
                  style: const TextStyle(fontSize: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
