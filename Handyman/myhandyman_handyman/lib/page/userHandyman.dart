import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:myhandyman_handyman/model/pekerjaan.dart';
import 'package:myhandyman_handyman/page/checkPemesanan.dart';
import 'package:myhandyman_handyman/page/kontak.dart';
import 'package:myhandyman_handyman/page/profile.dart';
import 'package:myhandyman_handyman/service/filtermenu.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
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
    return [home(), KontakPage(), profileHandyman()];
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
      mainContext = context;
    } else {}
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
  double maxDistanceFilter = 30.0;
  double selectedDistance = 0.0;
  List<Pekerjaan> dataToDisplay = [];
  TextEditingController queryController = TextEditingController();
  bool filterByDistance = false;

  final NumberFormat formatCurrency =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp');

  @override
  void initState() {
    super.initState();
    fetchLocationData(); // Pastikan posisi tersedia sebelum memanggil fetchData
  }

  Future<void> fetchLocationData() async {
    PermissionStatus permissionStatus = await Permission.location.request();

    if (permissionStatus.isGranted) {
      try {
        final Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        setState(() {
          _currentPosition = position;
          print("Posisi diperoleh: $_currentPosition");
        });

        // Panggil fetchData setelah mendapatkan posisi
        fetchData();
      } catch (e) {
        print('Error getting location: $e');
      }
    } else if (permissionStatus.isDenied ||
        permissionStatus.isPermanentlyDenied) {
      bool isPermissionGranted = await openAppSettings();
      if (isPermissionGranted) {
        fetchLocationData();
      }
    }
  }

  Future<void> fetchData() async {
    if (_currentPosition == null) {
      print("Menunggu posisi...");
      return;
    }

    data.clear();
    print("Mengambil data berdasarkan posisi: $_currentPosition");

    try {
      final dataList =
          await FirebaseDataService().getRequestData(_currentPosition!);
      setState(() {
        data = dataList;
        print("Data berhasil diperoleh: $data");
      });
    } catch (e) {
      print("Error saat mengambil data: $e");
    }
  }

  Future<void> _refresh() {
    return Future.delayed(Duration(seconds: 2), () {
      setState(() {
        fetchLocationData();
      });
    });
  }

  void FilteredByDistance() async {
    if (_currentPosition == null) {
      print("Posisi belum tersedia untuk filter berdasarkan jarak.");
      return;
    }

    data.clear();
    try {
      List<Pekerjaan> filteredData = await FirebaseDataService()
          .filterDataSearchdanDistance(
              selectedDistance, queryController.text, _currentPosition!);
      setState(() {
        data = filteredData;
      });
    } catch (e) {
      print("Error saat memfilter data berdasarkan jarak: $e");
    }
  }

  void FilteredBySearch() async {
    if (_currentPosition == null) {
      print("Posisi belum tersedia untuk filter pencarian.");
      return;
    }

    try {
      List<Pekerjaan> searchFilteredData = await FirebaseDataService()
          .searchPekerjaan(queryController.text, _currentPosition!);
      setState(() {
        data = searchFilteredData;
      });
    } catch (e) {
      print("Error saat memfilter data berdasarkan pencarian: $e");
    }
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Location services are disabled. Please enable the services')),
      );
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are denied')),
        );
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Location permissions are permanently denied, we cannot request permissions.')),
      );
      return false;
    }
    return true;
  }

  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;

    try {
      final Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentPosition = position;
      });
      print("Posisi: $_currentPosition");
    } catch (e) {
      print("Error mendapatkan posisi: $e");
    }
  }

  @override
  void dispose() {
    queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          Row(
            children: [
              Text('Home'),
              Padding(
                padding: const EdgeInsets.all(12.0),
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
                      if (filterByDistance) {
                        FilteredByDistance();
                      } else {
                        FirebaseDataService()
                            .searchPekerjaan(keyword, _currentPosition!)
                            .then((searchResults) {
                          setState(() {
                            data.clear();
                            // Perbarui data yang ditampilkan dengan hasil pencarian
                            data = searchResults;
                          });
                        });
                      }
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
      body: RefreshIndicator(
        child: Container(
          constraints: BoxConstraints(
            minWidth: 0,
            maxWidth: MediaQuery.of(context).size.width,
            maxHeight: 600,
          ),
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                'assets/images/home_decoration.png',
              ),
              fit: BoxFit.fill,
              alignment: Alignment.topCenter,
            ),
          ),
          child: CustomScrollView(
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
                      // Menggabungkan multiple values dengan koma
                      subtitle: Card(
                        // Define the shape of the card
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        // Define how the card's content should be clipped
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        // Define the child widget of the card
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            // Add padding around the row widget
                            Padding(
                              padding: const EdgeInsets.all(15),
                              child: Text(
                                '${item.optionMenu.join(', ')}',
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(15),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  // Add an image widget to display an image
                                  item.image != null && item.image.isNotEmpty
                                      ? Image.network(
                                          item.image,
                                          height: 100,
                                          width: 100,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.asset(
                                          'assets/images/no-photos.jpg',
                                          height: 100,
                                          width: 100,
                                          fit: BoxFit.cover,
                                        ),

                                  // Add some spacing between the image and the text
                                  Container(width: 20),
                                  // Add an expanded widget to take up the remaining horizontal space
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        // Add some spacing between the top of the card and the title
                                        Container(height: 5),
                                        // Add a title widget
                                        Text(
                                          item.tipe_Pekerjaan,
                                        ),
                                        // Add some spacing between the title and the subtitle
                                        Container(height: 5),
                                        // Add a subtitle widget
                                        Text(
                                          formatCurrency.format(
                                              int.parse(item.price.toString())),
                                        ),
                                        // Add some spacing between the subtitle and the text
                                        Container(height: 10),
                                        // Add a text widget to display some text
                                        Text(
                                          '${calculatedDistance.toStringAsFixed(1)} kilometer',
                                          maxLines: 2,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      onTap: () {
                        Navigator.of(context, rootNavigator: true)
                            .pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (BuildContext context) {
                              return pemesanan_details(
                                  data: item.id,
                                  email: item.user,
                                  uid: item.uid);
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
        ),
        onRefresh: _refresh,
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
