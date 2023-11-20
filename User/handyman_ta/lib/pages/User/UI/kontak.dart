import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:handyman_ta/pages/User/UI/chat_page.dart';
import 'package:handyman_ta/pages/User/home.dart';
import 'package:handyman_ta/pages/loginpage.dart';
import 'package:handyman_ta/pages/service/authservice.dart';

class messageUser extends StatefulWidget {
  final email;
  const messageUser({super.key, this.email});

  @override
  State<messageUser> createState() => _messageUserState();
}

class _messageUserState extends State<messageUser> {
  final AuthService _authService = AuthService();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: _authService.getCurrentUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else {
          if (snapshot.hasData) {
            return Container(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('kontak')
                    .where('penerimaEmail',
                        isEqualTo: FirebaseAuth.instance.currentUser?.email)
                    .where('isDone', isEqualTo: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return CircularProgressIndicator();
                  }
                  var contacts = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: contacts.length,
                    itemBuilder: (context, index) {
                      var contact = contacts[index];
                      var penerimaUID = contact['penerimaEmail'];
                      var pengirimUID = contact['pengirimEmail'];
                      var uid_pemesanan = contact['uid_pemesanan'];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundImage:
                                  AssetImage('assets/images/icon_profile.png'),
                            )
                          ],
                        ),
                        title: Text(
                          pengirimUID,
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                        onTap: () {
                          Navigator.of(context, rootNavigator: true)
                              .pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (BuildContext context) {
                                return ChatPage(
                                    penerimaUID, pengirimUID, uid_pemesanan);
                              },
                            ),
                            (_) => false,
                          );
                        },
                      );
                    },
                  );
                },
              ),
            );
          } else {
            return Stack(
              children: [
                Container(
                  constraints: BoxConstraints(
                    minWidth: 0,
                    maxWidth: MediaQuery.of(context).size.width,
                    maxHeight: 175,
                  ),
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/home_decoration.png'),
                      fit: BoxFit.fill,
                      alignment: Alignment.topCenter,
                    ),
                  ),
                ),
                // Overlay gelap
                Container(
                  color: Colors.black.withOpacity(0.5),
                ),
                // Kotak putih dengan judul "Login Required"
                Positioned.fill(
                  child: Center(
                    child: Container(
                      width:
                          300, // Sesuaikan lebar kotak putih sesuai kebutuhan
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Login Required',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context, rootNavigator: true)
                                  .pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (BuildContext context) {
                                    return LoginPage();
                                  },
                                ),
                                (_) => false,
                              );
                            },
                            child: Text('Login'),
                          ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context, rootNavigator: true)
                                  .pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (BuildContext context) {
                                    return LoginPage();
                                  },
                                ),
                                (_) => false,
                              );
                            },
                            child: Text('Sign Up'),
                          ),
                          SizedBox(height: 16),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context, rootNavigator: true)
                                  .pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (BuildContext context) {
                                    return userHomepage();
                                  },
                                ),
                                (_) => false,
                              ); // Tutup dialog jika tombol Cancel ditekan
                            },
                            child: Text('Cancel'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
        }
      },
    );
  }
}
