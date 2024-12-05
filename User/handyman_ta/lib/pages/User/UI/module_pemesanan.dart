import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/src/datetime_picker_theme.dart'
    as custom;
import 'package:flutter_dotenv/flutter_dotenv.dart' as DotEnv;
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:geocoding/geocoding.dart';
import 'package:handyman_ta/pages/Model/userTransaction.dart';
import 'package:handyman_ta/pages/Transaction/transaction_menu.dart';
import 'package:handyman_ta/pages/User/home.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class module extends StatelessWidget {
  final layanan;
  static const routeName = '/User/module_pemesanan';
  const module({Key? key, this.layanan});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Form Validation with Google Maps Integration',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ModulePemesanan(layanan: layanan),
    );
  }
}

class ModulePemesanan extends StatefulWidget {
  final layanan;

  const ModulePemesanan({Key? key, this.layanan});

  @override
  _ModulePemesananState createState() => _ModulePemesananState();
}

class _ModulePemesananState extends State<ModulePemesanan> {
  TimeOfDay selectedTimeStart = TimeOfDay.now();
  List<String> optionLayanan = [];
  TimeOfDay selectedTimeEnd = TimeOfDay.now();
  TextEditingController addressController = TextEditingController();
  DateTime? selectedDateTime = DateTime.now();
  String uid = "";

  String getToken = "";
  List<String> selectedOptions = [];
  TextEditingController descriptionController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController otherOptionController = TextEditingController();
  TextEditingController PriceController = TextEditingController();
  final dateController = TextEditingController();
  XFile? requestImage;
// Buat controller untuk komponen waktu mulai
  final startTimeController = TextEditingController();
// Buat controller untuk komponen waktu akhir
  final endTimeController = TextEditingController();
  Position? _currentPosition;
  bool isDateSelected = false;

  bool showTextbox = false;
// implementasi Payment
  final email = FirebaseAuth.instance.currentUser?.email;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    getOptionData();
    getDatas();
  }

  @override
  void dispose() {
    super.dispose();
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

  Future<void> getOptionData() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection("input_option")
          .where('option_layanan', isEqualTo: widget.layanan)
          .get();

      setState(() {
        optionLayanan = querySnapshot.docs
            .map((doc) => List<String>.from(doc.get('input')))
            .expand((options) => options)
            .toList();
      });
    } catch (e) {
      print("Error fetching option data: $e");
    }
  }

  Future<void> _getCurrentLocation() async {
    PermissionStatus permissionStatus = await Permission.location.request();

    if (permissionStatus.isGranted) {
      try {
        final Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        final String address = await getAddressFromCoordinates(
            position.latitude, position.longitude);

        setState(() {
          _currentPosition = position;
          print(_currentPosition);
          locationController.text = address;
        });
      } catch (e) {
        print('Error getting location: $e');
      }
    } else if (permissionStatus.isDenied ||
        permissionStatus.isPermanentlyDenied) {
      bool isPermissionGranted = await openAppSettings();

      if (isPermissionGranted) {
        _getCurrentLocation();
      }
    }
  }

  Future<String> getAddressFromCoordinates(
      double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      if (placemarks != null && placemarks.isNotEmpty) {
        Placemark placemark = placemarks[0];
        String address =
            '${placemark.street}, ${placemark.subLocality}, ${placemark.locality}, ${placemark.postalCode}, ${placemark.country}';
        return address;
      }
    } catch (e) {
      print('Error getting address: $e');
    }
    return '';
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

  Future<void> _selectDateAndTime() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDateTime!,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != selectedDateTime) {
      setState(() {
        isDateSelected = true;
        selectedDateTime = picked;
      });
    }
  }

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

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      String? user = FirebaseAuth.instance.currentUser?.email;
      String other = otherOptionController.text ?? '';
      String address = locationController.text;
      DateTime dateTime = selectedDateTime!;
      String description = descriptionController.text;
      Position? location = _currentPosition;
      String start_time = startTimeController.text;
      String end_time = endTimeController.text;
      Timestamp timestamp = Timestamp.fromDate(dateTime);
      String price = PriceController.text;

      //database
      final CollectionReference requestCollection =
          FirebaseFirestore.instance.collection('request_handyman');
      //format date
      String today = DateFormat('ddMMyyyy').format(DateTime.now());

