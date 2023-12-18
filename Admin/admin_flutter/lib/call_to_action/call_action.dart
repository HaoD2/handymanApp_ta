import 'package:admin_flutter/call_to_action/call_to_mobile.dart';
import 'package:admin_flutter/call_to_action/call_to_tablet_dekstop.dart';
import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';

class callAction extends StatelessWidget {
  final String title;
  const callAction(this.title);

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout(
      mobile: CallActionToMobile(title),
      tablet: CallToActionTableDekstop(title),
    );
  }
}
