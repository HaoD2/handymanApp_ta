import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:myhandyman_handyman/model/pekerjaan.dart';
import 'package:myhandyman_handyman/page/checkPemesanan.dart';
import 'package:myhandyman_handyman/page/message.dart';
import 'package:myhandyman_handyman/page/profile.dart';
import 'package:myhandyman_handyman/service/filtermenu.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class userHandyman extends StatelessWidget {
  static const routeName = 'Handyman/HandymanHome';
  const userHandyman({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.blueGrey),
      debugShowCheckedModeBanner: false,
      home: mainMenu(),
    );
  }
}

class mainMenu extends StatefulWidget {
  const mainMenu({super.key});

  @override
  State<mainMenu> createState() => _mainMenuState();
}

class _mainMenuState extends State<mainMenu> {
  BuildContext? mainContext;
  List<Widget> _buildScreens() {
    return [home(), MessageMain(), profileHandyman()];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    //route navigasi BottomNavMenu with Persitent
    return [
      PersistentBottomNavBarItem(
        icon: const Icon(CupertinoIcons.home),
        title: ("Home"),
        activeColorPrimary: CupertinoColors.activeBlue,
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(CupertinoIcons.chat_bubble),
        title: ("Message"),
        activeColorPrimary: CupertinoColors.activeBlue,
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(CupertinoIcons.person),
        title: ("Profile"),
        activeColorPrimary: CupertinoColors.activeBlue,
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),
    ];
  }

  late PersistentTabController _controller;

  @override
  Widget build(BuildContext context) {
    if (FirebaseAuth.instance.currentUser != null) {
      print('Auth User Home ada');
      mainContext = context;
    } else {
      print('Auth User tidak ada');
    }
    _controller = PersistentTabController(initialIndex: 0);

    return PersistentTabView(
      context,
      controller: _controller,
      screens: _buildScreens(),
      padding: const NavBarPadding.all(10),
      items: _navBarsItems(),
      confineInSafeArea: true,
      backgroundColor: Colors.white, // Default is Colors.white.
      handleAndroidBackButtonPress: true, // Default is true.
      resizeToAvoidBottomInset:
          true, // This needs to be true if you want to move up the screen when keyboard appears. Default is true.
      stateManagement: true, // Default is true.
      hideNavigationBarWhenKeyboardShows:
          true, // Recommended to set 'resizeToAvoidBottomInset' as true while using this argument. Default is true.
      decoration: NavBarDecoration(
        borderRadius: BorderRadius.circular(10.0),
        colorBehindNavBar: const Color.fromARGB(255, 242, 137, 252),
      ),
      popAllScreensOnTapOfSelectedTab: true,
      popActionScreens: PopActionScreensType.all,
      itemAnimationProperties: const ItemAnimationProperties(
        // Navigation Bar's items animation properties.
        duration: Duration(milliseconds: 200),
        curve: Curves.ease,
      ),
      screenTransitionAnimation: const ScreenTransitionAnimation(
        // Screen transition animation on change of selected tab.
        animateTabTransition: true,
        curve: Curves.ease,
        duration: Duration(milliseconds: 200),
      ),
      navBarStyle: NavBarStyle.style1,
      margin: const EdgeInsets.all(
          10), // Choose the nav bar style with this property.
    );
  }
}

class home extends StatefulWidget {
  const home({super.key});

  @override
  State<home> createState() => _homeState();
}

class _homeState extends State<home> {
  List<Pekerjaan> data = [];

