import 'package:admin_flutter/constants/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UpdateOptionDekstop extends StatefulWidget {
  final nama_option;
  const UpdateOptionDekstop({super.key, this.nama_option});

  @override
  State<UpdateOptionDekstop> createState() => _UpdateOptionDekstopState();
}

class _UpdateOptionDekstopState extends State<UpdateOptionDekstop> {
  late List<String> currentOptions = []; // Menyimpan pilihan saat ini
  late TextEditingController indexController = TextEditingController();
  late TextEditingController newOptionController = TextEditingController();
  List<String> textList = [''];

  List<TextEditingController> controllers1 = [TextEditingController()];

  void dispose() {
    // Hapus controller saat widget di dispose
    for (var controller1 in controllers1) {
      controller1.dispose();
    }

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _fetchOptions();
  }

  void _fetchOptions() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('input_option')
        .where('option_layanan', isEqualTo: this.widget.nama_option)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      setState(() {
        currentOptions = List<String>.from(querySnapshot.docs.first['input']);
      });
    }
  }

  Future<void> addDataToFirestore() async {
    // Fetch the document with the specified option_layanan
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('input_option')
        .where('option_layanan', isEqualTo: this.widget.nama_option)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // Document(s) with the specified option_layanan found
      querySnapshot.docs.forEach((doc) {
        List<dynamic> existingData = doc['input'];
        Set<String> existingSet = Set.from(existingData);

        // Check for duplicates in the existing data
        bool hasDuplicates = false;
        for (String element in textList) {
          if (existingSet.contains(element)) {
            hasDuplicates = true;
            break;
          }
        }

        if (!hasDuplicates) {
          // No duplicates found, proceed to update Firestore document
          List<String> updatedData = List.from(existingData)..addAll(textList);

          // Update Firestore document with the updated 'input' array
          FirebaseFirestore.instance
              .collection('input_option')
              .doc(doc.id)
              .update({'input': updatedData})
              .then((_) => print('Data added successfully!'))
              .catchError((error) => print('Failed to add data: $error'));
        } else {
          print('Data insertion failed. Duplicates found in newData.');
        }
      });
    } else {
      print('Document with  not found.');
    }
  }

  void _updateOption(int index, String newValue) async {
    currentOptions[index] = newValue;

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('input_option')
        .where('option_layanan', isEqualTo: widget.nama_option)
        .get();

    querySnapshot.docs.forEach((doc) async {
      await FirebaseFirestore.instance
          .collection('input_option')
          .doc(doc.id)
          .update({'input': currentOptions});
    });

    _fetchOptions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Option'),
      ),
      body: Container(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              child: Expanded(
                child: ListView.builder(
                  itemCount: currentOptions.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      title: Text('Opsi $index'),
                      subtitle: TextFormField(
                        initialValue: currentOptions[index],
                        onChanged: (newValue) {
                          _updateOption(index, newValue);
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
            Container(
              width: sizeDesktopTextContent * 24,
              padding: EdgeInsets.all(10),
              child: ButtonTheme(
                minWidth: 150.0,
                child: ElevatedButton(
                  onPressed: () {},
                  child: Text("Submit",
                      style: TextStyle(fontSize: sizeTableDesktopTextContent)),
                ),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.black, // Warna garis bawah
                    width: 1.0, // Lebar garis bawah
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(
                    bottom: 4.0), // Atur jarak antara teks dan garis
                child: Text(
                  "Inputan Baru",
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: controllers1.length,
                itemBuilder: (BuildContext context, int index) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: controllers1[index],
                                decoration: InputDecoration(
                                  labelText: 'Opsi Baru ${index + 1}',
                                  border: OutlineInputBorder(),
                                ),
                                onChanged: (value) {
                                  textList[index] = value;
                                },
                              ),
                            ),
                            if (index !=
                                0) // Hanya tampilkan tombol remove jika index bukan 0
                              IconButton(
                                icon: Icon(Icons.remove),
                                onPressed: () {
                                  setState(() {
                                    textList.removeAt(index);
                                    controllers1[index].dispose();
                                    controllers1.removeAt(index);
                                  });
                                },
                              ),
                            if (index ==
                                0) // Tampilkan tombol add jika index adalah 0
                              IconButton(
                                icon: Icon(Icons.add),
                                onPressed: () {
                                  setState(() {
                                    final newController =
                                        TextEditingController();
                                    controllers1.add(newController);
                                    textList.add('');
                                  });
                                },
                              ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            Container(
              width: sizeDesktopTextContent * 24,
              padding: EdgeInsets.all(10),
              child: ButtonTheme(
                minWidth: 150.0,
                child: ElevatedButton(
                  onPressed: () {
                    addDataToFirestore();
                  },
                  child: Text("Submit",
                      style: TextStyle(fontSize: sizeTableDesktopTextContent)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
