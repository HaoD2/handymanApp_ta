import 'package:admin_flutter/responsive.dart';
import 'package:admin_flutter/route/menu/layanan_menu/insert_layanan/insert_option_layanan/insert_option_dekstop.dart';
import 'package:admin_flutter/route/menu/layanan_menu/insert_layanan/insert_option_layanan/insert_option_mobile.dart';
import 'package:admin_flutter/route/menu/layanan_menu/update_layanan/update_option_layanan/update_option_desktop.dart';
import 'package:flutter/material.dart';

class MainUpdateOption extends StatelessWidget {
  final nama_option;
  const MainUpdateOption({super.key, this.nama_option});

  @override
  Widget build(BuildContext context) {
    print(nama_option);
    return Responsive(
      mobile: InsertOptionMobile(),
      desktop: UpdateOptionDekstop(
        nama_option: nama_option,
      ),
      tablet: InsertOptionMobile(),
    );
  }
}
