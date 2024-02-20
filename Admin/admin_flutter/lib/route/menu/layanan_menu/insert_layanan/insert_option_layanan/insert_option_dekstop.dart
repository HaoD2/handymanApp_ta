import 'package:admin_flutter/route/menu/layanan_menu/Dekstop_LM.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class InsertOptionDekstop extends StatefulWidget {
  final List<String> layanan;
  final nama_pekerjaan;
  final harga;
  const InsertOptionDekstop(
      {super.key, required this.layanan, this.nama_pekerjaan, this.harga});

  @override
  State<InsertOptionDekstop> createState() => _InsertOptionDekstopState();
}

class _InsertOptionDekstopState extends State<InsertOptionDekstop> {
  List<List<String>> textFieldValues = [[]];
  List<String> tempLayanan = [];

  void showSuccessAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Success"),
          content: Text("Pekerjaan telah ditambahkan"),
          actions: <Widget>[
            ElevatedButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                navigateToCRUDMenu(context); // Navigate to CRUDMenuDekstop
              },
            ),
          ],
        );
      },
    );
  }

// Function to navigate to CRUDMenuDekstop
  void navigateToCRUDMenu(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => CRUDMenuDekstop()),
    );
  }

// Function to insert data to Firestore
  Future<void> insertToFirestore(BuildContext context) async {
    CollectionReference layanan =
        FirebaseFirestore.instance.collection('pekerjaan');

    await layanan.add({
      'ImageName': "assets/images/pekerjaan_2.jpg",
      'title': this.widget.nama_pekerjaan,
      'price': this.widget.harga,
    });

    CollectionReference option_layanan =
        FirebaseFirestore.instance.collection('option_layanan');

    await option_layanan.add({
      'nama_layanan': this.widget.nama_pekerjaan,
      'option': tempLayanan,
    });

    List<Map<String, dynamic>> dataToSave = [];

    for (int index = 0; index < tempLayanan.length; index++) {
      List<String> inputs = [];
      for (int textFieldIndex = 0;
          textFieldIndex < textFieldValues[index].length;
          textFieldIndex++) {
        inputs.add(textFieldValues[index][textFieldIndex]);
      }

      Map<String, dynamic> data = {
        'input': inputs,
        'option_layanan': tempLayanan[
            index], // Setiap elemen dalam tempLayanan digunakan sebagai nama pekerjaan
      };

      dataToSave
          .add(data); // Tambahkan data ke list untuk disimpan ke Firestore
    }

    // After insertion is completed, show success alert dialog
    showSuccessAlertDialog(context);
  }

  @override
  void initState() {
    tempLayanan.addAll(this.widget.layanan);
    print(tempLayanan);
    textFieldValues = List.generate(tempLayanan.length, (_) => <String>[]);
    super.initState();
  }

  void addTextField(int index) {
    setState(() {
      textFieldValues[index].add('');
    });
  }

  // Menghapus textbox
  void removeTextField(int index, int textFieldIndex) {
    setState(() {
      textFieldValues[index].removeAt(textFieldIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dynamic Form'),
      ),
      body: ListView.builder(
        itemCount: tempLayanan.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.all(10.0),
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tempLayanan[index],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                    ),
                  ),
                  Column(
                    children: textFieldValues[index].map((value) {
                      int textFieldIndex =
                          textFieldValues[index].indexOf(value);
                      return Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              onChanged: (newValue) {
                                setState(() {
                                  textFieldValues[index][textFieldIndex] =
                                      newValue;
                                });
                              },
                              decoration: InputDecoration(
                                labelText: 'Textbox ${textFieldIndex + 1}',
                              ),
                              initialValue: value,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.remove_circle),
                            onPressed: () {
                              removeTextField(index, textFieldIndex);
                            },
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 10.0),
                  ElevatedButton(
                    onPressed: () {
                      addTextField(index);
                    },
                    child: Text('Tambah Textbox'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          insertToFirestore(context);
        },
        label: Text('Submit'),
        icon: Icon(Icons.cloud_upload),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
