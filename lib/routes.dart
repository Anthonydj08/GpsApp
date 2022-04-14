
import 'package:flutter/material.dart';
import 'package:gps_app/theme.dart';
import 'package:gps_app/view/components/navbar.dart';
import 'package:sizer/sizer.dart';


class Routes extends StatelessWidget {
  const Routes({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'GPS',
          theme: theme(),
          initialRoute: NavBar.routeName,
          routes: {'/': (context) => const NavBar()},
        );
      },
    );
  }
}