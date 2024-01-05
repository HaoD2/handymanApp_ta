import 'package:admin_flutter/responsive.dart';
import 'package:admin_flutter/route/menu/layanan_menu/insert_layanan/insert_layanan_dekstop.dart';
import 'package:admin_flutter/route/menu/layanan_menu/insert_layanan/insert_layanan_mobile.dart';
import 'package:admin_flutter/route/menu/layanan_menu/insert_layanan/insert_layanan_tablet.dart';
import 'package:flutter/material.dart';

class LayananMenuInsert extends StatelessWidget {
  const LayananMenuInsert({super.key});

  @override
  Widget build(BuildContext context) {
    return Responsive(
      mobile: insertLayananMobile(),
      desktop: insertLayananDekstop(),
      tablet: insertLayananTablet(),
    );
  }
}
