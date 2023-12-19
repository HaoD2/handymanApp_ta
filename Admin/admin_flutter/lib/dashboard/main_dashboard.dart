import 'package:admin_flutter/dashboard/desktop.dart';
import 'package:admin_flutter/dashboard/mobile.dart';
import 'package:admin_flutter/dashboard/tablet.dart';
import 'package:admin_flutter/responsive.dart';
import 'package:flutter/material.dart';

class MainDashboardScreen extends StatelessWidget {
  const MainDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Responsive(
      mobile: DashboardMobile(),
      tablet: DashboardTablet(),
      desktop: DashboardDekstop(),
    );
  }
}
