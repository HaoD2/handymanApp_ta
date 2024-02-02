import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:handyman_ta/pages/User/home.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class formRequestHandyman extends StatefulWidget {
  final email;
  const formRequestHandyman({super.key, this.email});
  static const routeName = '/User/profile/request_handyman';
  @override
  State<formRequestHandyman> createState() => _formRequestHandymanState();
}

class _formRequestHandymanState extends State<formRequestHandyman> {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();
  XFile? certificateImage;
  late String uid;

  Future<void> _submitForm() async {
    if (_formKey.currentState!.saveAndValidate()) {
      if (certificateImage != null) {
        final storageRef =
            FirebaseStorage.instance.ref().child('reqhandyman_$uid.png');

        final uploadTask = storageRef.putFile(File(certificateImage!.path));

        // Gunakan whenComplete untuk menunggu hingga pengunggahan selesai
        await uploadTask.whenComplete(() async {
          final String certificateImageUrl = await storageRef.getDownloadURL();

          // Simpan data ke Firestore
          final CollectionReference handymanReqCollection =
              FirebaseFirestore.instance.collection('handyman_req');

          await handymanReqCollection.add({
            'name': _formKey.currentState!.fields['name']?.value,
            'skill': _formKey.currentState!.fields['skill']?.value,
            'certificateImage': certificateImageUrl,
            // Tambahkan field lain sesuai kebutuhan
          });

          // Reset formulir
          _formKey.currentState!.reset();
          setState(() {
            certificateImage = null;
          });

          // Tampilkan pesan sukses
          Fluttertoast.showToast(
            msg: 'Permintaan Anda telah berhasil disimpan.',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor:
                Colors.red, // Atur warna latar belakang sesuai kebutuhan
            textColor: Colors.white, // Atur warna teks sesuai kebutuhan
          );
        });
      } else {
        // Tampilkan pesan jika gambar sertifikat tidak diunggah
        Fluttertoast.showToast(
          msg: 'Mohon unggah gambar sertifikat terlebih dahulu.',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor:
              Colors.red, // Atur warna latar belakang sesuai kebutuhan
          textColor: Colors.white, // Atur warna teks sesuai kebutuhan
        );
      }
    }
  }

  Future<void> _getImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        certificateImage = XFile(pickedFile.path);
      }
    });
  }

  Future<void> getDatas() async {
    final Querysnaps = await FirebaseFirestore.instance
        .collection("users")
        .where('email', isEqualTo: widget.email)
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

  @override
  void initState() {
    super.initState();
    getDatas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Form Permintaan Handyman'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: (() => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const userHomepage(),
              ))),
        ),
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FormBuilder(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FormBuilderTextField(
                  name: 'name',
                  decoration: InputDecoration(labelText: 'Nama'),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                  ]),
                ),
                FormBuilderTextField(
                  name: 'skill',
                  decoration: InputDecoration(labelText: 'Skill'),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                  ]),
                ),
                // Tambahkan kode untuk mengunggah gambar sertifikat
                ElevatedButton(
                  onPressed: _getImage,
                  child: Text('Unggah Sertifikat'),
                ),
                // Tambahkan widget untuk menampilkan gambar yang diunggah
                if (certificateImage != null)
                  Image.file(
                    File(certificateImage!.path),
                    height: 100.0,
                    width: 100.0,
                  ),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: Text('Kirim Permintaan'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
