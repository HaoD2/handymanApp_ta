import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OptionDeleteDekstop extends StatefulWidget {
  final namaInput;
  const OptionDeleteDekstop({Key? key, this.namaInput}) : super(key: key);

  @override
  State<OptionDeleteDekstop> createState() => _OptionDeleteDekstopState();
}

class _OptionDeleteDekstopState extends State<OptionDeleteDekstop> {
  late List<String> currentOptions = [];

  @override
  void initState() {
    super.initState();
    _fetchOptions();
  }

  void _fetchOptions() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('input_option')
        .where('option_layanan', isEqualTo: widget.namaInput)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      setState(() {
        currentOptions = List<String>.from(querySnapshot.docs.first['input']);
      });
    }
  }

  Future<void> deleteOption(int index) async {
    // Ambil dokumen pertama dari hasil query sebagai referensi
    var documentSnapshot = await FirebaseFirestore.instance
        .collection('input_option')
        .where('option_layanan', isEqualTo: widget.namaInput)
        .get()
        .then((querySnapshot) => querySnapshot.docs.first);

    if (documentSnapshot.exists) {
      // Hapus elemen di indeks tertentu dari array 'input'
      List<dynamic> inputArray = documentSnapshot['input'];
      inputArray.removeAt(index);

      // Perbarui data di Firestore
      await documentSnapshot.reference.update({
        'input': inputArray,
      });

      // Perbarui tampilan lokal
      setState(() {
        currentOptions = List<String>.from(inputArray);
      });
      _fetchOptions();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Data Options'),
      ),
      body: DataTable(
        columns: [
          DataColumn(label: Text('No')),
          DataColumn(label: Text('Input')),
          DataColumn(label: Text('Detail')),
        ],
        rows: List<DataRow>.generate(
          currentOptions.length,
          (index) => DataRow(
            cells: [
              DataCell(Text((index + 1).toString())),
              DataCell(Text(currentOptions[index])),
              DataCell(
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Delete Data'),
                          content: Text(
                              'Are you sure you want to delete this data?'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () async {
                                await deleteOption(index);
                                Navigator.of(context).pop();
                              },
                              child: Text('Delete'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
