import 'package:flutter/material.dart';

class NavBarLogo extends StatelessWidget {
  const NavBarLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 80,
        width: 150,
        child: Row(
          children: [
            Image(image: AssetImage('assets/images/Free-Emblem.png')),
          ],
        ));
  }
}
