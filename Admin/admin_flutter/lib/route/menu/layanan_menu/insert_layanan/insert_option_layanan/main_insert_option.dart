import 'package:admin_flutter/responsive.dart';
import 'package:admin_flutter/route/menu/layanan_menu/insert_layanan/insert_option_layanan/insert_option_dekstop.dart';
import 'package:admin_flutter/route/menu/layanan_menu/insert_layanan/insert_option_layanan/insert_option_mobile.dart';
import 'package:flutter/material.dart';

class MainInsertOption extends StatelessWidget {
  final List<String> layanan;
  final harga;
  final nama_pekerjaan;
  const MainInsertOption(
      {super.key, required this.layanan, this.harga, this.nama_pekerjaan});

  @override
  Widget build(BuildContext context) {
    List<String> newDataList =
        layanan.map((item) => item.toLowerCase()).toList();
    return Responsive(
      mobile: InsertOptionMobile(),
      desktop: InsertOptionDekstop(
        layanan: newDataList,
        nama_pekerjaan: nama_pekerjaan,
        harga: harga,
      ),
      tablet: InsertOptionMobile(),
    );
  }
}
