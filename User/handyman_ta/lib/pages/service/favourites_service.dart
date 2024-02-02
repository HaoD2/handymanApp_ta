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
        like: {},
      );
    }

    Map<String, bool> likeData = {};

    if (data['like'] != null) {
      // Jika ada data di dalam field 'like', membangun likeData secara dinamis
      for (String key in data['like'].keys) {
        likeData[key] = data['like'][key] ?? false;
      }
    }

    return FavouriteUserService(
      email: data['email'] ?? '',
      like: likeData,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'like': like,
    };
  }
}
