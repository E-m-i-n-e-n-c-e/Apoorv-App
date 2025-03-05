import 'package:apoorv_app/widgets/provider/user_info_provider.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:provider/provider.dart';

import '../../../constants.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../signup-flow/welcome.dart';

class ProfileScreen extends StatelessWidget {
  static const routeName = '/profile';
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Constants.gradientHigh, Constants.gradientLow],
          begin: Alignment.topCenter,
          end: Alignment.center,
        ),
      ),
      child: SafeArea(
        child: CustomMaterialIndicator(
          onRefresh: () async {}, // Your refresh logic

          indicatorBuilder:
              (BuildContext context, IndicatorController controller) {
            return const Icon(
              Icons.ac_unit,
              color: Colors.blue,
              size: 30,
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.05),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Icon(
                              Icons.account_circle_rounded,
                              size: MediaQuery.of(context).size.width * 0.33,
                              color: Constants.greenColor,
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.45,
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  buildPointsBalanceButton(context),
                                  Constants.gap,
                                  buildLogoutButton(context),
                                ],
                              ),
                            )
                          ]),
                      Constants.gap,
                      Text(context.read<UserProvider>().userName,
                          style: const TextStyle(
                            color: Constants.blackColor,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          )),
                      const Text("Email",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Constants.blackColor,
                              fontSize: 16)),
                      Text(context.read<UserProvider>().userEmail,
                          style: const TextStyle(
                              color: Constants.blackColor, fontSize: 16)),
                      const Text("Phone",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Constants.blackColor)),
                      Text(context.read<UserProvider>().userPhNo,
                          style: const TextStyle(
                              color: Constants.blackColor, fontSize: 16)),
                      if (context.read<UserProvider>().fromCollege)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Roll No',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Constants.blackColor)),
                            Text(context.read<UserProvider>().userRollNo!,
                                style: const TextStyle(
                                    color: Constants.blackColor, fontSize: 16)),
                          ],
                        ),
                      const Text('College',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Constants.blackColor)),
                      Text(context.read<UserProvider>().userCollegeName!,
                          style: const TextStyle(
                              color: Constants.blackColor, fontSize: 16)),
                    ]),
              ),
              Constants.gap,
              //             Expanded(
              //               child: Container(
              //                 // width: double.infinity,
              //                 alignment: Alignment.center,
              //                 padding:
              //                     EdgeInsets.all(MediaQuery.of(context).size.width * 0.1),
              //                 decoration: const BoxDecoration(
              //                   borderRadius: BorderRadius.only(
              //                     topLeft: Radius.circular(24),
              //                     topRight: Radius.circular(24),
              //                   ),
              //                   color: Constants.blackColor,
              //                 ),
              //                 child: QrImageView(
              //                   data: 'Siddharth',
              //                   backgroundColor: Constants.whiteColor,
              //                 ),
              //               ),
              //             ),
              buildQrCodeContainer(context),
            ],
          ),
        ),
      ),
    );
  }
}

Widget buildQrCodeContainer(BuildContext context) {
  return Expanded(
    child: Container(
      alignment: Alignment.center,
      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.1),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        color: Constants.blackColor,
      ),
      child: buildQrImageView(),
    ),
  );
}

Widget buildQrImageView() {
  return QrImageView(
    data: 'Siddharth',
    backgroundColor: Constants.whiteColor,
  );
}

Widget buildLogoutButton(BuildContext context) {
  return FilledButton(
    onPressed: () {
      Navigator.of(context).pushReplacementNamed(WelcomeScreen.routeName);
    },
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.all<Color>(Constants.redColor),
      foregroundColor: WidgetStateProperty.all<Color>(Constants.whiteColor),
    ),
    child: const SizedBox(
      width: double.infinity,
      child: Text(
        "Logout",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 16),
      ),
    ),
  );
}

Widget buildPointsBalanceButton(BuildContext context) {
  return FilledButton(
    onPressed: () {},
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.all<Color>(Constants.yellowColor),
      foregroundColor: WidgetStateProperty.all<Color>(Colors.black),
    ),
    child: SizedBox(
      width: double.infinity,
      child: buildPointButtonText(
          "Points Balance: ${context.read<UserProvider>().points}"),
    ),
  );
}

Widget buildPointButtonText(String text) {
  return Text(
    text,
    textAlign: TextAlign.center,
    // Add any additional style properties if needed
  );
}
