import 'package:admin_flutter/route/menu/layanan_menu/insert_layanan/insert_option_layanan/main_insert_option.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: insertLayananDekstop(),
    );
  }
}

class insertLayananDekstop extends StatefulWidget {
  @override
  _insertLayananDekstopState createState() => _insertLayananDekstopState();
}

class _insertLayananDekstopState extends State<insertLayananDekstop> {
  List<TextEditingController> controllers1 = [TextEditingController()];

  late String Pekerjaan;
  late String price;
  TextEditingController nama_pekerjaan = new TextEditingController();
  TextEditingController harga =
      new TextEditingController(); // List untuk controller
  List<String> textList = [''];

  @override
  void dispose() {
    // Hapus controller saat widget di dispose
    for (var controller1 in controllers1) {
      controller1.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Form Layanan Insert'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: nama_pekerjaan,
              decoration: InputDecoration(
                labelText: 'Nama Pekerjaan',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                Pekerjaan = value;
              },
            ),
          ),
          ListView.builder(
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
                              labelText: 'Pekerjaan ${index + 1}',
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
                                final newController = TextEditingController();
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
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MainInsertOption(
                            layanan: textList.toList(),
                            nama_pekerjaan: Pekerjaan,
                          )));
            },
            child: Text('Submit'),
          ),
        ],
      ),
    );
  }
}
