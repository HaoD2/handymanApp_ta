import 'package:cloud_firestore/cloud_firestore.dart';

class Message_Log {
  final String pengirimEmail;
  final String penerimaEmail;
  final String sent;
  final String isiPesan;
  final bool isDone;
  final DateTime waktu;
  final String uid_pemesanan;

  Message_Log(
      {required this.pengirimEmail,
      required this.penerimaEmail,
      required this.sent,
      required this.isiPesan,
      required this.isDone,
      required this.waktu,
      required this.uid_pemesanan});

  Map<String, dynamic> toMap() {
    return {
      'pengirimEmail': pengirimEmail,
      'penerimaEmail': penerimaEmail,
      'sent': sent,
      'isiPesan': isiPesan,
      'isDone': true,
      'waktu': waktu,
      'uid_pemesanan': uid_pemesanan,
    };
  }
}
