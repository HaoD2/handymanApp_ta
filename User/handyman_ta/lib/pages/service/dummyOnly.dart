import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class RequestHandymanService {
  static final CollectionReference _requests =
      FirebaseFirestore.instance.collection('request_handyman');
  static final Random _random = Random();

  // Data dummy user dan taken_by
  static const List<String> users = [
    'jeffreyadrian27@gmail.com',
    'kevinrennzx@gmail.com',
    'alyssareynolds1808@gmail.com',
    'stevenliem377@gmail.com',
    'limanhangel@gmail.com',
    'tristanfairuzaelfath@gmail.com'
  ];

  static const List<String> takenByOptions = [
    'kevinotchoa@gmail.com',
    'scottlangantman1808@gmail.com',
    'hanihanihani1808@gmail.com',
    '70hncs@gmail.com'
  ];

  static const List<String> statusOptions = ['cancel', 'pending', 'success'];

  // Data tipe pekerjaan dan opsi
  static final Map<String, List<String>> jobOptions = {
    "Pembersihan Ruang": [
      "Pembersihan Ruang",
      "Pembersihan Kebun",
      "Pembersihan Kamar"
    ],
    "Perbaikan Otomotif": ["Perbaikan Motor", "Perbaikan Mobil"],
    "Perbaikan Barang Elektronik": [
      "Perbaikan AC",
      "Perbaikan TV/Digital",
      "Perbaikan Audio"
    ],
  };

  // Generate unique UID based on index and date
  static String _generateUid(int index, DateTime date) {
    return 'ORDERLH${date.day.toString().padLeft(2, '0')}${date.month.toString().padLeft(2, '0')}${date.year}${index.toString().padLeft(6, '0')}';
  }

  // Generate random GeoPoint within bounds
  static GeoPoint _generateGeoPoint() {
    double latitude = 7.250445 + _random.nextDouble() * (7.350445 - 7.250445);
    double longitude =
        112.718845 + _random.nextDouble() * (112.768845 - 112.718845);
    return GeoPoint(latitude, longitude);
  }

  // Generate random date within the month
  static DateTime _generateRandomDate(int month) {
    return DateTime(2024, month, _random.nextInt(28) + 1,
        _random.nextInt(8) + 9, _random.nextInt(59));
  }

  // Generate a single data entry
  static Map<String, dynamic> _generateData(int index, int month) {
    // Generate random type and option
    String tipePekerjaan =
        jobOptions.keys.elementAt(_random.nextInt(jobOptions.keys.length));
    List<String> options = jobOptions[tipePekerjaan]!;
    String selectedOption = options[_random.nextInt(options.length)];

    // Random date
    DateTime createdDate = _generateRandomDate(month);
    DateTime dateTime = createdDate.subtract(Duration(minutes: 1));

    // Random status
    String status = statusOptions[_random.nextInt(statusOptions.length)];
    bool statusDone = status == 'success';
    String takenBy = statusDone
        ? takenByOptions[_random.nextInt(takenByOptions.length)]
        : '';

    // Generate random price between 50,000 and 450,000
    int price = (50 + _random.nextInt(401)) * 1000;

    return {
      "Option": [selectedOption],
      "address": "Surabaya, Indonesia",
      "created_date": Timestamp.fromDate(createdDate), // Save as Timestamp
      "dateTime": Timestamp.fromDate(dateTime), // Save as Timestamp
      "description": "",
      "end_time":
          "${_random.nextInt(5) + 14}:${(_random.nextInt(2) * 30).toString().padLeft(2, '0')}",
      "image": "",
      "location": _generateGeoPoint(),
      "otherOption": "",
      "price": price.toString(),
      "start_time":
          "${_random.nextInt(5) + 8}:${(_random.nextInt(2) * 30).toString().padLeft(2, '0')}",
      "status": status,
      "status_done": statusDone,
      "taken_by": takenBy,
      "tipe_pekerjaan": tipePekerjaan,
      "uid": _generateUid(index, createdDate),
      "user": users[_random.nextInt(users.length)],
    };
  }

  // Function to add 70 dummy transactions to Firebase
  static Future<void> addDummyRequests() async {
    int index = 1;
    for (int i = 0; i < 70; i++) {
      int month = 6 + (i ~/ 30); // Distribute dates over June, July, August
      Map<String, dynamic> data = _generateData(index, month);
      await _requests.add(data);
      index++;
    }
  }
}
