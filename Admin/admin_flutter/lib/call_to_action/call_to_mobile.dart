import 'package:admin_flutter/constants/app_colors.dart';
import 'package:flutter/material.dart';

class CallActionToMobile extends StatelessWidget {
  final String title;
  const CallActionToMobile(this.title);

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 60,
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
        ),
        decoration: BoxDecoration(
            color: primaryColor, borderRadius: BorderRadius.circular(5)));
  }
}
