import 'package:admin_flutter/constants/app_colors.dart';
import 'package:admin_flutter/navigation/navigation_header/nav_responsive.dart';
import 'package:admin_flutter/navigation/navigation_side/nav_responsive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ListingDekstop extends StatefulWidget {
  const ListingDekstop({super.key});

  @override
  State<ListingDekstop> createState() => _ListingDekstopState();
}

class _ListingDekstopState extends State<ListingDekstop> {
  late Stream<QuerySnapshot> _dataStream;

  void initState() {
    super.initState();
    _dataStream = FirebaseFirestore.instance
        .collection('request_handyman')
        .snapshots(); // Mengambil stream dari koleksi 'handyman_req_forms'
  }

  @override
  Widget build(BuildContext context) {
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
                    padding: EdgeInsets.all(60.0),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Listing Handyman'),
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

                                    return DataRow(cells: [
                                      DataCell(Text(
                                        index.toString(),
                                        style: TextStyle(
                                            fontSize:
                                                sizeTableDesktopTextContent),
                                      )),
                                      DataCell(Text(
                                        data['user'] ?? '',
                                        style: TextStyle(
                                            fontSize:
                                                sizeTableDesktopTextContent),
                                      )),
                                      DataCell(Text(
                                        data['description'] ?? '',
                                        style: TextStyle(
                                            fontSize:
                                                sizeTableDesktopTextContent),
                                      )),
                                      DataCell(Text(
                                        data['tipe_pekerjaan'] ?? '',
                                        style: TextStyle(
                                            fontSize:
                                                sizeTableDesktopTextContent),
                                      )),
                                      DataCell(Text(
                                        data['status'] ?? '',
                                        style: TextStyle(
                                            fontSize:
                                                sizeTableDesktopTextContent),
                                      )),
                                    ]);
                                  }).toList();

                                  return DataTable(
                                    headingRowColor:
                                        MaterialStateProperty.resolveWith(
                                            (states) => Colors.grey.shade200),
                                    columns: [
                                      DataColumn(
                                          label: Text(
                                        "No",
                                        style: TextStyle(
                                            fontSize:
                                                sizeTableDesktopTextTitle),
                                      )),
                                      DataColumn(
                                          label: Text("Nama",
                                              style: TextStyle(
                                                  fontSize:
                                                      sizeTableDesktopTextTitle))),
                                      DataColumn(
                                          label: Text("Description",
                                              style: TextStyle(
                                                  fontSize:
                                                      sizeTableDesktopTextTitle))),
                                      DataColumn(
                                          label: Text("Tipe Pekerjaan",
                                              style: TextStyle(
                                                  fontSize:
                                                      sizeTableDesktopTextTitle))),
                                      DataColumn(
                                          label: Text("Status",
                                              style: TextStyle(
                                                  fontSize:
                                                      sizeTableDesktopTextTitle))),
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
        ],
      ),
    );
  }
}
