import 'package:apoorv_app/screens/shopkeeper/shopkeeper_points.dart';
import 'package:apoorv_app/screens/shopkeeper/shopkeeper_profile.dart';
import 'package:flutter/material.dart';

import '../../constants.dart';

class ShopkeeperHomePage extends StatefulWidget {
  static const routeName = '/shopkeeper-home-page';
  const ShopkeeperHomePage({super.key});

  @override
  State<ShopkeeperHomePage> createState() => _ShopkeeperHomePageState();
}

class _ShopkeeperHomePageState extends State<ShopkeeperHomePage> {
  int currentPageIndex = 0;

  bool popStatus = true;
  int popCount = 0;

  @override
  void initState() {
    super.initState();
    popScreen(context);
  }

  Future<void> popScreen(BuildContext context) async {
    popStatus = await Navigator.maybePop(context);
    if (mounted) {
      setState(() {});
    }
  }

  void showAppCloseConfirmation(BuildContext context) {
    const snackBar = SnackBar(
      content: Text("Press back again to exit"),
      backgroundColor: Colors.white,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  List screens = [
    const ShopkeeperPointsScreen(),
    const ShopkeeperProfileScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: popStatus,
      onPopInvoked: (bool didPop) async {
        if (didPop) {
          return;
        }
        popCount += 1;
        if (popCount == 1) {
          showAppCloseConfirmation(context);
          setState(() {
            popStatus = true;
          });
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        // appBar: AppBar(
        //   titleTextStyle: const TextStyle(color: Constants.yellowColor),
        //   // automaticallyImplyLeading: false,
        //   centerTitle: true,
        //   title: const Text(
        //     "APOORV 2K24",
        //     style: TextStyle(fontSize: 32),
        //   ),
        //   leading: Image.asset(
        //     'assets/images/phoenix_74.png',
        //     fit: BoxFit.fitHeight,
        //   ),
        // ),
        body: screens[currentPageIndex],
        bottomNavigationBar: NavigationBar(
          onDestinationSelected: (int index) {
            setState(() {
              currentPageIndex = index;
            });
          },
          indicatorColor: Constants.redColor,
          selectedIndex: currentPageIndex,
          destinations: const <Widget>[
            NavigationDestination(
              selectedIcon: Icon(Icons.stars),
              icon: Icon(Icons.stars_outlined),
              label: 'Points',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.account_circle),
              icon: Icon(Icons.account_circle_outlined),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
