import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:handyman_ta/pages/User/home.dart';
import 'package:intl/intl.dart';

class showAll_list extends StatefulWidget {
  final email;
  const showAll_list({super.key, this.email});
  static const routeName = '/User/activity_list';
  @override
  State<showAll_list> createState() => _showAll_listState();
}

class _showAll_listState extends State<showAll_list> {
  final CollectionReference _request_handyman =
      FirebaseFirestore.instance.collection('request_handyman');

  final currencyFormatter = NumberFormat('#,##0.00', 'ID');
  getData() async {
    QuerySnapshot querySnapshot = await _request_handyman.get();

    final allData = querySnapshot.docs.map((doc) => doc.data()).toList();

    return allData;
  }

  Card buildCard(String title, String Desc, String image, int harga,
      String status, DateTime Tanggal) {
    return Card(
        elevation: 4.0,
        child: Column(
          children: [
            ListTile(
              title: Text(title),
              subtitle: Text("Rp. ${currencyFormatter.format(harga)}"),
            ),
            SizedBox(
              height: 200.0,
              child: Image.asset(
                image.toString(),
                fit: BoxFit.cover,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16.0),
              alignment: Alignment.centerLeft,
              child: Text(status),
            ),
            ButtonBar(
              children: [
                if (status == "Sedang Dikerjakan")
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(
                      // <-- Icon
                      Icons.message_sharp,
                      size: 24.0,
                    ),
                    label: const Text('Message Handyman'), // <-- Text
                  ),
              ],
            ),
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const userHomepage(),
              )),
        ),
        title: const Text("Details"),
        centerTitle: true,
      ),
      body: SafeArea(
          child: Column(
        children: [
          Expanded(
              child: FutureBuilder<dynamic>(
            initialData: const {},
            future: getData(),
            builder: (context, AsyncSnapshot<dynamic> snapshot) {
              if (!snapshot.hasData ||
                  snapshot.data == null ||
                  snapshot.data.isEmpty ||
                  snapshot.hasError) {
                if (snapshot.data == {}) {
                  return Container();
                } else {
                  // print("masuk");

                  return SizedBox(
                    height: MediaQuery.of(context).size.height - 200,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
              }
              print("email ini ${widget.email}");

              return SizedBox(
                height: MediaQuery.of(context).size.height - 200,
                child: ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (_, int index) {
                    return Container(
                        child: buildCard(
                            snapshot.data[index]["nama_layanan"],
                            snapshot.data[index]["nama_layanan"],
                            'assets/images/home_decoration.png',
                            snapshot.data[index]["harga"],
                            snapshot.data[index]["status"],
                            DateTime.parse(snapshot.data[index]
                                    ["request_tanggal"]
                                .toDate()
                                .toString())));
                  },
                ),
              );
            },
          )),
        ],
      )),
    );
  }
}
