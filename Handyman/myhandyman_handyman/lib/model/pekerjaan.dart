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
  final String price;
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
      required this.price,
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
        tipe_Pekerjaan: data['tipe_pekerjaan'] as String? ??
            "", // Mengatasi nilai null dengan default string kosong
        taken_by: data['taken_by'] as String? ??
            "", // Mengatasi nilai null dengan default string kosong
        user: data['user'] as String? ??
            "", // Mengatasi nilai null dengan default string kosong
        price: data['price'].toString(),
        uid: data['uid'] as String);
  }
}

class FirebaseDataService {
  List<Pekerjaan> requestData = [];
  final CollectionReference requestHandymanCollection =
      FirebaseFirestore.instance.collection('request_handyman');

  Future<List<Pekerjaan>> getRequestData(Position _currentPosition) async {
    List<Pekerjaan> filteredData = [];

    try {
      print("Fetching pending requests...");

      QuerySnapshot querySnapshot = await requestHandymanCollection
          .where('status', isEqualTo: 'pending')
          .get();

      print("Number of pending requests fetched: ${querySnapshot.docs.length}");

      for (var doc in querySnapshot.docs) {
        final pekerjaanData = doc.data() as Map<String, dynamic>;
        final pekerjaan = Pekerjaan.fromMap(doc.id, pekerjaanData);

        print("Processing job with ID: ${doc.id}");

        // Hitung jarak antara lokasi saat ini dengan lokasi pekerjaan
        double distance = Geolocator.distanceBetween(
              _currentPosition.latitude,
              _currentPosition.longitude,
              pekerjaan.location.latitude,
              pekerjaan.location.longitude,
            ) /
            1000; // convert meter to kilometer

        print("Distance to job (in km): $distance");

        // Filter pekerjaan yang berada dalam jarak 100 km dan belum melewati tenggat waktu
        bool withinDistance = distance <= 100;
        bool beforeDeadline =
            pekerjaan.datetime.toDate().isAfter(DateTime.now());

        print("Within distance (<=100 km): $withinDistance");
        print("Before deadline: $beforeDeadline");
        print("Current time: ${DateTime.now()}");
        print("Job deadline: ${pekerjaan.datetime.toDate()}");

        if (withinDistance && beforeDeadline) {
          print("Job meets criteria and is added to filtered list.");
          filteredData.add(pekerjaan);
        }
      }

      // Urutkan hasil filter berdasarkan jarak terkecil
      print("Sorting filtered jobs by distance...");
      filteredData.sort((a, b) {
        double distanceA = Geolocator.distanceBetween(
              _currentPosition.latitude,
              _currentPosition.longitude,
              a.location.latitude,
              a.location.longitude,
            ) /
            1000;
        double distanceB = Geolocator.distanceBetween(
              _currentPosition.latitude,
              _currentPosition.longitude,
              b.location.latitude,
              b.location.longitude,
            ) /
            1000;
        return distanceA.compareTo(distanceB);
      });
      print("Sorted jobs by distance.");
    } catch (e) {
      print("Error fetching data: $e");
    }

    print("Total filtered jobs returned: ${filteredData.length}");
    return filteredData;
  }

  Future<List<Pekerjaan>> filterDataSearchdanDistance(
      double maxDistance, String keyword, Position _currentPosition) async {
    List<Pekerjaan> allData = await getRequestData(_currentPosition);

    List<Pekerjaan> filteredData = [];

    if (maxDistance > 0 && keyword.isNotEmpty) {
      // Jika menggunakan keduanya: distance dan search
      if (_currentPosition != null) {
        allData.forEach((item) {
          double calculatedDistance = Geolocator.distanceBetween(
                _currentPosition.latitude,
                _currentPosition.longitude,
                item.location.latitude,
                item.location.longitude,
              ) /
              1000;

          String lowercaseDescription = item.description.toLowerCase();
          String lowercaseTipePekerjaan = item.tipe_Pekerjaan.toLowerCase();
          String lowercaseKeyword = keyword.toLowerCase();

          if (calculatedDistance <= maxDistance &&
              (lowercaseDescription.contains(lowercaseKeyword) ||
                  lowercaseTipePekerjaan.contains(lowercaseKeyword))) {
            filteredData.add(item);
          }
        });
      }
    } else if (maxDistance > 0) {
      // Jika hanya menggunakan distance
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
    } else if (keyword.isNotEmpty) {
      // Jika hanya menggunakan search
      allData.forEach((item) {
        String lowercaseDescription = item.description.toLowerCase();
        String lowercaseTipePekerjaan = item.tipe_Pekerjaan.toLowerCase();
        String lowercaseKeyword = keyword.toLowerCase();

        if (lowercaseDescription.contains(lowercaseKeyword) ||
            lowercaseTipePekerjaan.contains(lowercaseKeyword)) {
          filteredData.add(item);
        }
      });
    } else {
      // Jika tidak ada filter
      filteredData = allData;
    }

    return filteredData;
  }

  Future<List<Pekerjaan>> fetchAndFilterData(
      double maxDistance, Position _currentPosition) async {
    List<Pekerjaan> allData = await getRequestData(_currentPosition);

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
          print('filtered');
          print(maxDistance);
          filteredData.add(item);
        }
      });
    }

    // Kembalikan data yang telah difilter
    return filteredData;
  }

  Future<List<Pekerjaan>> searchPekerjaan(
      String keyword, Position _currentPosition) async {
    List<Pekerjaan> allData = await getRequestData(_currentPosition);

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
