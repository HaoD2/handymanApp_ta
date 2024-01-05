import 'package:admin_flutter/responsive.dart';
import 'package:admin_flutter/route/menu/layanan_menu/insert_layanan/insert_option_layanan.dart/insert_option_dekstop.dart';
import 'package:admin_flutter/route/menu/layanan_menu/insert_layanan/insert_option_layanan.dart/insert_option_mobile.dart';
import 'package:flutter/material.dart';

class MainInsertOption extends StatelessWidget {
  final layanan;
  const MainInsertOption({super.key, this.layanan});

  @override
  Widget build(BuildContext context) {
    return Responsive(
      mobile: InsertOptionMobile(),
      desktop: InsertOptionDekstop(
        layanan: this.layanan,
      ),
      tablet: InsertOptionMobile(),
    );
  }
}
