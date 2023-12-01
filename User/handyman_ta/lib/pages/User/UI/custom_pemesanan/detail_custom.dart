import 'package:flutter/material.dart';
import 'package:handyman_ta/pages/User/home.dart';

class detail_custom extends StatefulWidget {
  final deskripsi, alamat, require_handyman, waktu_pekerjaan;
  const detail_custom({
    Key? key,
    required this.deskripsi,
    required this.alamat,
    required this.require_handyman,
    required this.waktu_pekerjaan,
  }) : super(key: key);

  @override
  State<detail_custom> createState() => _detail_customState();
}

class _detail_customState extends State<detail_custom> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const userHomepage(),
              )),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Deskripsi:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(widget.deskripsi),
            SizedBox(height: 10),
            Text(
              'Alamat:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(widget.alamat),
            SizedBox(height: 10),
            Text(
              'Require Handyman:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(widget.require_handyman),
            SizedBox(height: 10),
            Text(
              'Waktu Pekerjaan:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(widget.waktu_pekerjaan),
          ],
        ),
      ),
    );
  }
}
