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
    PermissionStatus permissionStatus = await Permission.location.request();

    if (permissionStatus.isGranted) {
      try {
        final Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        setState(() {
          _currentPosition = position;
          print(_currentPosition);
        });
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
    data.clear();
    FirebaseDataService().getRequestData().then((dataList) {
      setState(() {
        data = dataList;
      });
    });
  }

  void FilteredByDistance() async {
    data.clear();
    // Panggil fetchAndFilterData
    List<Pekerjaan> filteredData = await FirebaseDataService()
        .filterDataSearchdanDistance(
            selectedDistance, queryController.text, _currentPosition!);

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
    fetchData();
    print(data);
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
                      if (filterByDistance) {
                        FilteredByDistance();
                      } else {
                        FirebaseDataService()
                            .searchPekerjaan(keyword)
                            .then((searchResults) {
                          setState(() {
                            data.clear();
                            // Perbarui data yang ditampilkan dengan hasil pencarian
                            data = searchResults;
                          });
                        });
                      }

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
                                          print(filterByDistance);
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
      body: Container(
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
                    title: Text(
                      'Option Menu: ${item.optionMenu.join(', ')}',
                    ), // Menggabungkan multiple values dengan koma
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Start Time: ${item.startTime}'),
                        Text('End Time: ${item.endTime}'),
                        Text('Description: ${item.description}'),
                        Text('Price: ${item.price}'),
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
                            return pemesanan_details(
                                data: item.id, email: item.user, uid: item.uid);
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
