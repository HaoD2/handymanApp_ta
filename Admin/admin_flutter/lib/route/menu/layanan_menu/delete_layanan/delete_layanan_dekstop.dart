import 'package:admin_flutter/route/menu/layanan_menu/delete_layanan/delete_option_layanan/main_option_delete.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DeleteLayananDekstop extends StatefulWidget {
  final nama_pekerjaan;
  const DeleteLayananDekstop({super.key, this.nama_pekerjaan});

  @override
  State<DeleteLayananDekstop> createState() => _DeleteLayananDekstopState();
}

class _DeleteLayananDekstopState extends State<DeleteLayananDekstop> {
  late Stream<QuerySnapshot> _dataStream;

  Future<void> DeleteToFirestore() async {
    CollectionReference layanan =
        FirebaseFirestore.instance.collection('pekerjaan');

    CollectionReference option_layanan =
        FirebaseFirestore.instance.collection('option_layanan');

    CollectionReference input_option =
        FirebaseFirestore.instance.collection('input_option');

    // Hapus dokumen di 'pekerjaan' dengan kondisi nama_pekerjaan == widget.nama_pekerjaan
    await layanan
        .where('title', isEqualTo: widget.nama_pekerjaan)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        doc.reference.delete();
      });
    });

    var querySnapshot1 = await option_layanan
        .where('nama_layanan', isEqualTo: widget.nama_pekerjaan)
        .get();

    // Menyimpan data dari dokumen yang akan dihapus ke dalam sebuah array
    List<Map<String, dynamic>> dataToDelete = [];

    querySnapshot1.docs.forEach((doc) {
      var data = doc.data() as Map<String, dynamic>;
      dataToDelete.add(data);
    });

    // Hapus dokumen di 'option_layanan' dengan kondisi nama_pekerjaan == widget.nama_pekerjaan
    await option_layanan
        .where('nama_layanan', isEqualTo: widget.nama_pekerjaan)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        doc.reference.delete();
      });
    });

    // Hapus dokumen di 'input_option' dengan kondisi nama_pekerjaan == widget.nama_pekerjaan
    for (var data in dataToDelete) {
      if (data['option'] != null) {
        List<dynamic> options = data['option'];
        print(dataToDelete);
        for (var option in options) {
          if (option != null) {
            await input_option
                .where('option_layanan', isEqualTo: option)
                .get()
                .then((querySnapshot) {
              querySnapshot.docs.forEach((doc) {
                doc.reference.delete();
              });
            });
          }
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _dataStream = FirebaseFirestore.instance
        .collection('option_layanan')
        .where('nama_layanan', isEqualTo: widget.nama_pekerjaan)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pilih salah satu yang ingin Didelete'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: _dataStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('Tidak ada data.'));
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.docs.length +
                      1, // Menambah 1 untuk menu "Hapus layanan ini"
                  itemBuilder: (context, index) {
                    if (index == snapshot.data!.docs.length) {
                      // Mengecek jika ini adalah indeks terakhir
                      return Container(
                        color: Colors.red,
                        child: ListTile(
                          title: Text("Hapus layanan ini"),
                          onTap: () {
                            DeleteToFirestore();
                          },
                        ),
                      );
                    } else {
                      var document = snapshot.data!.docs[index];
                      var data = document.data() as Map<String, dynamic>;
                      var judulList = data['option'] as List<dynamic>;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: judulList.map((judul) {
                          return ListTile(
                            title: Text(judul.toString()),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => OptionMenuDelete(
                                          nama_pekerjaan: judul.toString(),
                                        )),
                              );
                            },
                          );
                        }).toList(),
                      );
                    }
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
