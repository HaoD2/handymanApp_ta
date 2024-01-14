import 'package:admin_flutter/responsive.dart';

import 'package:admin_flutter/route/menu/layanan_menu/delete_layanan/delete_option_layanan/delete_option_desktop.dart';
import 'package:admin_flutter/route/menu/layanan_menu/insert_layanan/insert_layanan_mobile.dart';
import 'package:admin_flutter/route/menu/layanan_menu/insert_layanan/insert_layanan_tablet.dart';
import 'package:flutter/material.dart';

class OptionMenuDelete extends StatelessWidget {
  final nama_pekerjaan;
  const OptionMenuDelete({super.key, this.nama_pekerjaan});

  @override
  Widget build(BuildContext context) {
    print('--->>>');
    print(nama_pekerjaan);
    return Responsive(
      mobile: insertLayananMobile(),
      desktop: OptionDeleteDekstop(namaInput: nama_pekerjaan),
      tablet: insertLayananTablet(),
    );
  }
}
