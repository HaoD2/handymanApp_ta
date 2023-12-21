import 'package:admin_flutter/navigation/navigation_header/nav_header_dekstop.dart';
import 'package:admin_flutter/navigation/navigation_header/nav_header_mobile.dart';
import 'package:admin_flutter/navigation/navigation_header/nav_header_tablet.dart';
import 'package:admin_flutter/navigation/navigation_side/nav_side_dekstop.dart';
import 'package:admin_flutter/navigation/navigation_side/nav_side_mobile.dart';
import 'package:admin_flutter/navigation/navigation_side/nav_side_tablet.dart';
import 'package:admin_flutter/responsive.dart';
import 'package:flutter/material.dart';

class NavigationHeaderResponsive extends StatelessWidget {
  const NavigationHeaderResponsive({super.key});

  @override
  Widget build(BuildContext context) {
    return Responsive(
      mobile: NavigationHeaderMobile(),
      tablet: NavigationHeaderTablet(),
      desktop: NavigationHeaderDekstop(),
    );
  }
}
