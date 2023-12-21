import 'package:admin_flutter/responsive.dart';
import 'package:admin_flutter/route/laporan/laporan_pelanggaran/LP_Desktop.dart';
import 'package:admin_flutter/route/laporan/laporan_pelanggaran/LP_Mobile.dart';
import 'package:admin_flutter/route/laporan/laporan_pelanggaran/LP_Tablet.dart';
import 'package:flutter/material.dart';

class LaporanPelanggaran extends StatelessWidget {
  const LaporanPelanggaran({super.key});

  @override
  Widget build(BuildContext context) {
    return Responsive(
      mobile: LaporangPelanggaranMobile(),
      tablet: LaporanPelanggaranTablet(),
      desktop: LaporanPelanggaranDekstop(),
    );
  }
}
