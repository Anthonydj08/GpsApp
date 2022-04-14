import 'package:flutter/material.dart';
import 'package:gps_app/controller/localController.dart';
import 'package:gps_app/model/LocalPorRotaModel.dart';
import 'package:gps_app/model/rotaModel.dart';
import 'package:gps_app/view/detalheLocal.dart';
import 'package:gps_app/view/mapScreen.dart';
import 'package:sizer/sizer.dart';

import '../constants.dart';

class DetalheRota extends StatefulWidget {
  final RotaModel rota;
  final LocalPorRotaModel locaisPorRota;

  const DetalheRota({Key? key, required this.rota, required this.locaisPorRota})
      : super(key: key);
  static String routeName = "/historico";

  @override
  _DetalheRotaState createState() => _DetalheRotaState();
}

class _DetalheRotaState extends State<DetalheRota> {
  late RotaModel rota;
  late LocalPorRotaModel locaisPorRota;
  LocalController localController = LocalController();

  @override
  void initState() {
    super.initState();
    rota = widget.rota;
    locaisPorRota = widget.locaisPorRota;
  }

  //excluir local da rota
  void excluirLocal(int id) async {
    await localController.deletarLocal(id);
    setState(() {
      locaisPorRota.locais.removeWhere((local) => local.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Detalhe da Rota",
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
          Text("Nome: ${rota.titulo}"),
          Expanded(
            child: locaisPorRota.locais.isEmpty
                ? const Center(
                    child: Text(
                      "Nenhum local cadastrado",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  )
            : ListView.builder(
              itemCount: locaisPorRota.locais.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    title: Text(locaisPorRota.locais[index].latitude),
                    subtitle: Text(locaisPorRota.locais[index].longitude),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        excluirLocal(locaisPorRota.locais[index].id!);
                      },
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              DetalheLocal(local: locaisPorRota.locais[index]),
                        ),
                      );
                    },
                  ),
                  elevation: 4,
                  margin: const EdgeInsets.all(8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                );
              },
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
                              'Ver rota',
                              style: TextStyle(
                                fontSize: 20.sp,
                                color: const Color.fromARGB(255, 21, 51, 25),
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward,
                              color: Color.fromARGB(255, 10, 85, 20),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  splashColor: kPrimaryColor.withAlpha(30),
                  onTap: () {
                    //ir para a pagina de rota passando rotas
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MapScreen(
                          locais: locaisPorRota.locais,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
