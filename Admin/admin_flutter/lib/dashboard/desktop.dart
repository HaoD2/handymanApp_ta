import 'package:flutter/material.dart';

class DashboardDekstop extends StatefulWidget {
  const DashboardDekstop({super.key});

  @override
  State<DashboardDekstop> createState() => _DashboardDekstopState();
}

class _DashboardDekstopState extends State<DashboardDekstop> {
  @override
  Widget build(BuildContext context) {
    bool isMenuOpen = false;
    return Scaffold(
      body: Row(
        children: [
          //Let's start by adding the Navigation Rail
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
                      style: TextStyle(color: Colors.black87)),
                ),
                ListTile(
                  leading: Icon(Icons.home, color: Colors.white),
                  title: Text('Home', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    // Action for Home
                  },
                ),
                ListTile(
                  leading: Icon(Icons.bar_chart, color: Colors.white),
                  title: Text('Laporan Insight',
                      style: TextStyle(color: Colors.white)),
                  onTap: () {
                    // Action for Rapports
                  },
                ),
                ListTile(
                  leading: Icon(Icons.settings, color: Colors.white),
                  title:
                      Text('Settings', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    // Action for Settings
                  },
                ),
                ListTile(
                  leading: Icon(Icons.logout_outlined, color: Colors.white),
                  title: Text('Logout', style: TextStyle(color: Colors.white)),
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
                        DataTable(
                            headingRowColor: MaterialStateProperty.resolveWith(
                                (states) => Colors.grey.shade200),
                            columns: [
                              DataColumn(label: Text("ID")),
                              DataColumn(label: Text("Article Title")),
                              DataColumn(label: Text("Creation Date")),
                              DataColumn(label: Text("Views")),
                              DataColumn(label: Text("Comments")),
                            ],
                            rows: [
                              DataRow(cells: [
                                DataCell(Text("0")),
                                DataCell(
                                    Text("How to build a Flutter Web App")),
                                DataCell(Text("${DateTime.now()}")),
                                DataCell(Text("2.3K Views")),
                                DataCell(Text("102Comments")),
                              ]),
                              DataRow(cells: [
                                DataCell(Text("1")),
                                DataCell(
                                    Text("How to build a Flutter Mobile App")),
                                DataCell(Text("${DateTime.now()}")),
                                DataCell(Text("21.3K Views")),
                                DataCell(Text("1020Comments")),
                              ]),
                              DataRow(cells: [
                                DataCell(Text("2")),
                                DataCell(
                                    Text("Flutter for your first project")),
                                DataCell(Text("${DateTime.now()}")),
                                DataCell(Text("2.3M Views")),
                                DataCell(Text("10K Comments")),
                              ]),
                            ]),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.add),
        backgroundColor: Colors.deepPurple.shade400,
      ),
    );
  }
}
