import 'package:cloud_firestore/cloud_firestore.dart';

class kontak_user {
  final String pengirimEmail;
  final String penerimaEmail;
  final String uid_pemesanan;
  final bool isDone;
  final bool isDoneUser;
  final bool isRatingDone;
  final bool isReportDone;

  kontak_user(
      {required this.pengirimEmail,
      required this.penerimaEmail,
      required this.uid_pemesanan,
      required this.isDone,
      required this.isDoneUser,
      required this.isRatingDone,
      required this.isReportDone});

  Map<String, dynamic> toMap() {
    return {
      'pengirimEmail': pengirimEmail,
      'penerimaEmail': penerimaEmail,
      'uid_pemesanan': uid_pemesanan,
      'isDone': isDone,
      'isDoneUser': isDoneUser,
      'isRatingDone': isRatingDone,
      'isReportDone': isReportDone
    };
  }
}
