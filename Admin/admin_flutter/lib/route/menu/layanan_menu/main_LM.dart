import 'package:admin_flutter/responsive.dart';
import 'package:admin_flutter/route/menu/layanan_menu/Dekstop_LM.dart';
import 'package:admin_flutter/route/menu/layanan_menu/Mobile_LM.dart';
import 'package:admin_flutter/route/menu/layanan_menu/Tablet_LM.dart';
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
