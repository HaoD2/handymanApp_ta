import 'package:cloud_firestore/cloud_firestore.dart';

class Message_Log {
  final String pengirimUID;
  final String penerimaUID;
  final String isiPesan;
  final bool isDone;
  final String waktu;

  Message_Log({
    required this.pengirimUID,
    required this.penerimaUID,
    required this.isiPesan,
    required this.isDone,
    required this.waktu,
  });

  Map<String, dynamic> toMap() {
    return {
      'pengirimUID': pengirimUID,
      'penerimaUID': penerimaUID,
      'isiPesan': isiPesan,
      'isDone': true,
      'waktu': waktu,
    };
  }
}
