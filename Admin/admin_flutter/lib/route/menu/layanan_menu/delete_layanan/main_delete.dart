import 'package:admin_flutter/responsive.dart';
import 'package:admin_flutter/route/menu/layanan_menu/delete_layanan/delete_layanan_dekstop.dart';
import 'package:admin_flutter/route/menu/layanan_menu/insert_layanan/insert_layanan_mobile.dart';
import 'package:admin_flutter/route/menu/layanan_menu/insert_layanan/insert_layanan_tablet.dart';
import 'package:flutter/material.dart';

class LayananMenuDelete extends StatelessWidget {
  final nama_pekerjaan;
  const LayananMenuDelete({super.key, this.nama_pekerjaan});

  @override
  Widget build(BuildContext context) {
    return Responsive(
      mobile: insertLayananMobile(),
      desktop: DeleteLayananDekstop(nama_pekerjaan: nama_pekerjaan),
      tablet: insertLayananTablet(),
    );
  }
}
