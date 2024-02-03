import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:handyman_ta/pages/Model/kontak.dart';
import 'package:handyman_ta/pages/User/UI/chat_page.dart';

class Kontak_User extends StatefulWidget {
  final email;
  const Kontak_User({super.key, this.email});

  @override
  State<Kontak_User> createState() => _Kontak_UserState();
}

class _Kontak_UserState extends State<Kontak_User> {
  Future<List<kontak_user>> getDatas() async {
    kontakService kontak_userService = kontakService();
    List<kontak_user> dataList = await kontak_userService
        .getkontakListRand(FirebaseAuth.instance.currentUser!.email.toString());

    print(dataList.length);
    return dataList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Kontak'),
        ),
        body: Container(
          constraints: BoxConstraints(
            minWidth: 0,
            maxWidth: MediaQuery.of(context).size.width,
            maxHeight: 600,
          ),
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                'assets/images/home_decoration.png',
              ),
              fit: BoxFit.fill,
              alignment: Alignment.topCenter,
            ),
          ),
          child: FutureBuilder<List<kontak_user>>(
            future: getDatas(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              } else {
                List<kontak_user>? dataList = snapshot.data;
                if (dataList != null && dataList.isNotEmpty) {
                  return ListView.builder(
                    itemCount: dataList.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () async {
                          String uidPemesanan = dataList[index].uid_pemesanan;
                          // Periksa apakah ada permintaan dengan UID pemesanan yang sesuai
                          QuerySnapshot requestSnapshot =
                              await FirebaseFirestore.instance
                                  .collection('request_handyman')
                                  .where('uid', isEqualTo: uidPemesanan)
                                  .get();

                          if (requestSnapshot.docs.isNotEmpty) {
                            ListView.builder(
                              itemCount: requestSnapshot.docs.length,
                              itemBuilder: (context, index) {
                                var document = requestSnapshot.docs[index];
                                String pengirimHandyman =
                                    document['pengirimHandyman'];
                                String tipe_pekerjaan =
                                    document['tipe_pekerjaan'];
                                String uid_pemesanan =
                                    document['uid_pemesanan'];

                                return ListTile(
                                  title: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        pengirimHandyman,
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '$tipe_pekerjaan - $uid_pemesanan',
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  // You can add onTap or any other properties you want for the ListTile
                                );
                              },
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Tidak ada permintaan untuk $uidPemesanan',
                                ),
                              ),
                            );
                            // You might want to return something here or handle the case when there are no requests
                          }
                        },
                      );
                    },
                  );
                } else {
                  return Center(
                    child: Text('Tidak ada data kontak'),
                  );
                }
              }
            },
          ),
        ));
  }
}
                            // Navigator.of(context, rootNavigator: true)
                            //     .pushAndRemoveUntil(
                            //   MaterialPageRoute(
                            //     builder: (BuildContext context) {
                            //       return ChatPage(pengirimUser,
                            //           pengirimHandyman, uidPemesanan);
                            //     },
                            //   ),
                            //   (_) => false,
                            // );