import 'package:admin_flutter/responsive.dart';
import 'package:admin_flutter/route/laporan/laporan_insight/LI_Dekstop.dart';
import 'package:admin_flutter/route/laporan/laporan_insight/LI_Mobile.dart';
import 'package:admin_flutter/route/laporan/laporan_insight/LI_Tablet.dart';
import 'package:flutter/material.dart';

class LaporanInsight extends StatelessWidget {
  const LaporanInsight({super.key});

  @override
  Widget build(BuildContext context) {
    return Responsive(
      desktop: LaporanInsightDekstop(),
      mobile: LaporanInsightMobile(),
      tablet: LaporanInsightTablet(),
    );
  }
}
