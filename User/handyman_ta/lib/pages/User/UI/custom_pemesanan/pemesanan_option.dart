import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:handyman_ta/pages/Model/pekerjaan.dart';
import 'package:handyman_ta/pages/User/UI/custom_pemesanan/detail_custom.dart';
import 'package:handyman_ta/pages/User/home.dart';

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

  TextEditingController detailPemesananControlller = TextEditingController();
  TextEditingController waktuController = TextEditingController();
  TextEditingController handymanController = TextEditingController();
  TextEditingController lokasiController = TextEditingController();
  int _currentPageIndex = 0;

  late AnimationController animationController;
  @override
  void initState() {
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
                                    waktu_pekerjaan: waktuController.text);
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
                  FormBuilderTextField(
                    name: 'waktu_pekerjaan_text',
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                    ]),
                    decoration: InputDecoration(
                      labelText: 'Waktu Pekerjaan ?',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    controller: waktuController,
                    minLines: 3,
                    maxLines: null,
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
                  FormBuilderTextField(
                    name: 'lokasi_text',
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                    ]),
                    decoration: InputDecoration(
                      labelText: 'Tempat Lokasi  ?',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    controller: lokasiController,
                    minLines: 3,
                    maxLines: null,
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
