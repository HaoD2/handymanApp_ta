import 'package:admin_flutter/constants/app_colors.dart';
import 'package:admin_flutter/route/laporan_pelanggaran.dart';
import 'package:flutter/material.dart';

class NavigationSideMobile extends StatelessWidget {
  const NavigationSideMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: Colors.deepPurple.shade400,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(
                  "https://faces-img.xcdn.link/image-lorem-face-3430.jpg"),
              radius: 15.0,
            ),
            title: Text('Welcome, Admin',
                style: TextStyle(
                    color: Colors.black87, fontSize: sizeMobileTextContent)),
          ),
          SizedBox(
            height: 20,
          ),
          ListTile(
            leading: Icon(Icons.home, color: Colors.white),
            title: Text('Home',
                style: TextStyle(
                    color: Colors.white, fontSize: sizeMobileTextContent)),
            onTap: () {
              // Action for Home
            },
          ),
          SizedBox(
            height: 20,
          ),
          ListTile(
            leading: Icon(Icons.bar_chart, color: Colors.white),
            title: Text('Laporan Insight',
                style: TextStyle(
                    color: Colors.white, fontSize: sizeMobileTextContent)),
            onTap: () {
              // Action for Rapports
            },
          ),
          SizedBox(
            height: 20,
          ),
          ListTile(
            leading: Icon(Icons.warning, color: Colors.white),
            title: Text('Laporan Pelanggaran',
                style: TextStyle(
                    color: Colors.white, fontSize: sizeMobileTextContent)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LaporanPelanggaran()),
              );
            },
          ),
          SizedBox(
            height: 20,
          ),
          ListTile(
            leading: Icon(Icons.logout_outlined, color: Colors.white),
            title: Text('Logout',
                style: TextStyle(
                    color: Colors.white, fontSize: sizeMobileTextContent)),
            onTap: () {
              // Action for Settings
            },
          ),
        ],
      ),
    );
  }
}
