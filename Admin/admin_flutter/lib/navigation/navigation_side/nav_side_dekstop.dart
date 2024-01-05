import 'package:admin_flutter/constants/app_colors.dart';
import 'package:admin_flutter/route/dashboard/main_dashboard.dart';
import 'package:admin_flutter/route/laporan/laporan_pelanggaran/main_pelanggaran.dart';
import 'package:admin_flutter/route/menu/layanan_menu/main_layanan.dart';
import 'package:admin_flutter/route/menu/view_listing/main_listing.dart';
import 'package:flutter/material.dart';

class NavigationSideDekstop extends StatelessWidget {
  const NavigationSideDekstop({super.key});

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
                    color: Colors.black87, fontSize: sizeDesktopTextContent)),
          ),
          SizedBox(
            height: 10,
          ),
          ListTile(
            leading: Icon(Icons.home, color: Colors.white),
            title: Text('Home',
                style: TextStyle(
                    color: Colors.white, fontSize: sizeDesktopTextContent)),
            onTap: () {
              // Action for Home
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MainDashboardScreen()),
              );
            },
          ),
          SizedBox(
            height: 10,
          ),
          ListTile(
            leading: Icon(Icons.bar_chart, color: Colors.white),
            title: Text('Laporan Insight',
                style: TextStyle(
                    color: Colors.white, fontSize: sizeDesktopTextContent)),
            onTap: () {
              // Action for Rapports
            },
          ),
          SizedBox(
            height: 10,
          ),
          ListTile(
            leading: Icon(Icons.warning, color: Colors.white),
            title: Text('Laporan Pelanggaran',
                style: TextStyle(
                    color: Colors.white, fontSize: sizeDesktopTextContent)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LaporanPelanggaran()),
              );
            },
          ),
          SizedBox(
            height: 10,
          ),
          ListTile(
            leading: Icon(Icons.logout_outlined, color: Colors.white),
            title: Text('Laporan Listing',
                style: TextStyle(
                    color: Colors.white, fontSize: sizeDesktopTextContent)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ListingView()),
              );
            },
          ),
          SizedBox(
            height: 10,
          ),
          ListTile(
            leading: Icon(Icons.logout_outlined, color: Colors.white),
            title: Text('Laporan Pekerjaan',
                style: TextStyle(
                    color: Colors.white, fontSize: sizeDesktopTextContent)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LayananMenu()),
              );
            },
          ),
          SizedBox(
            height: 10,
          ),
          ListTile(
            leading: Icon(Icons.logout_outlined, color: Colors.white),
            title: Text('Logout',
                style: TextStyle(
                    color: Colors.white, fontSize: sizeDesktopTextContent)),
            onTap: () {
              // Action for Settings
            },
          ),
        ],
      ),
    );
  }
}
