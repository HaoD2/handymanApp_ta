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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';

final uniqueKeyProvider = StateProvider.autoDispose<int>((ref) {
  // Gunakan fungsi Random() atau UUID untuk membuat kunci yang unik
  return UniqueKey().hashCode; // Contoh menggunakan hashCode dari UniqueKey
});
final currentPageProvider = StateProvider<int>((ref) => 0);

class PemesananOption extends ConsumerStatefulWidget {
  final dynamic layanan;

  const PemesananOption({Key? key, this.layanan}) : super(key: key);
  @override
  ConsumerState<PemesananOption> createState() => _PemesananOptionState();
}

class _PemesananOptionState extends ConsumerState<PemesananOption>
    with SingleTickerProviderStateMixin {
  Position? _currentPosition;
  FocusNode _textFieldFocusNode = FocusNode();
  TimeOfDay selectedTimeEnd = TimeOfDay.now();
  TimeOfDay selectedTimeStart = TimeOfDay.now();
  TextEditingController detailPemesananControlller = TextEditingController();
// Buat controller untuk komponen waktu mulai
  final startTimeController = TextEditingController();
// Buat controller untuk komponen waktu akhir
  final endTimeController = TextEditingController();
  TextEditingController handymanController = TextEditingController();
  TextEditingController lokasiController = TextEditingController();
  final TextEditingController _minController = TextEditingController();
  final TextEditingController _maxController = TextEditingController();
  int _currentPageIndex = 0;
//form handler
  GlobalKey<FormBuilderState> formKey1 = GlobalKey<FormBuilderState>();
  GlobalKey<FormBuilderState> formKey2 = GlobalKey<FormBuilderState>();
  GlobalKey<FormBuilderState> formKey3 = GlobalKey<FormBuilderState>();
  GlobalKey<FormBuilderState> formKey4 = GlobalKey<FormBuilderState>();
  GlobalKey<FormBuilderState> formKey5 = GlobalKey<FormBuilderState>();
  final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID', symbol: 'Rp'); // Formatter mata uang
  //RangeValues
  double _minValue = 0;
  double _maxValue = 10000000; // Nilai maksimum 10 juta
  final FocusNode _minFocus = FocusNode();
  final FocusNode _maxFocus = FocusNode();

  RangeValues _currentRange = const RangeValues(0, 100000000);

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
    _getCurrentLocation();
    super.initState();

    animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 100), // Adjust duration as needed
    );
    animationController.forward();
  }

  @override
  void dispose() {
    _minFocus.dispose();
    _maxFocus.dispose();
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uniqueKey = ref.watch(uniqueKeyProvider);
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
                    child: _getPage(_currentPageIndex, uniqueKey),
                  ),
                  SizedBox(height: 20), // Jarak antara text field dan button
                  Align(
                    alignment: Alignment.bottomRight,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_currentPageIndex < 4) {
                          setState(() {
                            _currentPageIndex++;
                          });
                          print(animationController.isAnimating);
                          print(_currentPageIndex);
                        } else {
                          // Lakukan sesuatu ketika tombol Next di halaman terakhir ditekan
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) {
                                return detail_custom(
                                  deskripsi: detailPemesananControlller.text,
                                  alamat: lokasiController.text,
                                  require_handyman: handymanController.text,
                                  start_time: startTimeController.text,
                                  end_time: endTimeController.text,
                                  min: _minController.text,
                                  max: _maxController.text,
                                );
                              },
                            ),
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
                      child: Text(_currentPageIndex < 4 ? "Next" : "Submit"),
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

  Widget _getPage(int index, int uniqueKey) {
    switch (index) {
      case 0:
        return FadeTransition(
          opacity: Tween<double>(begin: 0, end: 1).animate(
              CurvedAnimation(parent: animationController, curve: Curves.ease)),
          key: ValueKey<int>(uniqueKey),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            child: FormBuilder(
              key: formKey1,
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
          key: ValueKey<int>(uniqueKey),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            child: FormBuilder(
              key: formKey2,
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
          key: ValueKey<int>(uniqueKey),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            child: FormBuilder(
              key: formKey3,
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
        // Widget C
        return FadeTransition(
          opacity: Tween<double>(begin: 0, end: 1).animate(
            CurvedAnimation(parent: animationController, curve: Curves.ease),
          ),
          key: ValueKey<int>(uniqueKey),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            child: FormBuilder(
              key: formKey4,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(labelText: 'Min Value'),
                          controller: _minController,
                          onChanged: (value) {
                            int min = int.tryParse(value) ?? 0;
                            int max = int.tryParse(_maxController.text) ?? 0;

                            if (min > max) {
                              min = max;
                              _minController.text = min.toString();
                            }

                            if (min > 10000000) {
                              min =
                                  10000000; // Batasi nilai minimum menjadi 10 juta
                              _minController.text = min.toString();
                            }

                            setState(() {
                              _minValue = min.toDouble();
                            });
                          },
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(labelText: 'Max Value'),
                          controller: _maxController,
                          onChanged: (value) {
                            int min = int.tryParse(_minController.text) ?? 0;
                            int max = int.tryParse(value) ?? 0;

                            if (max < min) {
                              max = min;
                              _maxController.text = max.toString();
                            }

                            if (max > 10000000) {
                              max =
                                  10000000; // Batasi nilai maksimum menjadi 10 juta
                              _maxController.text = max.toString();
                            }

                            setState(() {
                              _maxValue = max.toDouble();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  RangeSlider(
                    values: RangeValues(_minValue, _maxValue),
                    min: 0,
                    max: 10000000, // Ubah nilai maksimum menjadi 10 juta
                    divisions: 100,
                    labels: RangeLabels(
                      currencyFormatter.format(_minValue),
                      currencyFormatter.format(_maxValue),
                    ),
                    onChanged: (RangeValues values) {
                      setState(() {
                        _minValue = values.start;
                        _maxValue = values.end;
                        _minController.text = _minValue.toInt().toString();
                        _maxController.text = _maxValue.toInt().toString();
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      case 4:
        // Widget D
        return FadeTransition(
          opacity: Tween<double>(begin: 0, end: 1).animate(
              CurvedAnimation(parent: animationController, curve: Curves.ease)),
          key: ValueKey<int>(uniqueKey),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            child: FormBuilder(
              key: formKey5,
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
