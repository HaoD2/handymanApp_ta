import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:myhandyman_handyman/model/kontak_user.dart';
import 'package:myhandyman_handyman/model/message.dart';
import 'package:myhandyman_handyman/model/pekerjaan.dart';
import 'package:myhandyman_handyman/page/kontak.dart';
import 'package:myhandyman_handyman/page/userHandyman.dart';
import 'package:myhandyman_handyman/service/messagingService.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:geolocator/geolocator.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class pemesanan_details extends StatefulWidget {
  final data;
  final email;
  final uid;
  static const routeName = '/Handyman/checkPemesananDetails';
  const pemesanan_details({super.key, this.data, this.email, this.uid});

  @override
  State<pemesanan_details> createState() => _pemesanan_detailsState();
}

class _pemesanan_detailsState extends State<pemesanan_details> {
  Pekerjaan? pekerjaan;
  bool isLoading = false;
  LatLng? pekerjaanLocation;
  List<Pekerjaan> datas = [];
  final messaging = MessagingService();
  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void Retrieve() async {
    final CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('users');

    QuerySnapshot querySnapshot = await usersCollection
        .where('email', isEqualTo: this.widget.email)
        .where('status_kerja', isEqualTo: false)
        .get();
    final token_sent = querySnapshot.docs.first['token_messaging'];

    if (querySnapshot.docs.first['status_kerja'] == true) {
      // Menampilkan alert box jika status_kerja adalah true
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Terdapat Pesanan yang belum selesai'),
            actions: <Widget>[
              ElevatedButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      final getTrue = await messaging.sendFCMMessage(
          messaging.getAccessToken().toString(),
          token_sent,
          "Pemesanan",
          "Kamu Mendapatkan Handyman!");
      print(getTrue);
      if (getTrue == "success") {
        InsertData(this.widget.data,
            FirebaseAuth.instance.currentUser!.email.toString());
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Gagal'),
              content: Text('Pemesanan Gagal didapatkan!'),
              actions: <Widget>[
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    }
  }

  Future<void> fetchData() async {
    final listData =
        await FirebaseDataService().getPekerjaanById(this.widget.data);
    if (listData != null) {
      setState(() {
        pekerjaan = listData;
        pekerjaanLocation = LatLng(
          pekerjaan?.location.latitude ?? 0,
          pekerjaan?.location.longitude ?? 0,
        );
      });
    }
  }

  Future<void> InsertData(String id, String newTakenBy) async {
    try {
      final firestore = FirebaseFirestore.instance;

      // Mengambil referensi dokumen yang sesuai berdasarkan ID
      final documentReference =
          firestore.collection('request_handyman').doc(id);

      // Memperbarui dokumen
      await documentReference.update({
        'taken_by':
            newTakenBy, // Menetapkan nilai taken_by menjadi nama pengguna Firebase
        'status': 'on-progress', // Menetapkan status menjadi "on-progress"
      });
      documentReference.get().then((documentSnapshot) {
        if (documentSnapshot.exists) {
          // Mendapatkan nilai dari field "user" dalam dokumen "request_handyman"
          String pengirimUser = documentSnapshot.data()?['user'];
          String pengirimHandyman = documentSnapshot.data()?['taken_by'];
          String uid_pemesanan = documentSnapshot.data()?['uid'];
          // Mencari dokumen pengguna yang cocok dalam koleksi "users"
          createMessage(pengirimUser, pengirimHandyman, uid_pemesanan);
        } else {
          print('Dokumen "request_handyman" tidak ditemukan.');
        }
      });

      // Delay selama 3 detik
      await Future.delayed(Duration(seconds: 3));

      setState(() {
        isLoading = false; // Sembunyikan tampilan loading setelah selesai.
      });
      showSuccessDialog();
      print('Data berhasil diperbarui.');
    } catch (e) {
      print('Gagal memperbarui data: $e');
    }
  }

  Future<void> createMessage(String pengirimUser, String pengirimHandyman,
      String uid_pemesanan) async {
    try {
      Message_Log pesanBaru = Message_Log(
          pengirimUser: pengirimUser,
          pengirimHandyman: pengirimHandyman,
          sent: "",
          isDone: false,
          isiPesan: "",
          waktu: DateTime.now(),
          uid_pemesanan: this.widget.uid);
      FirebaseFirestore.instance
          .collection('log_pesan')
          .add(pesanBaru.toMap())
          .then((value) {
        // Menghapus teks dari input pesan.
      }).catchError((error) {
        print('Terjadi kesalahan: $error');
      });
      kontak_user kontak = kontak_user(
          pengirimUser: pengirimUser,
          pengirimHandyman: pengirimHandyman,
          uid_pemesanan: uid_pemesanan,
          isDoneHandyman: false,
          isDoneUser: false,
          isRatingDoneUser: false,
          isRatingDoneHandyman: false,
          isReportDoneHandyman: false,
          isReportDoneUser: false);
      Map<String, dynamic> kontakMap = kontak.toMap();
      FirebaseFirestore.instance
          .collection('kontak')
          .add(kontakMap)
          .then((value) {
        // Menghapus teks dari input pesan.
      }).catchError((error) {
        print('Terjadi kesalahan: $error');
      });
    } catch (e) {
      print('Gagal memperbarui data: $e');
    }
  }

  void showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text('Data berhasil diperbarui!'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Pemesanan'),
      ),
      body: Container(
        constraints: BoxConstraints(
          minWidth: 0,
          maxWidth: MediaQuery.of(context).size.width,
          maxHeight: 600,
        ),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              'assets/images/home_decoration.png',
            ),
            fit: BoxFit.fill,
            alignment: Alignment.topCenter,
          ),
        ),
        child: SingleChildScrollView(
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
                      pekerjaan?.location.latitude ?? -6.966667,
                      pekerjaan?.location.longitude ?? 110.7122,
                    ),
                    zoom: 5.0,
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
                            pekerjaan?.location.latitude ?? -6.966667,
                            pekerjaan?.location.longitude ?? 110.7122,
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
                          onPressed: () {
                            Retrieve();
                          },
                        ),
                      ),
                    ),
                    if (isLoading)
                      Center(
                        child:
                            CircularProgressIndicator(), // Tampilkan indikator loading.
                      ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
