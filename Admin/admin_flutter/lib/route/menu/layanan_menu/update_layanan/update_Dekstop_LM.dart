import 'package:admin_flutter/route/menu/layanan_menu/update_layanan/update_option_layanan/main_update_option.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UpdateLayananDesktop extends StatefulWidget {
  final namaPekerjaan;
  const UpdateLayananDesktop({Key? key, required this.namaPekerjaan})
      : super(key: key);

  @override
  State<UpdateLayananDesktop> createState() => _UpdateLayananDesktopState();
}

class _UpdateLayananDesktopState extends State<UpdateLayananDesktop> {
  late Stream<QuerySnapshot> _dataStream;

  @override
  void initState() {
    super.initState();
    _dataStream = FirebaseFirestore.instance
        .collection('option_layanan')
        .where('nama_layanan', isEqualTo: widget.namaPekerjaan)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pilih salah satu yang ingin diupdate'),
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
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
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
                                  builder: (context) => MainUpdateOption(
                                        nama_option: judul.toString(),
                                      )),
                            );
                          },
                        );
                      }).toList(),
                    );
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
