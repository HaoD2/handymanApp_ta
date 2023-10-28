import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:myhandyman_handyman/model/pekerjaan.dart';
import 'package:myhandyman_handyman/page/userHandyman.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:geolocator/geolocator.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class pemesanan_details extends StatefulWidget {
  final data;
  static const routeName = '/Handyman/checkPemesananDetails';
  const pemesanan_details({super.key, this.data});

  @override
  State<pemesanan_details> createState() => _pemesanan_detailsState();
}

class _pemesanan_detailsState extends State<pemesanan_details> {
  Pekerjaan? pekerjaan;
  List<Pekerjaan> datas = [];
  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final listData =
        await FirebaseDataService().getPekerjaanById(this.widget.data);
    if (listData != null) {
      setState(() {
        pekerjaan = listData;
        print(pekerjaan?.address);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Pemesanan'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Peta dan kontennya di sini
            Container(
              margin: EdgeInsets.all(15),
              height: 200,
              child: FlutterMap(
                options: MapOptions(
                  center: LatLng(
                    pekerjaan?.location.latitude ?? 0,
                    pekerjaan?.location.longitude ?? 0,
                  ),
                  zoom: 13.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                    subdomains: ['a', 'b', 'c'],
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        width: 40.0,
                        height: 40.0,
                        point: LatLng(
                          pekerjaan?.location.latitude ?? 0,
                          pekerjaan?.location.longitude ?? 0,
                        ),
                        builder: (ctx) => Container(
                          child: Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 40.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Tampilan judul dan detail di bawah peta
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Tipe Pekerjaan: ${pekerjaan?.tipe_Pekerjaan ?? 'Tidak Ada'}',
                style: TextStyle(fontSize: 18),
              ),
            ),
            // Tambahkan bagian lainnya di sini sesuai kebutuhan Anda seperti Alamat, Gambar, Deskripsi, Jam, Tanggal, dll.
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Alamat: ${pekerjaan?.address ?? 'Tidak Ada'}',
                style: TextStyle(fontSize: 18),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Gambar: ',
                style: TextStyle(fontSize: 18),
              ),
            ),
            // Padding(
            //     padding: const EdgeInsets.all(16.0),
            //     child: Image.network('${pekerjaan?.image.toString() ?? ""} ')),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Deskripsi: ${pekerjaan?.description ?? 'Tidak Ada'}',
                style: TextStyle(fontSize: 18),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Jam: ${pekerjaan?.startTime ?? 'Tidak Ada'} - ${pekerjaan?.endTime ?? 'Tidak Ada'}',
                style: TextStyle(fontSize: 18),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Tanggal: ${pekerjaan?.datetime?.toDate().toString().substring(0, 10) ?? 'Tidak Ada'}',
                style: TextStyle(fontSize: 18),
              ),
            ),
            // Tambahkan komponen lainnya sesuai kebutuhan Anda seperti Text Alamat, dll.
            Container(
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      child: Text('Back'),
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true)
                            .pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (BuildContext context) {
                              return userHandyman();
                            },
                          ),
                          (_) => false,
                        );
                      },
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: ElevatedButton(
                        child: Text('Submit'),
                        onPressed: () {},
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
