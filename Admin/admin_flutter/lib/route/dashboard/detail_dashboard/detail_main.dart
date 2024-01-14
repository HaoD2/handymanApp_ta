import 'package:admin_flutter/responsive.dart';
import 'package:admin_flutter/route/dashboard/detail_dashboard/detail_desktop.dart';
import 'package:admin_flutter/route/dashboard/detail_dashboard/detail_mobile.dart';
import 'package:admin_flutter/route/dashboard/detail_dashboard/detail_tablet.dart';
import 'package:flutter/material.dart';

class Detail_Dashboard extends StatelessWidget {
  final email;
  const Detail_Dashboard({Key? key, this.email}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Responsive(
      mobile: detail_mobile(),
      tablet: detail_tablet(),
      desktop: detail_desktop(email: email),
    );
  }
}
