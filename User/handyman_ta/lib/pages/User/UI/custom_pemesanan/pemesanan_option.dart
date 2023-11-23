import 'package:flutter/material.dart';
import 'package:handyman_ta/pages/Model/pekerjaan.dart';

class PemesananOption extends StatefulWidget {
  final dynamic layanan;

  const PemesananOption({Key? key, this.layanan}) : super(key: key);

  @override
  State<PemesananOption> createState() => _PemesananOptionState();
}

class _PemesananOptionState extends State<PemesananOption> {
  List<Pekerjaan>? dataList;
  bool isTextBoxVisible = false;
  Pekerjaan? selectedPekerjaan;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    PekerjaanService pekerjaanService = PekerjaanService();
    List<Pekerjaan> pekerjaanList = await pekerjaanService.getPekerjaanList();

    setState(() {
      dataList = pekerjaanList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Background Image dan Listbox'),
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
          Container(
            color: Colors.yellow.withOpacity(0.6),
          ),
          // Listbox dan textbox yang tersembunyi
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ListBox (dropdown)
                if (dataList != null)
                  DropdownButton<Pekerjaan>(
                    value: selectedPekerjaan,
                    items: dataList?.map((Pekerjaan pekerjaan) {
                      return DropdownMenuItem<Pekerjaan>(
                        value: pekerjaan,
                        child: Text(pekerjaan.title),
                      );
                    }).toList(),
                    onChanged: (Pekerjaan? newValue) {
                      setState(() {
                        selectedPekerjaan = newValue;
                      });
                      // Tambahkan logika penanganan perubahan pada dropdown di sini
                      if (newValue != null) {
                        print('Pekerjaan yang dipilih: ${newValue.title}');
                      }
                    },
                  ),
                Visibility(
                  visible: isTextBoxVisible,
                  child: Container(
                    width: 200,
                    height: 50,
                    color: Colors.white, // Ubah warna sesuai kebutuhan
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Masukkan teks',
                        border: OutlineInputBorder(),
                      ),
                      // Jika ingin menambahkan logika atau aksi saat teks berubah, gunakan onChanged
                      // onChanged: (text) {
                      //   // Lakukan sesuatu dengan teks yang dimasukkan
                      // },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: PemesananOption(),
  ));
}
