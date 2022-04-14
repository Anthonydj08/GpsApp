
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Configuracoes extends StatefulWidget {
  const Configuracoes({Key? key}) : super(key: key);
  static String routeName = "/configuracoes";

  @override
  _ConfiguracaoState createState() => _ConfiguracaoState();
}

class _ConfiguracaoState extends State<Configuracoes> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Configurações"),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: const Text("Configurações"),
            trailing: const Icon(Icons.settings),
            onTap: () {
              Navigator.of(context).pushNamed("/configuracoes");
            },
          ),
          ListTile(
            title: const Text("Sobre"),
            trailing: const Icon(Icons.info),
            onTap: () {
              Navigator.of(context).pushNamed("/sobre");
            },
          ),
          ListTile(
            title: const Text("Sair"),
            trailing: const Icon(Icons.exit_to_app),
            onTap: () {
              SystemNavigator.pop();
            },
          ),
          //list tile on the botton



        ],
      ),
    );
  }
  
}