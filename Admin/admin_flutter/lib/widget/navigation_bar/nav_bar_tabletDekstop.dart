import 'package:admin_flutter/widget/navigation_bar/nav_bar_items.dart';
import 'package:admin_flutter/widget/navigation_bar/nav_logo.dart';
import 'package:flutter/material.dart';

class NavigationBarTabletDekstop extends StatelessWidget {
  const NavigationBarTabletDekstop({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          NavBarLogo(),
          Row(
            children: <Widget>[navBarItems('Login')],
          )
        ],
      ),
    );
    ;
  }
}
