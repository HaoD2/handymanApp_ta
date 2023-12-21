import 'package:admin_flutter/navigation/navigation_side/nav_side_dekstop.dart';
import 'package:admin_flutter/navigation/navigation_side/nav_side_mobile.dart';
import 'package:admin_flutter/navigation/navigation_side/nav_side_tablet.dart';
import 'package:admin_flutter/responsive.dart';
import 'package:flutter/material.dart';

class NavigationSideResponsive extends StatelessWidget {
  const NavigationSideResponsive({super.key});

  @override
  Widget build(BuildContext context) {
    return Responsive(
      mobile: NavigationSideMobile(),
      tablet: NavigationSideTablet(),
      desktop: NavigationSideDekstop(),
    );
  }
}