// Dapatkan nomor urut terakhir dari database
      QuerySnapshot lastOrder = await requestCollection
          .orderBy('created_date', descending: true)
          .orderBy('uid', descending: true)
          .limit(1)
          .get();

      // Simulasi nomor urut terakhir dari database
      BigInt lastOrderNumber = BigInt.zero;

      if (lastOrder.docs.isNotEmpty) {
        // Jika ada pemesanan sebelumnya, ambil nomor urutnya
        String uid = lastOrder.docs.first.get('uid').substring(
            15); // Ubah dari 8 menjadi 14 untuk mendapatkan nomor urut
        lastOrderNumber = BigInt.parse(uid);
      }

      // Ubah Timestamp menjadi DateTime untuk created_date
      DateTime? lastOrderDate = lastOrder.docs.isNotEmpty
          ? (lastOrder.docs.first.get('created_date') as Timestamp).toDate()
          : null;

      if (lastOrderDate != null && lastOrderDate.day == DateTime.now().day) {
        lastOrderNumber += BigInt.one; // Tambahkan satu digit terakhir
      } else {
        Timestamp timestamps = lastOrder.docs.first.get('created_date');

// Konversi Timestamp menjadi String dengan format yang diinginkan
        String formattedDate =
            DateFormat('yyyy-MM-dd').format(timestamps.toDate());

        lastOrderNumber = BigInt.from(
            int.parse(formattedDate.replaceAll('-', '')) * 100000 + 1);
      }

      // Gabungkan semuanya untuk membuat kode unik
      String uniqueCode =
          'ORDERLHABC${DateFormat('ddMMyyyy').format(DateTime.now())}${lastOrderNumber.toString().padLeft(5, '0')}';

      // Lakukan operasi form submission sesuai kebutuhan Anda
      Map<String, dynamic> requestData = {
        'uid': uniqueCode,
        'created_date': DateTime.now(),
        'tipe_pekerjaan': this.widget.layanan,
        'user': user,
        'status': "pending",
        'status_done': false,
        'address': address,
        'dateTime': selectedDateTime,
        'start_time': start_time,
        'price': price,
        'end_time': end_time,
        'otherOption': other ?? null,
        'description': description,
        'location': location != null
            ? GeoPoint(location.latitude, location.longitude)
            : null,
        'Option': selectedOptions,
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
          'Option_Name': selectedOptions.toList(),
          'dateTime': selectedDateTime.toString(),
          'start_time': start_time.toString(),
          'end_time': end_time.toString(),
          'otherOption': other.toString(),
          'description': description,
          'tipe_pekerjaan': this.widget.layanan,
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
        final responseData = jsonDecode(res.body);

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
        _formKey.currentState!.reset();
        setState(() {
          requestImage = null;
        });
      } else {
        print(res.body);
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Tidak bisa memesan'),
              content: Text('Mohon Menunggu, Pesanan Sedang Overload!.'),
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
    }
  }

  final _mapController = MapController();
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: (() => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const userHomepage(),
              ))),
        ),
        title: Text("${this.widget.layanan}"),
        centerTitle: true,
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
          child: FormBuilder(
              key: _formKey,
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.all(15),
                    child: FormBuilderTextField(
                      name: 'address',
                      controller: locationController,
                      decoration: InputDecoration(
                          labelText: 'Location',
                          labelStyle: TextStyle(fontSize: 20)),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                      ]),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(15),
                    height: 200,
                    child: _currentPosition != null
                        ? FlutterMap(
                            options: MapOptions(
                              center: LatLng(
                                _currentPosition!.latitude,
                                _currentPosition!.longitude,
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
                                        _currentPosition!.latitude,
                                        _currentPosition!.longitude,
                                      ),
                                      builder: (ctx) => Container(
                                              child: Icon(
                                            Icons.location_on,
                                            color: Colors.red,
                                            size: 40.0,
                                          )))
                                ],
                              )
                            ],
                          )
                        : Center(
                            child: CircularProgressIndicator(),
                          ),
                  ),
                  const SizedBox(height: 16.0),
                  Container(
                    margin: EdgeInsets.all(15),
                    child: FormBuilderDateTimePicker(
                      name: 'date',
                      decoration: InputDecoration(
                        labelText: 'Select Date',
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      initialValue: selectedDateTime,
                      inputType: InputType.date,
                      firstDate: DateTime.now().subtract(Duration(days: 2)),
                      lastDate: DateTime(2100),
                      controller: dateController,
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                      ]),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedDateTime = value;
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Container(
                      margin: EdgeInsets.all(15),
                      alignment: Alignment.centerLeft,
                      child: Text("Gambar (Optional)")),

                  // Tambahkan kode untuk mengunggah gambar
                  Container(
                    margin: EdgeInsets.all(15),
                    alignment: Alignment.centerLeft,
                    child: ElevatedButton(
                      onPressed: _getImage,
                      child: Text('Unggah Foto'),
                    ),
                  ),
                  if (requestImage != null)
                    Container(
                      margin: EdgeInsets.all(15),
                      child: Image.file(
                        File(requestImage!.path),
                        height: 100.0,
                        width: 100.0,
                      ),
                    ),
                  Row(
                    children: [
                      Container(
                        width: 150,
                        margin: EdgeInsets.all(15),
                        child: FormBuilderDateTimePicker(
                          name: 'start_time',
                          inputType: InputType.time,
                          initialValue: DateTime(
                            DateTime.now().year,
                            DateTime.now().month,
                            DateTime.now().day,
                            selectedTimeStart.hour,
                            selectedTimeStart.minute,
                          ),
                          format: DateFormat("HH:mm"),
                          controller: startTimeController,
                          decoration: InputDecoration(labelText: 'Start : '),
                        ),
                      ),
                      Container(
                        width: 150,
                        margin: EdgeInsets.all(15),
                        child: FormBuilderDateTimePicker(
                          name: 'end_time',
                          inputType: InputType.time,
                          initialValue: DateTime(
                            DateTime.now().year,
                            DateTime.now().month,
                            DateTime.now().day,
                            selectedTimeEnd.hour,
                            selectedTimeEnd.minute,
                          ),
                          format: DateFormat("HH:mm"),
                          controller: endTimeController,
                          decoration: InputDecoration(labelText: 'End : '),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.all(15),
                    child: FormBuilderTextField(
                      name: 'Description',
                      controller: descriptionController,
                      maxLines: 10,
                      decoration: InputDecoration(labelText: 'Description'),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                      ]),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(15),
                    child: FormBuilderTextField(
                      name: 'Price',
                      controller: PriceController,
                      decoration: InputDecoration(
                          labelText: 'Price', hintText: 'Minimal 50.000'),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                        FormBuilderValidators.numeric(),
                        FormBuilderValidators.min(50000)
                      ]),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Container(
                    margin: EdgeInsets.all(15),
                    child: FormBuilderCheckboxGroup(
                      name: 'options',
                      options: optionLayanan
                          .map(
                              (option) => FormBuilderFieldOption(value: option))
                          .toList(),
                      onChanged: (selected) {
                        if (selected != null) {
                          setState(() {
                            selectedOptions = List<String>.from(selected);
                            showTextbox =
                                selectedOptions.contains("Lain - Lainnya");
                            if (!showTextbox) {
                              otherOptionController.clear();
                            }
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  if (showTextbox)
                    Container(
                      margin: EdgeInsets.all(15),
                      child: FormBuilderTextField(
                        name: 'otherOption',
                        controller: otherOptionController,
                        decoration:
                            InputDecoration(labelText: 'lain - lain nya'),
                      ),
                    ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () async {
                      _submitForm();
                    },
                    child: const Text('Submit'),
                  ),
                  const SizedBox(height: 16.0),
                  SizedBox(height: 16.0),
                ],
              )),
        ),
      ),
    );
  }
}
