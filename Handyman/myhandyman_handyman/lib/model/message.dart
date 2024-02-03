import 'package:cloud_firestore/cloud_firestore.dart';

class Message_Log {
  final String pengirimUser;
  final String pengirimHandyman;
  final String sent;
  final String isiPesan;
  final bool isDone;
  final DateTime waktu;
  final String uid_pemesanan;

  Message_Log(
      {required this.pengirimUser,
      required this.pengirimHandyman,
      required this.sent,
      required this.isiPesan,
      required this.isDone,
      required this.waktu,
      required this.uid_pemesanan});

  Map<String, dynamic> toMap() {
    return {
      'pengirimUser': pengirimUser,
      'pengirimHandyman': pengirimHandyman,
      'sent': sent,
      'isiPesan': isiPesan,
      'isDone': true,
      'waktu': waktu,
      'uid_pemesanan': uid_pemesanan,
    };
  }
}
