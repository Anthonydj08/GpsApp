import 'package:flutter/material.dart';
import 'package:gps_app/controller/localController.dart';
import 'package:gps_app/controller/rotaController.dart';
import 'package:gps_app/model/LocalPorRotaModel.dart';
import 'package:gps_app/model/localModel.dart';
import 'package:location/location.dart';
import 'package:geocoding/geocoding.dart' as Geocoding;

class ListaLocais extends StatefulWidget {
  const ListaLocais({Key? key}) : super(key: key);
  static String routeName = "/historico";

  @override
  _ListaLocaisState createState() => _ListaLocaisState();
}

class _ListaLocaisState extends State<ListaLocais> {
  LocalController localController = LocalController();
  List<LocalModel> _listaLocais = [];
  late final _listaLocaisPorRota = [];

  @override
  void initState() {
    super.initState();
    _listLocais();
    _listLocaisPorRota();
  }

  _getUserLocation(String long, String lat) async {
    Location location = Location();
    var local = Geocoding.placemarkFromCoordinates(
        double.parse(long), double.parse(lat),
        localeIdentifier: "pt_BR");

    local.then((value) {
      Geocoding.Placemark place = value[0];
      return place.street!;
    });
  }

  _listLocais() async {
    _listaLocais = [];
    localController.listarLocais().then(
      (value) {
        print(_listaLocais);
        for (var i = 0; i < _listaLocais.length; i++) {
          print(_getUserLocation(
              _listaLocais[i].latitude, _listaLocais[i].longitude));
        }
        for (var local in value) {
          _listaLocais.add(local);
        }
      },
    );
  }

  _listLocaisPorRota() async {
    RotaController rotaController = RotaController();
    var _listaRota = [];
    rotaController.listarRotas().then(
      (value) {
        for (var rota in value) {
          _listaRota.add(rota);
        }
      },
    ).then((value) {
      for (var i = 0; i < _listaRota.length; i++) {
        localController.listarLocaisPorRota(_listaRota[i].id).then(
          (value) {
            _listaLocaisPorRota
                .add(LocalPorRotaModel(rota: _listaRota[i], locais: value));
          },
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Locais",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: FutureBuilder(
        future: _listLocais(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return ListView.builder(
              itemCount: _listaLocais.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    title: Text(
                      _listaLocais[index].latitude +
                          " " +
                          _listaLocais[index].longitude,
                    ),
                    subtitle: //latitude e longitude
                        Text(
                      "ID: " +
                          _listaLocais[index].id.toString() +
                          "\nID da rota: " +
                          _listaLocais[index].idRota.toString(),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        localController.deletarLocal(_listaLocais[index].id!);
                        _listaLocais.removeAt(index);
                        setState(() {});
                      },
                    ),
                  ),
                );
              },
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
