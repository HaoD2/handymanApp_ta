import 'package:admin_flutter/responsive.dart';
import 'package:admin_flutter/route/menu/layanan_menu/Dekstop_LM.dart';
import 'package:admin_flutter/route/menu/layanan_menu/Mobile_LM.dart';
import 'package:admin_flutter/route/menu/layanan_menu/Tablet_LM.dart';
import 'package:admin_flutter/route/menu/request_saldo/desktop_RS.dart';
import 'package:admin_flutter/route/menu/request_saldo/mobile_RS.dart';
import 'package:admin_flutter/route/menu/request_saldo/rs_detail/rsd_desktop.dart';
import 'package:admin_flutter/route/menu/request_saldo/rs_detail/rsd_mobile.dart';
import 'package:admin_flutter/route/menu/request_saldo/rs_detail/rsd_tablet.dart';
import 'package:admin_flutter/route/menu/request_saldo/tablet_RS.dart';
import 'package:flutter/material.dart';

class RequestSaldoDetail extends StatelessWidget {
  final email;
  const RequestSaldoDetail({super.key, this.email});

  @override
  Widget build(BuildContext context) {
    return Responsive(
      mobile: rsdMobile(),
      desktop: rsdDesktop(
        email: this.email,
      ),
      tablet: rsdTablet(),
    );
  }
}
