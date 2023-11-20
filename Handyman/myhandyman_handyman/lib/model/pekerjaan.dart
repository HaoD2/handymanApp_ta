import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class Pekerjaan {
  final String id;
  final List<String> optionMenu;
  final String address;
  final Timestamp datetime;
  final String description;
  final String startTime;
  final String endTime;
  final String image;
  final GeoPoint location;
  final String otherOption;
  final String status;
  final String tipe_Pekerjaan;
  final String taken_by;
  final String user;
  final uid;

  Pekerjaan(
      {required this.id,
      required this.optionMenu,
      required this.address,
      required this.datetime,
      required this.description,
      required this.startTime,
      required this.endTime,
      required this.image,
      required this.location,
      required this.otherOption,
      required this.status,
      required this.tipe_Pekerjaan,
      required this.user,
      required this.taken_by,
      required this.uid});

  factory Pekerjaan.fromMap(String id, Map<String, dynamic> data) {
    return Pekerjaan(
        id: id, // Menambahkan ID dokumen
        optionMenu:
            (data['Option'] as List?)?.map((e) => e as String).toList() ?? [],
        address: data['address'] as String? ??
            "", // Mengatasi nilai null dengan default string kosong
        datetime: data['dateTime'] as Timestamp? ??
            Timestamp
                .now(), // Mengatasi nilai null dengan default Timestamp saat ini
        description: data['description'] as String? ??
            "", // Mengatasi nilai null dengan default string kosong
        startTime: data['start_time'] as String? ??
            "", // Mengatasi nilai null dengan default string kosong
        endTime: data['end_time'] as String? ??
            "", // Mengatasi nilai null dengan default string kosong
        image: data['image'] as String? ??
            "", // Mengatasi nilai null dengan default string kosong
        location: data['location'] as GeoPoint? ??
            GeoPoint(0.0,
                0.0), // Mengatasi nilai null dengan default GeoPoint (0, 0)
        otherOption: data['other_option'] as String? ??
            "", // Mengatasi nilai null dengan default string kosong
        status: data['status'] as String? ??
            "", // Mengatasi nilai null dengan default string kosong
        tipe_Pekerjaan: data['tipe_Pekerjaan'] as String? ??
            "", // Mengatasi nilai null dengan default string kosong
        taken_by: data['taken_by'] as String? ??
            "", // Mengatasi nilai null dengan default string kosong
        user: data['user'] as String? ??
            "", // Mengatasi nilai null dengan default string kosong
        uid: data['uid'] as String);
  }
}

class FirebaseDataService {
  List<Pekerjaan> requestData = [];
  final CollectionReference requestHandymanCollection =
      FirebaseFirestore.instance.collection('request_handyman');

  Future<List<Pekerjaan>> getRequestData() async {
    try {
      QuerySnapshot querySnapshot = await requestHandymanCollection.get();
      requestData.clear();
      querySnapshot.docs.forEach((doc) {
        final pekerjaanData = doc.data() as Map<String, dynamic>;
        final pekerjaan =
            Pekerjaan.fromMap(doc.id, pekerjaanData); // Menambahkan ID dokumen
        requestData.add(pekerjaan);
      });
    } catch (e) {
      print(e.toString());
    }

    return requestData;
  }

  Future<List<Pekerjaan>> fetchAndFilterData(
      double maxDistance, Position _currentPosition) async {
    List<Pekerjaan> allData = await getRequestData();

    List<Pekerjaan> filteredData = [];
    if (_currentPosition != null) {
      allData.forEach((item) {
        double calculatedDistance = Geolocator.distanceBetween(
              _currentPosition.latitude,
              _currentPosition.longitude,
              item.location.latitude,
              item.location.longitude,
            ) /
            1000;

        if (calculatedDistance <= maxDistance) {
          filteredData.add(item);
        }
      });
    }

    // Kembalikan data yang telah difilter
    return filteredData;
  }

  Future<List<Pekerjaan>> searchPekerjaan(
    String keyword,
  ) async {
    List<Pekerjaan> allData = await getRequestData();

    List<Pekerjaan> searchfilteredData = [];

    allData.forEach((pekerjaan) {
      String lowercaseDescription = pekerjaan.description.toLowerCase();
      String lowercaseTipePekerjaan = pekerjaan.tipe_Pekerjaan.toLowerCase();
      String lowercaseKeyword = keyword.toLowerCase();

      if (lowercaseDescription.contains(keyword.toLowerCase()) ||
          lowercaseTipePekerjaan.contains(keyword.toLowerCase())) {
        searchfilteredData.add(pekerjaan);
      }
    });

    return searchfilteredData;
  }

  Future<Pekerjaan?> getPekerjaanById(String id) async {
    try {
      DocumentSnapshot pekerjaanDoc =
          await requestHandymanCollection.doc(id).get();
      if (pekerjaanDoc.exists) {
        final pekerjaanData = pekerjaanDoc.data() as Map<String, dynamic>;
        return Pekerjaan.fromMap(id, pekerjaanData);
      }
    } catch (e) {
      print("Gagal mengambil data: $e");
    }

    return null; // Mengembalikan null jika data tidak ditemukan atau ada kesalahan
  }
}
