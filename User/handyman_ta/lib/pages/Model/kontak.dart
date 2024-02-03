import 'package:cloud_firestore/cloud_firestore.dart';

class kontak_user {
  final String pengirimUser;
  final String pengirimHandyman;
  final String uid_pemesanan;
  final bool isDoneHandyman;
  final bool isDoneUser;
  final bool isRatingDoneUser;
  final bool isRatingDoneHandyman;
  final bool isReportDoneUser;
  final bool isReportDoneHandyman;

  kontak_user(
      {required this.pengirimUser,
      required this.pengirimHandyman,
      required this.uid_pemesanan,
      required this.isDoneUser,
      required this.isDoneHandyman,
      required this.isRatingDoneUser,
      required this.isRatingDoneHandyman,
      required this.isReportDoneUser,
      required this.isReportDoneHandyman});

  factory kontak_user.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    String pengirimUser = data['pengirimUser'] ?? '';
    String pengirimHandyman = data['pengirimHandyman'] ?? '';
    String uidPemesanan = data['uid_pemesanan'] ?? '';
    bool isDoneUser = data['isDoneUser'] ?? false;
    bool isDoneHandyman = data['isDoneHandyman'] ?? false;
    bool isRatingDoneUser = data['isRatingDoneUser'] ?? false;
    bool isRatingDoneHandyman = data['isRatingDoneHandyman'] ?? false;
    bool isReportDoneUser = data['isReportDoneUser'] ?? false;
    bool isReportDoneHandyman = data['isReportDoneHandyman'] ?? false;

    return kontak_user(
      pengirimUser: pengirimUser,
      pengirimHandyman: pengirimHandyman,
      uid_pemesanan: uidPemesanan,
      isDoneUser: isDoneUser,
      isDoneHandyman: isDoneHandyman,
      isRatingDoneUser: isRatingDoneUser,
      isRatingDoneHandyman: isRatingDoneHandyman,
      isReportDoneUser: isReportDoneUser,
      isReportDoneHandyman: isReportDoneHandyman,
    );
  }
}

class kontakService {
  final CollectionReference KontakCollection =
      FirebaseFirestore.instance.collection('kontak');
  Future<List<kontak_user>> getkontakListRand(String email) async {
    List<kontak_user> kontakList = [];
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('kontak') // Ganti dengan nama koleksi yang sesuai
          .where('pengirimUser', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        print("ada");
        // Jika data ditemukan
        kontakList.addAll(querySnapshot.docs
            .map((doc) => kontak_user.fromFirestore(doc))
            .toList());
      } else {
        print('Tidak ada kontak dengan pengirim email $email');
      }
    } catch (error) {
      print('Terjadi kesalahan: $error');
    }
    return kontakList;
  }
}
