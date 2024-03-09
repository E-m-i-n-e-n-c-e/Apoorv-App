
import 'package:apoorv_app/providers/user_info_provider.dart';
import 'package:apoorv_app/widgets/signup-flow/logout.dart';
import 'package:provider/provider.dart';

import '../../../constants.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ProfileScreen extends StatefulWidget {
  static const routeName = '/profile';
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    var prov = Provider.of<UserProvider>(context, listen: false);
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Constants.gradientHigh, Constants.gradientLow],
          begin: Alignment.topCenter,
          end: Alignment.center,
        ),
      ),
      child: SafeArea(
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
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                FilledButton(
                                  onPressed: () {},
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Constants.yellowColor),
                                    foregroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.black),
                                  ),
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: Text(
                                      "Points Balance: ${context.read<UserProvider>().points}",
                                      textAlign: TextAlign.center,
                                      // style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ),
                                Constants.gap,
                                const LogoutButton(),
                              ],
                            ),
                          )
                        ]),
                    Constants.gap,
                    const Text("Dummy",
                        style: TextStyle(
                          color: Constants.blackColor,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        )),
                    const Text("Email",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Constants.blackColor,
                            fontSize: 16)),
                    const Text("dummy@noreply.com",
                        style: TextStyle(
                            color: Constants.blackColor, fontSize: 16)),
                    const Text("Phone",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Constants.blackColor)),
                    const Text("1111111111",
                        style: TextStyle(
                            color: Constants.blackColor, fontSize: 16)),
                    // if (providerContext.fromCollege)
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Roll No',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Constants.blackColor)),
                        Text("2021BCS0000",
                            style: TextStyle(
                                color: Constants.blackColor, fontSize: 16)),
                      ],
                    ),
                    const Text('College',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Constants.blackColor)),
                    const Text("IIITK",
                        style: TextStyle(
                            color: Constants.blackColor, fontSize: 16)),
                  ]),
            ),
            Constants.gap,
            Expanded(
              child: Container(
                // width: double.infinity,
                alignment: Alignment.center,
                padding:
                    EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  color: Constants.blackColor,
                ),
                child: QrImageView(
                  data: "Nothing to see here",
                  backgroundColor: Constants.whiteColor,
                  // size: MediaQuery.of(context).size.width * 0.75,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
