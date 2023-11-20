import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:handyman_ta/pages/Model/pekerjaan.dart';
import 'package:handyman_ta/pages/User/UI/kontak.dart';
import 'package:handyman_ta/pages/User/UI/profile.dart';
import 'package:handyman_ta/pages/User/UI/request_pekerjaan.dart';
import 'package:handyman_ta/pages/loginpage.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';

class userHomepage extends StatelessWidget {
  static const routeName = '/User/userHome';
  final email;
  const userHomepage({super.key, this.email});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.blueGrey),
      debugShowCheckedModeBanner: false,
      home: MainMenu(email: email.toString()),
    );
  }
}

class MainMenu extends StatefulWidget {
  final email;
  const MainMenu({super.key, this.email});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  BuildContext? mainContext;
  List<Widget> _buildScreens() {
    return [
      home(email: widget.email),
      requestPekerjaan(email: widget.email),
      messageUser(email: widget.email),
      profile(email: widget.email)
    ];
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
        icon: const Icon(CupertinoIcons.add_circled),
        title: ("Add"),
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
  final email;

  const home({super.key, this.email});

  @override
  State<home> createState() => _homeState();
}

class _homeState extends State<home> {
  int currentIndex = 0;
  List<Pekerjaan> dataList = [];
  Future<void> fetchData() async {
    PekerjaanService pekerjaanService = PekerjaanService();
    List<Pekerjaan> fetchedData = await pekerjaanService.getPekerjaanListRand();
    fetchedData.shuffle();

    setState(() {
      dataList = fetchedData;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          constraints: BoxConstraints(
            minWidth: 0,
            maxWidth: MediaQuery.of(context).size.width,
            maxHeight: 175,
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
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 250,
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding:
                          const EdgeInsets.only(top: 50, right: 50, left: 50),
                      child: const Text(
                        'Welcome',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(top: 50, left: 125),
                      child: IconButton(
                        icon: Icon(Icons.notifications),
                        onPressed: () {
                          // Tambahkan logika notifikasi di sini
                          // Misalnya tampilkan snackbar atau navigasi ke layar notifikasi
                          // Sesuaikan dengan kebutuhan aplikasi kamu
                        },
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
        const Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(bottom: 20.0),
              child: Text(
                "Popular Menu",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        Column(children: [
          CarouselSlider(
            options: CarouselOptions(
              onPageChanged: (index, reason) {
                setState(() {
                  currentIndex = index;
                });
              },
              height: 250.0,
              enableInfiniteScroll: true,
              reverse: false,
              initialPage: 0,
              scrollDirection: Axis.horizontal,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 3),
              autoPlayAnimationDuration: const Duration(milliseconds: 1000),
              autoPlayCurve: Curves.fastOutSlowIn,
            ),
            items: dataList.map((pekerjaan) {
              return Builder(
                builder: (BuildContext context) {
                  return Center(
                    child: Stack(
                      children: [
                        Container(
                          margin: const EdgeInsets.all(10),
                          alignment: Alignment.center,
                          child: ClipRect(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(
                                sigmaX: 4,
                                sigmaY: 4,
                              ),
                              child: Image.asset(
                                pekerjaan
                                    .imageName, // Ganti dengan field yang sesuai
                                height: 250,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.all(10),
                          color: Colors.transparent,
                          alignment: Alignment.center,
                          child: Text(
                            pekerjaan.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                              color: Colors.white70,
                              fontFamily: 'OpenSans',
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }).toList(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 0; i < dataList.length; i++)
                Container(
                  height: 12,
                  width: 12,
                  margin: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: currentIndex == i ? Colors.blue : Colors.white24,
                    shape: BoxShape.circle,
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.grey,
                        spreadRadius: 2,
                        blurRadius: 2,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ])
      ],
    );
  }
}

//profile
class profile_home extends StatelessWidget {
  const profile_home({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.blueGrey),
      debugShowCheckedModeBanner: false,
      home: const profile(),
    );
  }
}
