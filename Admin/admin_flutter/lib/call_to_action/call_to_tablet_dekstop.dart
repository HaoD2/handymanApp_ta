import 'package:admin_flutter/constants/app_colors.dart';
import 'package:flutter/material.dart';

class CallToActionTableDekstop extends StatelessWidget {
  final String title;
  const CallToActionTableDekstop(this.title);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 60, vertical: 15),
      child: Text(
        title,
        style: TextStyle(
            fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
      ),
      decoration: BoxDecoration(
          color: primaryColor, borderRadius: BorderRadius.circular(5)),
    );
  }
}
