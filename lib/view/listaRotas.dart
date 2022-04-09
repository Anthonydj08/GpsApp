import 'package:flutter/material.dart';
import 'package:gps_app/controller/localController.dart';
import 'package:gps_app/controller/rotaController.dart';
import 'package:gps_app/model/LocalPorRotaModel.dart';
import 'package:gps_app/model/rotaModel.dart';
import 'package:gps_app/view/detalheRota.dart';

class ListaRotas extends StatefulWidget {
  const ListaRotas({Key? key}) : super(key: key);
  static String routeName = "/historico";

  @override
  _ListaRotasState createState() => _ListaRotasState();
}

class _ListaRotasState extends State<ListaRotas> {
  RotaController rotaController = RotaController();
  LocalController localController = LocalController();
  late List<RotaModel> _listaRotas = [];
  late final List<LocalPorRotaModel> _listaLocaisPorRota = [];

  @override
  void initState() {
    super.initState();
    _listRotas();
    _listLocaisPorRota();
  }

  _listRotas() async {
    _listaRotas = [];
    rotaController.listarRotas().then(
      (value) {
        value.forEach((rota) => _listaRotas.add(rota));
        print(_listaRotas);
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
    //card to list rotas
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Rotas",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: Container(
        child: FutureBuilder(
          future: _listRotas(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return ListView.builder(
                itemCount: _listaRotas.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      title: Text(_listaRotas[index].titulo),
                      subtitle: Text(
                        //tempo e id
                        "Tempo: ${_listaRotas[index].tempo} \nId: ${_listaRotas[index].id}, \nNº locais: ${_listaLocaisPorRota[index].locais.length}",
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetalheRota(
                              rota: _listaRotas[index],
                              locaisPorRota: _listaLocaisPorRota[index],
                            ),
                          ),
                        );
                      },
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          rotaController.deletarRota(_listaRotas[index].id!);
                          _listaRotas.removeAt(index);
                          setState(() {});
                        },
                      ),
                    ),
                  );
                },
              );
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    );
  }
}
