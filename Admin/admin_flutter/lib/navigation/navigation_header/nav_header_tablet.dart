import 'package:admin_flutter/constants/app_colors.dart';
import 'package:flutter/material.dart';

class NavigationHeaderTablet extends StatelessWidget {
  const NavigationHeaderTablet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: AppBar(
        // Tambahkan AppBar sebagai judul
        title:
            Text('Dashboard', style: TextStyle(fontSize: sizeTabletTextTitle)),
        backgroundColor: Colors.deepPurple.shade400,
        automaticallyImplyLeading: false, centerTitle: true,
        // Menonaktifkan tombol back
      ),
    );
  }
}