  Position? _currentPosition;
  double maxDistanceFilter = 100.0;
  double selectedDistance = 0.0;
  List<Pekerjaan> dataToDisplay = [];
  TextEditingController queryController = TextEditingController();
  bool filterByDistance = false;
  Future<void> fetchLocationData() async {
    // Periksa izin lokasi
    final locationPermission = await Geolocator.checkPermission();
    if (locationPermission == LocationPermission.denied) {
      // Jika izin ditolak, minta izin
      final permissionStatus = await Geolocator.requestPermission();
      if (permissionStatus != LocationPermission.always &&
          permissionStatus != LocationPermission.whileInUse) {
        // Izin tidak diberikan, tampilkan pesan kepada pengguna atau handle sesuai kebijakan aplikasi Anda.
        return;
      }
    }

    // Periksa status layanan lokasi
    final isLocationServiceEnabled =
        await Geolocator.isLocationServiceEnabled();
    if (!isLocationServiceEnabled) {
      // Layanan lokasi dimatikan, tampilkan pesan kepada pengguna atau handle sesuai kebijakan aplikasi Anda.
      return;
    }

    // Dapatkan data lokasi
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);
      // Setelah mendapatkan data lokasi, Anda dapat menghitung jarak atau melakukan tindakan lainnya.
      setState(() {
        _currentPosition = position;
      });
    } catch (e) {
      // Tangani kesalahan yang mungkin terjadi saat mendapatkan lokasi.
    }
  }

  Future<void> _getCurrentLocation() async {
    PermissionStatus permissionStatus = await Permission.location.request();

    if (permissionStatus.isGranted) {
      try {
        final Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        setState(() {
          print(_currentPosition);
          _currentPosition = position;
        });
      } catch (e) {
        print('Error getting location: $e');
      }
    } else if (permissionStatus.isDenied ||
        permissionStatus.isPermanentlyDenied) {
      bool isPermissionGranted = await openAppSettings();
      if (isPermissionGranted) {
        _getCurrentLocation();
      }
    }
  }

  Future<void> fetchData() async {
    FirebaseDataService().getRequestData().then((dataList) {
      setState(() {
        data = dataList;
      });
    });
  }

  void FilteredByDistance() async {
    // Panggil fetchAndFilterData
    List<Pekerjaan> filteredData = await FirebaseDataService()
        .fetchAndFilterData(maxDistanceFilter, _currentPosition!);

    // Setelah mendapatkan data yang telah difilter, perbarui state widget ini dengan data tersebut
    setState(() {
      data = filteredData;
    });
  }

  void FilteredBySearch() async {
    // Panggil fetchAndFilterData
    List<Pekerjaan> SearchfilteredData =
        await FirebaseDataService().searchPekerjaan(dataToDisplay as String);
    print(dataToDisplay);
    // Setelah mendapatkan data yang telah difilter, perbarui state widget ini dengan data tersebut
    setState(() {
      data = SearchfilteredData;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchLocationData();
    _getCurrentLocation();
    if (filterByDistance) {
      print("masuk fecth data filter");
      FilteredByDistance();
    } else {
      print("masuk fecth data filter");
      fetchData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: 200, // Sesuaikan ukuran sesuai kebutuhan
                  child: TextField(
                    controller: queryController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25.0)),
                      ),
                      suffixIcon: Icon(Icons.search),
                    ),
                    onChanged: (text) {
                      // Dapatkan nilai pencarian saat pengguna mengetik
                      String keyword = text;
                      // Panggil fungsi pencarian dengan kata kunci yang sedang diketik
                      FirebaseDataService()
                          .searchPekerjaan(keyword)
                          .then((searchResults) {
                        setState(() {
                          data.clear();
                          // Perbarui data yang ditampilkan dengan hasil pencarian
                          data = searchResults;
                        });
                      });
                      print(keyword);
                    },
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.filter_list),
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return StatefulBuilder(builder: (context, setState) {
                          return AlertDialog(
                              title: Text('Filter'),
                              content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Text(
                                        'Distance: ${selectedDistance.toStringAsFixed(0)} Km'),
                                    Slider(
                                      value: selectedDistance,
                                      min: 0,
                                      max: maxDistanceFilter,
                                      onChanged: (value) {
                                        setState(() {
                                          selectedDistance = value;
                                        });
                                      },
                                    ),
                                    CheckboxListTile(
                                      title: Text('Filter by Distance'),
                                      value: filterByDistance,
                                      onChanged: (value) {
                                        setState(() {
                                          filterByDistance = value!;
                                        });
                                      },
                                    ),
                                    TextButton(
                                      child: Text('Filter'),
                                      onPressed: () {
                                        if (filterByDistance) {
                                          FilteredByDistance();
                                        } else {
                                          fetchData();
                                        }
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ]));
                        });
                      });

                  // Tampilkan dialog atau widget untuk mengatur filter ja
                },
              ),
            ],
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                final item = data[index];
                double calculatedDistance = Geolocator.distanceBetween(
                      _currentPosition?.latitude ?? 0.0,
                      _currentPosition?.longitude ?? 0.0,
                      item.location.latitude,
                      item.location.longitude,
                    ) /
                    1000;
                return ListTile(
                  title: Text(
                    'Option Menu: ${item.optionMenu.join(', ')}',
                  ), // Menggabungkan multiple values dengan koma
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Start Time: ${item.startTime}'),
                      Text('End Time: ${item.endTime}'),
                      Text('Description: ${item.description}'),
                      Row(
                        children: <Widget>[
                          Icon(Icons.access_time),
                          Text(
                              'Date Time: ${item.datetime.toDate()}'), // Konversi Timestamp ke DateTime
                        ],
                      ),
                      Text(
                          'Jarak ke Lokasi: ${calculatedDistance.toStringAsFixed(2)} kilometer'),
                    ],
                  ),
                  onTap: () {
                    Navigator.of(context, rootNavigator: true)
                        .pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (BuildContext context) {
                          return pemesanan_details(data: item.id);
                        },
                      ),
                      (_) => false,
                    );
                  },
                  // Tambahkan logika untuk menangani item yang diklik di sini
                );
              },
              childCount: data.length,
            ),
          ),
          // Tambahkan lebih banyak Sliver sesuai kebutuhan di sini
        ],
      ),
    );
  }
}

enum PermissionGroup {
  /// Android: Fine and Coarse Location
  /// iOS: CoreLocation - Always
  locationAlways,

  /// Android: Fine and Coarse Location
  /// iOS: CoreLocation - WhenInUse
  locationWhenInUse
}
