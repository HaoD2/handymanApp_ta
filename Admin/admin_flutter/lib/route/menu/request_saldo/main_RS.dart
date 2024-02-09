import 'package:admin_flutter/responsive.dart';
import 'package:admin_flutter/route/menu/layanan_menu/Dekstop_LM.dart';
import 'package:admin_flutter/route/menu/layanan_menu/Mobile_LM.dart';
import 'package:admin_flutter/route/menu/layanan_menu/Tablet_LM.dart';
import 'package:admin_flutter/route/menu/request_saldo/desktop_RS.dart';
import 'package:admin_flutter/route/menu/request_saldo/mobile_RS.dart';
import 'package:admin_flutter/route/menu/request_saldo/tablet_RS.dart';
import 'package:flutter/material.dart';

class RequestSaldo extends StatelessWidget {
  const RequestSaldo({super.key});

  @override
  Widget build(BuildContext context) {
    return Responsive(
      mobile: RequesT_Saldo_Mobile(),
      desktop: Request_Saldo_Dekstop(),
      tablet: Request_Saldo_Tablet(),
    );
  }
}
