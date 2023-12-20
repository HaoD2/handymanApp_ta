import 'package:admin_flutter/constants/app_colors.dart';
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
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Column(
        children: [
          AppBar(
            // Tambahkan AppBar sebagai judul
            title: Text('Dashboard',
                style: TextStyle(fontSize: sizeDesktopTextContent)),
            backgroundColor: Colors.deepPurple.shade400,
            automaticallyImplyLeading: false, centerTitle: true,
            // Menonaktifkan tombol back
          ),
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 250,
                  color: Colors.deepPurple.shade400,
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(
                              "https://faces-img.xcdn.link/image-lorem-face-3430.jpg"),
                          radius: 15.0,
                        ),
                        title: Text('Welcome, Admin',
                            style: TextStyle(
                                color: Colors.black87,
                                fontSize: sizeDesktopTextContent)),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      ListTile(
                        leading: Icon(Icons.home, color: Colors.white),
                        title: Text('Home',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: sizeDesktopTextContent)),
                        onTap: () {
                          // Action for Home
                        },
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      ListTile(
                        leading: Icon(Icons.bar_chart, color: Colors.white),
                        title: Text('Laporan Insight',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: sizeDesktopTextContent)),
                        onTap: () {
                          // Action for Rapports
                        },
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      ListTile(
                        leading: Icon(Icons.settings, color: Colors.white),
                        title: Text('Settings',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: sizeDesktopTextContent)),
                        onTap: () {
                          // Action for Settings
                        },
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      ListTile(
                        leading:
                            Icon(Icons.logout_outlined, color: Colors.white),
                        title: Text('Logout',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: sizeDesktopTextContent)),
                        onTap: () {
                          // Action for Settings
                        },
                      ),
                    ],
                  ),
                ),
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
                                      DataCell(Text(index.toString())),
                                      DataCell(Text(data['name'] ?? '')),
                                      DataCell(Text(data['email'] ?? '')),
                                      DataCell(Text(data['skill'] ?? '')),
                                      DataCell(Row(
                                        children: [
                                          ButtonTheme(
                                            minWidth: 150.0,
                                            height: 100.0,
                                            child: ElevatedButton(
                                              onPressed: () {},
                                              child: Text("Detail"),
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          ButtonTheme(
                                            minWidth: 150.0,
                                            height: 100.0,
                                            child: ElevatedButton(
                                              onPressed: () {},
                                              child: Text("Submit"),
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          ButtonTheme(
                                            minWidth: 150.0,
                                            height: 100.0,
                                            child: ElevatedButton(
                                              onPressed: () {},
                                              child: Text("Tolak"),
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
                                      DataColumn(label: Text("No")),
                                      DataColumn(label: Text("Nama")),
                                      DataColumn(label: Text("Email")),
                                      DataColumn(label: Text("Skill")),
                                      DataColumn(label: Text("Action")),
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
