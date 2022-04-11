// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:gps_app/view/configuracoes.dart';
import 'package:gps_app/view/listaLocais.dart';
import 'package:gps_app/view/listaRotas.dart';
import 'package:gps_app/view/mapScreen.dart';
import 'package:sizer/sizer.dart';
import 'package:gps_app/view/home.dart';

import '../../constants.dart';

class NavBar extends StatefulWidget {
  const NavBar({Key? key}) : super(key: key);
  static String routeName = "/bottom_bar";

  @override
  _NavBarState createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();
  _NavBarState();

  int index = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      Home(),
      //MapScreen(locais: [],),
      ListaRotas(),
      ListaLocais(),
      Configuracoes(),
      Configuracoes(),
    ];

    return Scaffold(
      body: screens[index],
      bottomNavigationBar: CurvedNavigationBar(
        key: _bottomNavigationKey,
        index: 0,
        height: 50.0,
        items: const <Widget>[
          Icon(Icons.home, size: 30),
          //Icon(Icons.map, size: 30),
          Icon(Icons.near_me_sharp, size: 30),
          Icon(Icons.place, size: 30),
          Icon(Icons.settings, size: 30),
          Icon(Icons.circle, size: 30),
        ],
        color: kPrimaryColor,
        buttonBackgroundColor: kPrimaryColor,
        backgroundColor: kPrimaryColor,
        animationCurve: Curves.easeInOut,
        animationDuration: Duration(milliseconds: 400),
        onTap: (index) {
          setState(() {
            this.index = index;
          });
        },
        letIndexChange: (index) => true,
      ),
    );
  }
}
