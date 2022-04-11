import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gps_app/controller/localController.dart';
import 'package:gps_app/model/enderecoModel.dart';
import 'package:gps_app/model/localModel.dart';
import 'package:geocoding/geocoding.dart' as Geocoding;

class DetalheLocal extends StatefulWidget {
  final LocalModel local;

  const DetalheLocal({
    Key? key,
    required this.local,
  }) : super(key: key);
  static String routeName = "/historico";

  @override
  _DetalheRotaState createState() => _DetalheRotaState();
}

class _DetalheRotaState extends State<DetalheLocal> {
  late LocalModel local;
  LocalController localController = LocalController();
  late EnderecoModel endereco = EnderecoModel(
      rua: "", cidade: "", estado: "", pais: "", cep: "", bairro: "");

  @override
  void initState() {
    super.initState();
    local = widget.local;
    Timer(const Duration(seconds: 1), () => _getUserLocation());
  }

  Future<void> _getUserLocation() async {
    setState(
      () {
        var res = Geocoding.placemarkFromCoordinates(
            double.parse(local.latitude), double.parse(local.longitude),
            localeIdentifier: "pt_BR");

        res.then((value) {
          Geocoding.Placemark place = value[0];
          endereco = EnderecoModel(
            cep: place.postalCode!,
            cidade: place.subAdministrativeArea!,
            estado: place.administrativeArea!,
            bairro: place.subLocality!,
            rua: place.street!,
            pais: place.country!,
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Detalhe do local",
          style: TextStyle(
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
        children: <Widget>[
          SizedBox(
            height: 300,
            width: 350,
            child: Card(
              child: Image.network(
                "https://maps.googleapis.com/maps/api/staticmap?center=${local.latitude},${local.longitude}&zoom=16&size=500x500&maptype=roadmap&markers=color:red%7Clabel:S%7C${local.latitude},${local.longitude}&key=AIzaSyA_ztUeRrky_gYmsbnsKnfE6tOPGC_ABhg",
                fit: BoxFit.cover,
              ),
              elevation: 5,
              margin: const EdgeInsets.all(8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      const Icon(Icons.location_on),
                      Text(
                        'Rua: ${endereco.rua}',
                        style: const TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      const Icon(Icons.location_on),
                      Text(
                        'Bairro: ${endereco.bairro}',
                        style: const TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      const Icon(Icons.location_on),
                      Text(
                        'Cidade: ${endereco.cidade}',
                        style: const TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      const Icon(Icons.location_on),
                      Text(
                        'Estado: ${endereco.estado}',
                        style: const TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      const Icon(Icons.location_on),
                      Text(
                        'País: ${endereco.pais}',
                        style: const TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      const Icon(Icons.location_on),
                      Text(
                        'CEP: ${endereco.cep}',
                        style: const TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            elevation: 4,
            margin: const EdgeInsets.all(8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ],
      ),
    );
  }
}
