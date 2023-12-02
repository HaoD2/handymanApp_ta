import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/src/datetime_picker_theme.dart'
    as custom;
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:handyman_ta/pages/Model/pekerjaan.dart';
import 'package:handyman_ta/pages/User/UI/custom_pemesanan/detail_custom.dart';
import 'package:handyman_ta/pages/User/home.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';

class PemesananOption extends StatefulWidget {
  final dynamic layanan;

  const PemesananOption({Key? key, this.layanan}) : super(key: key);

  @override
  State<PemesananOption> createState() => _PemesananOptionState();
}

class _PemesananOptionState extends State<PemesananOption>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormBuilderState> _formKeyPage1 =
      GlobalKey<FormBuilderState>();
  final GlobalKey<FormBuilderState> _formKeyPage2 =
      GlobalKey<FormBuilderState>();
  final GlobalKey<FormBuilderState> _formKeyPage3 =
      GlobalKey<FormBuilderState>();
  final GlobalKey<FormBuilderState> _formKeyPage4 =
      GlobalKey<FormBuilderState>();
  Position? _currentPosition;

  TimeOfDay selectedTimeEnd = TimeOfDay.now();
  TimeOfDay selectedTimeStart = TimeOfDay.now();
  TextEditingController detailPemesananControlller = TextEditingController();
// Buat controller untuk komponen waktu mulai
  final startTimeController = TextEditingController();
// Buat controller untuk komponen waktu akhir
  final endTimeController = TextEditingController();
  TextEditingController handymanController = TextEditingController();
  TextEditingController lokasiController = TextEditingController();
  int _currentPageIndex = 0;

  late AnimationController animationController;
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
          lokasiController.text = address;
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

  @override
  void initState() {
    // if (_currentPageIndex == 3) {
    //   _getCurrentLocation();
    // }
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 100), // Adjust duration as needed
    );
    animationController.forward();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Custom Pemesanan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            if (_currentPageIndex > 0) {
              _delayedBack();
              print(_currentPageIndex);
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const userHomepage(),
                ),
              );
            }
          },
        ),
      ),
      body: Stack(
        children: [
          // Bagian latar belakang dari gambar di folder 'img'
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/home_decoration.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Bagian latar belakang kuning
          Positioned.fill(
            child: Container(
              color: Colors.yellow.withOpacity(0.6),
            ),
          ),
          // Listbox dan textbox yang tersembunyi
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedSwitcher(
                    duration: Duration(milliseconds: 100),
                    child: _getPage(_currentPageIndex),
                  ),
                  SizedBox(height: 20), // Jarak antara text field dan button
                  Align(
                    alignment: Alignment.bottomRight,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_currentPageIndex < 3) {
                          setState(() {
                            _currentPageIndex++;
                          });
                          print(_currentPageIndex);
                        } else {
                          // Lakukan sesuatu ketika tombol Next di halaman terakhir ditekan

                          Navigator.of(context, rootNavigator: true)
                              .pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (BuildContext context) {
                                return detail_custom(
                                    deskripsi: detailPemesananControlller.text,
                                    alamat: lokasiController.text,
                                    require_handyman: handymanController.text,
                                    start_time: startTimeController.text,
                                    end_time: endTimeController.text);
                              },
                            ),
                            (_) => false,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 24,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(_currentPageIndex < 3 ? "Next" : "Submit"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return FadeTransition(
          opacity: Tween<double>(begin: 0, end: 1).animate(
              CurvedAnimation(parent: animationController, curve: Curves.ease)),
          key: UniqueKey(),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            child: FormBuilder(
              key: _formKeyPage1,
              child: Column(
                children: [
                  FormBuilderTextField(
                    name: 'detail_pemesanan_text',
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                    ]),
                    decoration: InputDecoration(
                      labelText: 'Detail Pekerjaan ?',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    controller: detailPemesananControlller,
                    minLines: 3,
                    maxLines: null,
                  ),
                ],
              ),
            ),
          ),
        );

      case 1:
        // Widget B
        return FadeTransition(
          opacity: Tween<double>(begin: 0, end: 1).animate(
              CurvedAnimation(parent: animationController, curve: Curves.ease)),
          key: UniqueKey(),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            child: FormBuilder(
              key: _formKeyPage2,
              child: Column(
                children: [
                  FormBuilderTextField(
                    name: 'handymanrequire_text',
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                    ]),
                    decoration: InputDecoration(
                      labelText: 'Pekerjaan ini membutuhkan berapa Handyman ?',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    controller: handymanController,
                    minLines: 3,
                    maxLines: null,
                  ),
                ],
              ),
            ),
          ),
        );
      case 2:
        // Widget C
        return FadeTransition(
          opacity: Tween<double>(begin: 0, end: 1).animate(
              CurvedAnimation(parent: animationController, curve: Curves.ease)),
          key: UniqueKey(),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            child: FormBuilder(
              key: _formKeyPage3,
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 75,
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
                        width: 75,
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
                ],
              ),
            ),
          ),
        );
      case 3:
        // Widget D
        return FadeTransition(
          opacity: Tween<double>(begin: 0, end: 1).animate(
              CurvedAnimation(parent: animationController, curve: Curves.ease)),
          key: UniqueKey(),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            child: FormBuilder(
              key: _formKeyPage4,
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.all(15),
                    child: FormBuilderTextField(
                      name: 'address',
                      controller: lokasiController,
                      decoration: InputDecoration(labelText: 'Location'),
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
                ],
              ),
            ),
          ),
        );
      default:
        return Container();
    }
  }

  void _delayedBack() {
    if (mounted) {
      setState(() {
        _currentPageIndex--;
      });
    }
  }

  void main() {
    runApp(MaterialApp(
      home: PemesananOption(),
    ));
  }
}
