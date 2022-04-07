import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:gps_app/view/map.dart';
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

  int index = 1;

  @override
  Widget build(BuildContext context) {
    
    final screens = [
      Home(),
      Map(),
      Home(),
      Home(),
      Home(),
    ];

    return Scaffold(
      body: screens[index],
      bottomNavigationBar: CurvedNavigationBar(
        
        key: _bottomNavigationKey,
        index: 0,
        height: 50.0,
        items: <Widget>[
          Icon(Icons.home, size: 30),
          Icon(Icons.search, size: 30),
          Icon(Icons.add_circle, size: 30),
          Icon(Icons.favorite, size: 30),
          Icon(Icons.person, size: 30),
        ],
        color: kPrimaryColor,
        buttonBackgroundColor: kPrimaryColor,
        backgroundColor: kPrimaryColor,
        animationCurve: Curves.easeInOut,
        animationDuration: Duration(milliseconds: 600),
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