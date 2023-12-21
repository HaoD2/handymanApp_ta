import 'package:admin_flutter/constants/app_colors.dart';
import 'package:admin_flutter/navigation/navigation_header/nav_responsive.dart';
import 'package:admin_flutter/navigation/navigation_side/nav_responsive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LaporanPelanggaranTablet extends StatefulWidget {
  const LaporanPelanggaranTablet({super.key});

  @override
  State<LaporanPelanggaranTablet> createState() =>
      _LaporanPelanggaranTabletState();
}

class _LaporanPelanggaranTabletState extends State<LaporanPelanggaranTablet> {
  late Stream<QuerySnapshot> _dataStream;
  @override
  void initState() {
    super.initState();
    _dataStream = FirebaseFirestore.instance
        .collection('pelanggaran_user')
        .snapshots(); // Mengambil stream dari koleksi 'handyman_req_forms'
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Column(
        children: [
          NavigationHeaderResponsive(),
          Expanded(
            child: Row(
              children: [
                NavigationSideResponsive(),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Request Handyman'),
                          SizedBox(
                            height: 24,
                          ),
                          //Now let's add the Table
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              StreamBuilder<QuerySnapshot>(
                                stream: _dataStream,
                                builder: (context, snapshot) {
                                  if (snapshot.hasError) {
                                    return Center(
                                        child: Text(
                                            'Error: ${snapshot.error.toString()}'));
                                  }

                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Center(
                                        child: CircularProgressIndicator());
                                  }

                                  List<DocumentSnapshot> documents =
                                      snapshot.data!.docs;

                                  List<DataRow> rows =
                                      documents.asMap().entries.map((entry) {
                                    Map<String, dynamic> data = entry.value
                                        .data() as Map<String, dynamic>;
                                    int index = entry.key + 1;
                                    Timestamp t = data['tanggal_pelanggaran'];
                                    DateTime date = t.toDate();
                                    Map<String, dynamic> options =
                                        data['option_keterangan'];
                                    return DataRow(cells: [
                                      DataCell(Text(index.toString(),
                                          style: TextStyle(
                                              fontSize:
                                                  sizeTableTabletTextContent))),
                                      DataCell(Text(data['nama_pelapor'] ?? '',
                                          style: TextStyle(
                                              fontSize:
                                                  sizeTableTabletTextContent))),
                                      DataCell(Text(data['nama_terlapor'] ?? '',
                                          style: TextStyle(
                                              fontSize:
                                                  sizeTableTabletTextContent))),
                                      DataCell(Text(date.toString())),
                                      DataCell(Row(
                                        children: [
                                          IconButton(
                                            onPressed: () {
                                              // Aksi untuk tombol Detail
                                            },
                                            icon: Icon(Icons
                                                .details), // Ganti dengan ikon yang sesuai
                                          ),
                                          SizedBox(width: 8),
                                          IconButton(
                                            onPressed: () {
                                              // Aksi untuk tombol Submit
                                            },
                                            icon: Icon(Icons
                                                .send), // Ganti dengan ikon yang sesuai
                                          ),
                                          SizedBox(width: 8),
                                          IconButton(
                                            onPressed: () {
                                              // Aksi untuk tombol Tolak
                                            },
                                            icon: Icon(Icons
                                                .close), // Ganti dengan ikon yang sesuai
                                          ),
                                        ],
                                      )),
                                    ]);
                                  }).toList();

                                  return DataTable(
                                    headingRowColor:
                                        MaterialStateProperty.resolveWith(
                                            (states) => Colors.grey.shade200),
                                    columns: [
                                      DataColumn(
                                          label: Text("No",
                                              style: TextStyle(
                                                  fontSize:
                                                      sizeTableTabletTextTitle))),
                                      DataColumn(
                                          label: Text("Nama Pelapor",
                                              style: TextStyle(
                                                  fontSize:
                                                      sizeTableTabletTextTitle))),
                                      DataColumn(
                                          label: Text("Nama Terlapor",
                                              style: TextStyle(
                                                  fontSize:
                                                      sizeTableTabletTextTitle))),
                                      DataColumn(
                                          label: Text("tanggal_pelanggaran",
                                              style: TextStyle(
                                                  fontSize:
                                                      sizeTableTabletTextTitle))),
                                      DataColumn(
                                          label: Text("Action",
                                              style: TextStyle(
                                                  fontSize:
                                                      sizeTableTabletTextTitle))),
                                    ],
                                    rows: rows,
                                  );
                                },
                              ),

                              //Now let's set the pagination
                              SizedBox(
                                height: 40.0,
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Text(screenWidth.toString()),
        ],
      ),
    );
  }
}
