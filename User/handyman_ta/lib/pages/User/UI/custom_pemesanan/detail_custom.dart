import 'dart:convert';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:handyman_ta/pages/Transaction/transaction_menu.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:handyman_ta/pages/User/UI/custom_pemesanan/pemesanan_option.dart';
import 'package:image_picker/image_picker.dart';

class detail_custom extends StatefulWidget {
  final deskripsi,
      alamat,
      require_handyman,
      start_time,
      end_time,
      price,
      dateTime,
      position;
  const detail_custom(
      {Key? key,
      required this.deskripsi,
      required this.alamat,
      required this.require_handyman,
      required this.start_time,
      required this.end_time,
      required this.price,
      required this.dateTime,
      required this.position})
      : super(key: key);

  @override
  State<detail_custom> createState() => _detail_customState();
}

class _detail_customState extends State<detail_custom> {
  XFile? requestImage;
  String uid = '';
  Position? _currentPosition;
  final dateController = TextEditingController();
  Future<String> uploadImageToFirebaseStorage(XFile imageFile) async {
    try {
      final storage = FirebaseStorage.instance;
      final storageReference = storage.ref().child('pemesananRequest_$uid.jpg');
      await storageReference.putFile(File(requestImage!.path));
      String imageUrl = await storageReference.getDownloadURL();
      return imageUrl;
    } catch (e) {
      return ''; // Kembalikan nilai kosong jika terjadi kesalahan
    }
  }

  Future<void> getDatas() async {
    final Querysnaps = await FirebaseFirestore.instance
        .collection("users")
        .where('email', isEqualTo: FirebaseAuth.instance.currentUser?.email)
        .get();
    if (Querysnaps.docs.isNotEmpty) {
      final DocumentSnapshot documentSnapshot = Querysnaps.docs.first;
      final data = documentSnapshot.data() as Map<String, dynamic>;
      final documentId = documentSnapshot.id; // Mengambil ID dokumen
      setState(() {
        uid = documentId;
      });
    } else {
      // Handle jika dokumen tidak ditemukan
      setState(() {
        uid = ""; // Atau atur ke nilai default yang sesuai
      });
    }
  }

  Future<void> _submitForm() async {
    String? user = FirebaseAuth.instance.currentUser?.email;
    String address = widget.alamat;
    String description = widget.deskripsi;
    String start_time = widget.start_time;
    String end_time = widget.end_time;

    String price = widget.price;
    // Dapatkan referensi ke collection "request_handyman" di Firebase
    final CollectionReference requestCollection =
        FirebaseFirestore.instance.collection('request_handyman');
    String today = DateTime.now()
        .toLocal()
        .toString()
        .substring(0, 10)
        .replaceAll("-", "");

// Dapatkan nomor urut terakhir dari database
    QuerySnapshot lastOrder =
        await requestCollection.orderBy('uid', descending: true).limit(1).get();

    int lastOrderNumber = 0;

    if (lastOrder.docs.isNotEmpty) {
      // Jika ada pemesanan sebelumnya, ambil nomor urutnya
      lastOrderNumber =
          int.parse(lastOrder.docs.first.get('uid').substring(13)) + 1;
    }

// Format nomor urut menjadi 6 digit dengan padding nol
    String orderNumber = lastOrderNumber.toString().padLeft(6, '0');

// Jika nomor urut masih 0, mulai dari "ORDER061123000001"
    if (lastOrderNumber == 0) {
      orderNumber = "000001";
    }

// Gabungkan semuanya untuk membuat kode unik
    String uniqueCode = 'ORDERCP$today$orderNumber';
    // Lakukan operasi form submission sesuai kebutuhan Anda
    Map<String, dynamic> requestData = {
      'uid': uniqueCode,
      'tipe_pekerjaan': "Custom Pemesanan",
      'user': user,
      'status': "pending",
      'address': address,
      'dateTime': widget.dateTime.toString(),
      'start_time': start_time,
      'price': price,
      'end_time': end_time,
      'otherOption': ' ',
      'description': description,
      'location': widget.position != null
          ? GeoPoint(widget.position.latitude, widget.position.longitude)
          : null,
      'Option': ' ',
      'image': requestImage != null
          ? await uploadImageToFirebaseStorage(requestImage!)
          : null,
    };
    Map<String, dynamic> requestAPI = {
      'transaction_detail': {"order_id": uniqueCode, "gross_amount": price},
      'credit_card': {"secure": true},
      'item_details': {
        'id': uniqueCode,
        'price': price,
        'Option_Name': ' ',
        'dateTime': widget.dateTime.toString(),
        'start_time': start_time.toString(),
        'end_time': end_time.toString(),
        'otherOption': ' ',
        'description': description,
        'tipe_pekerjaan': 'Layanan Custom',
      },
      'customer_detail': {
        'user': user,
        'address': address,
      }
    };
    //post API

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: user)
        .where('status_pesan', isEqualTo: true)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Tidak bisa memesan'),
            content: Text(
                'Anda tidak dapat memesan karena terdapat pesanan yang belum selesai.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }
    String password = '';
    String basicAuth = 'Basic ' +
        base64.encode(
            utf8.encode('SB-Mid-server-jHCvz3LmqB9xqdY7KYD5Tu9d:$password'));
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': basicAuth, // Ganti basicAuth dengan nilai yang sesuai
    };
    final res = await http.post(
        Uri.parse(
            "https://famous-mastiff-sunny.ngrok-free.app/api/transaction/purchase"),
        headers: headers,
        body: jsonEncode(requestAPI));
    if (res.statusCode == 200) {
      print('>>>>>>>>>>>>>>>>>>>>success');
      final responseData = jsonDecode(res.body);

      print(responseData['redirect']);
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (BuildContext context) {
            return SnapScreen(
              redirect_url: responseData['redirect'],
              order_id: uniqueCode,
              requestData: requestData,
            );
          },
        ),
        (_) => false,
      );
      setState(() {
        requestImage = null;
      });
    } else {
      print(res.body);
      print(res.statusCode.toString() + ">>>>>");
      print('>>>>>>>>>>>>>>>>>>>>gagal');
    }
  }

  Future<void> _getImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        requestImage = XFile(pickedFile.path);
      }
    });
  }

  @override
  void initState() {
    super.initState();

    getDatas();
  }

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
              builder: (context) => const PemesananOption(),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/home_decoration.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Konten lainnya di atas background
          Padding(
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
                Text(widget.start_time + " - " + widget.end_time),
                SizedBox(height: 10),
                Text(
                  'Budget Harga Pekerjaan: ' + widget.price,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 16.0),
                Container(
                  margin: EdgeInsets.all(15),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Gambar (Optional)",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(15),
                  alignment: Alignment.centerLeft,
                  child: ElevatedButton(
                    onPressed: _getImage,
                    child: Text('Unggah Foto'),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    _submitForm();
                  },
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
