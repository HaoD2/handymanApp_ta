import 'package:admin_flutter/widget/navigation_bar/nav_bar_mobile.dart';
import 'package:admin_flutter/widget/navigation_bar/nav_bar_tabletDekstop.dart';
import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';

class nav_bar extends StatelessWidget {
  const nav_bar({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout(
      mobile: NavigationBarMobile(),
      tablet: NavigationBarTabletDekstop(),
    );
  }
}
