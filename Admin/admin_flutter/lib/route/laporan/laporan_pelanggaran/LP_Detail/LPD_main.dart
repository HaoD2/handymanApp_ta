import 'package:admin_flutter/responsive.dart';
import 'package:admin_flutter/route/laporan/laporan_pelanggaran/LP_Detail/LPD_dekstop.dart';
import 'package:admin_flutter/route/laporan/laporan_pelanggaran/LP_Detail/LPD_mobile.dart';
import 'package:admin_flutter/route/laporan/laporan_pelanggaran/LP_Detail/LPD_tablet.dart';
import 'package:flutter/material.dart';

class LPDMain extends StatelessWidget {
  final uid;
  const LPDMain({super.key, this.uid});

  @override
  Widget build(BuildContext context) {
    return Responsive(
      mobile: LPDMobile(),
      tablet: LPDTablet(),
      desktop: LPDDekstop(uid: uid),
    );
  }
}
