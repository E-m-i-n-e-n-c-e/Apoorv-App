// ignore_for_file: library_private_types_in_public_api

import 'package:apoorv_app/screens/shopkeeper/shopkeeper_signup.dart';
import 'package:apoorv_app/screens/signup-flow/signup.dart';
import 'package:flutter/material.dart';

import '../../constants.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});
  static const routeName = '/welcome';
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
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
        body: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.sizeOf(context).width * 0.05),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Image.asset('assets/images/upscaled_phoenix_red_title.png'),
                  Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Constants.gradientLow,
                              Constants.gradientHigh
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          // color: Constants.yellowColor,
                          borderRadius: BorderRadius.all(Radius.circular(50)),
                        ),
                        child: FilledButton.icon(
                          onPressed: () => Navigator.of(context)
                              .restorablePushReplacementNamed(
                                  SignUpScreen.routeName),
                          style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all<Color>(
                                  Colors.transparent)),
                          icon: SizedBox(
                            height: 64,
                            child: Image.asset(
                              'assets/images/google.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                          label: const Text(
                            'Sign In with Google',
                            style: TextStyle(
                              fontSize: 20,
                              fontFamily: 'Inter',
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      Constants.gap,
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        width: double.infinity,
                        child: IconButton(
                            onPressed: () => Navigator.of(context)
                                .restorablePushReplacementNamed(
                                    ShopkeeperSignupScreen.routeName),
                            icon: const Icon(Icons.shop)),
                      ),
                    ],
                  )
                ],
              ),
            )),
      ),
    );
  }
}
