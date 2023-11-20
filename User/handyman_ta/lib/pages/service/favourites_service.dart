import 'package:cloud_firestore/cloud_firestore.dart';

class FavouriteUserService {
  final String email;
  final Map<String, bool> like;

  FavouriteUserService({
    required this.email,
    required this.like,
  });

  factory FavouriteUserService.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      // Jika data kosong, mengembalikan nilai default atau kosong
      return FavouriteUserService(
        email: '',
        like: {
          'Layanan Jasa Titip': false,
          'Layanan Pembersihan': false,
          'Layanan Perbaikan': false,
        },
      );
    }

    return FavouriteUserService(
      email: data['email'] ?? '',
      like: {
        'Layanan Jasa Titip': data['like']['Layanan Jasa Titip'] ?? false,
        'Layanan Pembersihan': data['like']['Layanan Pembersihan'] ?? false,
        'Layanan Perbaikan': data['like']['Layanan Perbaikan'] ?? false,
      },
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'like': {
        'Layanan Jasa Titip': like['Layanan Jasa Titip'],
        'Layanan Pembersihan': like['Layanan Pembersihan'],
        'Layanan Perbaikan': like['Layanan Perbaikan'],
      },
    };
  }
}
