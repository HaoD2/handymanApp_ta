import 'package:admin_flutter/constants/app_colors.dart';
import 'package:admin_flutter/navigation/navigation_header/nav_responsive.dart';
import 'package:admin_flutter/navigation/navigation_side/nav_responsive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DashboardDekstop extends StatefulWidget {
  const DashboardDekstop({super.key});

  @override
  State<DashboardDekstop> createState() => _DashboardDekstopState();
}

class _DashboardDekstopState extends State<DashboardDekstop> {
  late Stream<QuerySnapshot> _dataStream;
  @override
  void initState() {
    super.initState();
    _dataStream = FirebaseFirestore.instance
        .collection('handyman_req_forms')
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

                                    return DataRow(cells: [
                                      DataCell(Text(
                                        index.toString(),
                                        style: TextStyle(
                                            fontSize:
                                                sizeTableDesktopTextContent),
                                      )),
                                      DataCell(Text(
                                        data['name'] ?? '',
                                        style: TextStyle(
                                            fontSize:
                                                sizeTableDesktopTextContent),
                                      )),
                                      DataCell(Text(
                                        data['email'] ?? '',
                                        style: TextStyle(
                                            fontSize:
                                                sizeTableDesktopTextContent),
                                      )),
                                      DataCell(Text(
                                        data['skill'] ?? '',
                                        style: TextStyle(
                                            fontSize:
                                                sizeTableDesktopTextContent),
                                      )),
                                      DataCell(Row(
                                        children: [
                                          ButtonTheme(
                                            minWidth: 150.0,
                                            height: 100.0,
                                            child: ElevatedButton(
                                              onPressed: () {},
                                              child: Text(
                                                "Detail",
                                                style: TextStyle(
                                                    fontSize:
                                                        sizeTableDesktopTextContent),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          ButtonTheme(
                                            minWidth: 150.0,
                                            height: 100.0,
                                            child: ElevatedButton(
                                              onPressed: () {},
                                              child: Text(
                                                "Submit",
                                                style: TextStyle(
                                                    fontSize:
                                                        sizeTableDesktopTextContent),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          ButtonTheme(
                                            minWidth: 150.0,
                                            height: 100.0,
                                            child: ElevatedButton(
                                              onPressed: () {},
                                              child: Text(
                                                "Tolak",
                                                style: TextStyle(
                                                    fontSize:
                                                        sizeTableDesktopTextContent),
                                              ),
                                            ),
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
                                          label: Text("Email",
                                              style: TextStyle(
                                                  fontSize:
                                                      sizeTableDesktopTextTitle))),
                                      DataColumn(
                                          label: Text("Skill",
                                              style: TextStyle(
                                                  fontSize:
                                                      sizeTableDesktopTextTitle))),
                                      DataColumn(
                                          label: Text("Action",
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
