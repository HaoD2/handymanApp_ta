import 'package:admin_flutter/responsive.dart';
import 'package:admin_flutter/route/menu/layanan_menu/insert_layanan/insert_layanan_dekstop.dart';
import 'package:admin_flutter/route/menu/layanan_menu/insert_layanan/insert_layanan_mobile.dart';
import 'package:admin_flutter/route/menu/layanan_menu/insert_layanan/insert_layanan_tablet.dart';
import 'package:admin_flutter/route/menu/layanan_menu/update_layanan/update_Dekstop_LM.dart';
import 'package:flutter/material.dart';

class LayananMenuUpdate extends StatelessWidget {
  final nama_pekerjaan;
  const LayananMenuUpdate({super.key, this.nama_pekerjaan});

  @override
  Widget build(BuildContext context) {
    return Responsive(
      mobile: insertLayananMobile(),
      desktop: UpdateLayananDesktop(namaPekerjaan: nama_pekerjaan),
      tablet: insertLayananTablet(),
    );
  }
}
