import 'package:admin_flutter/constants/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DashboardTablet extends StatefulWidget {
  const DashboardTablet({super.key});

  @override
  State<DashboardTablet> createState() => _DashboardTabletState();
}

class _DashboardTabletState extends State<DashboardTablet> {
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
                style: TextStyle(fontSize: sizeTabletTextTitle)),
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
                                fontSize: sizeTabletTextTitle)),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      ListTile(
                        leading: Icon(Icons.home, color: Colors.white),
                        title: Text('Home',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: sizeTabletTextTitle)),
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
                                fontSize: sizeTabletTextTitle)),
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
                                fontSize: sizeTabletTextTitle)),
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
                                fontSize: sizeTabletTextTitle)),
                        onTap: () {
                          // Action for Settings
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: 20.0, right: 20.0),
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
                                      DataCell(Text(index
                                          .toString())), // Jika Anda ingin menambahkan nomor urutan, sesuaikan di sini
                                      DataCell(Text(data['name'] ?? '',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize:
                                                  sizeTabletTextContent))),
                                      DataCell(Text(data['email'] ?? '',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize:
                                                  sizeTabletTextContent))),
                                      DataCell(Text(data['skill'] ?? '',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize:
                                                  sizeTabletTextContent))),
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
                                                  color: Colors.black,
                                                  fontSize:
                                                      sizeTabletTextTitle))),
                                      DataColumn(
                                          label: Text("Nama",
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize:
                                                      sizeTabletTextTitle))),
                                      DataColumn(
                                          label: Text("Email",
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize:
                                                      sizeTabletTextTitle))),
                                      DataColumn(
                                          label: Text("Skill",
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize:
                                                      sizeTabletTextContent))),
                                      DataColumn(
                                          label: Text("Action",
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize:
                                                      sizeTabletTextContent))),
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
