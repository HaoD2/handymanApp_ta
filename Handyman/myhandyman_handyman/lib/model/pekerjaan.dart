import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class Pekerjaan {
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
  final String user;

  Pekerjaan({
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
  });

  factory Pekerjaan.fromMap(Map<String, dynamic> data) {
    return Pekerjaan(
      optionMenu:
          (data['Option'] as List?)?.map((e) => e as String).toList() ?? [],
      address: data['address'] as String,
      datetime: data['dateTime'] as Timestamp,
      description: data['description'] as String,
      startTime: data['start_time'] as String,
      endTime: data['end_time'] as String,
      image: data['image'] ?? "",
      location: data['location'] as GeoPoint,
      otherOption: data['other_option'] ?? "",
      status: data['status'] ?? "",
      tipe_Pekerjaan: data["tipe_Pekerjaan"],
      user: data['user'] as String,
    );
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
        requestData.add(Pekerjaan.fromMap(doc.data() as Map<String, dynamic>));
      });
    } catch (e) {
      print("Gagal mengambil data: $e");
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
}
