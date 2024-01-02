import 'package:admin_flutter/responsive.dart';
import 'package:admin_flutter/route/menu/layanan_menu/layanan_Dekstop.dart';
import 'package:admin_flutter/route/menu/layanan_menu/layanan_Mobile.dart';
import 'package:admin_flutter/route/menu/layanan_menu/layanan_Tablet.dart';
import 'package:flutter/material.dart';

class LayananMenu extends StatelessWidget {
  const LayananMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Responsive(
      mobile: CRUDMenuMobile(),
      desktop: CRUDMenuDekstop(),
      tablet: CRUDMenuTablet(),
    );
  }
}
