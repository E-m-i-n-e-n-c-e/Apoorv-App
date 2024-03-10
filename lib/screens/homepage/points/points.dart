import 'package:apoorv_app/providers/user_info_provider.dart';
import 'package:apoorv_app/screens/homepage/points/all_transactions.dart';
import 'package:provider/provider.dart';

import '../../../widgets/points-widget/qr/generate_qr.dart';
import '../../../widgets/points-widget/qr/scan_qr.dart';
import 'package:flutter/material.dart';

import '../../../constants.dart';
import '../../../widgets/snackbar.dart';
import 'leaderboard.dart';

class PointsScreen extends StatefulWidget {
  static const routeName = '/points';
  const PointsScreen({super.key});

  @override
  State<PointsScreen> createState() => _PointsScreenState();
}

class _PointsScreenState extends State<PointsScreen> {
  Future<Map<String, dynamic>>? myFuture;
  @override
  void initState() {
    super.initState();
  }

  Future reloadPage() async {
    myFuture = Provider.of<UserProvider>(context, listen: false)
        .getLatest2Transactions();
    return myFuture;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: reloadPage(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );

            case ConnectionState.done:
            default:
              if (snapshot.hasError) {
                return Scaffold(
                  body: Center(child: Text(snapshot.error.toString())),
                );
              } else if (snapshot.hasData) {
                print(snapshot.data);
                if (snapshot.data['success']) {
                  Provider.of<UserProvider>(context);
                  var providerContext = context.read<UserProvider>();
                  // providerContext.refreshUID();

                  // var data = snapshot.data;

                  // Future.delayed(Durations.extralong4,
                  //     () => showSnackbarOnScreen(context, data['message']));

                  return Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Constants.gradientHigh, Constants.gradientLow],
                        begin: Alignment.topCenter,
                        end: Alignment.center,
                      ),
                    ),
                    // color: Constants.yellowColor,
                    child: SafeArea(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            margin: EdgeInsets.symmetric(
                                horizontal:
                                    MediaQuery.of(context).size.width * 0.033),
                            decoration: BoxDecoration(
                              color: Constants.blackColor,
                              // border: Border.all(
                              //   color: Colors.white,
                              // ),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const TextField(
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Search Someone",
                                  prefixIcon: Icon(
                                    Icons.search,
                                    size: 30,
                                  )),
                            ),
                          ),
                          // Constants.gap,
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                context.read<UserProvider>().points.toString(),
                                style: const TextStyle(
                                  fontSize: 72,
                                  fontWeight: FontWeight.w700,
                                  color: Constants.blackColor,
                                ),
                              ),
                              const Text(
                                "Points",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 36,
                                  color: Constants.blackColor,
                                ),
                              ),
                            ],
                          ),
                          // Constants.gap,
                          Expanded(
                            child: Container(
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                color: Constants.blackColor,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(24),
                                  topRight: Radius.circular(24),
                                ),
                              ),
                              padding: EdgeInsets.all(
                                  MediaQuery.of(context).size.width * 0.05),
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  // mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    const Text(
                                      "LAST TRANSACTIONS",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 19,
                                      ),
                                    ),

                                    if (providerContext.transactions.isEmpty)
                                      const Column(
                                        children: [
                                          Text("No transactions to show here"),
                                          Constants.gap,
                                        ],
                                      ),
                                    if (providerContext.transactions.isNotEmpty)
                                      ...snapshot.data['transactions'],
                                    Constants.gap,

                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pushNamed(
                                              AllTransactions.routeName);
                                        },
                                        style: const ButtonStyle(),
                                        child: const Text(
                                          'View More',
                                          style: TextStyle(fontSize: 16),
                                          // textAlign: TextAlign.end,
                                        ),
                                      ),
                                    ),

                                    Constants.gap,
                                    // QrCode(),

                                    const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [GenerateQR(), ScanQR()],
                                    ),

                                    const SizedBox(
                                      height: 20,
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.pushNamed(
                                            context,
                                            Leaderboard.routeName,
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                15.0), // Set the desired border radius
                                          ),
                                        ),
                                        child: const Text("View Leaderboard"),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // ),
                  );
                } else {
                  // Future.delayed(
                  //   Duration.zero,
                  //   () =>
                  //       showSnackbarOnScreen(context, snapshot.data['message']),
                  // );
                  return Center(child: Text(snapshot.data['message']));
                }
              } else {
                return const Scaffold(body: Text('No data'));
              }
          }
        });
  }
}
