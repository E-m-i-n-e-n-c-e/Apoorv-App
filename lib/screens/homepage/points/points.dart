import 'dart:async';

import 'package:apoorv_app/api.dart';
import 'package:apoorv_app/providers/receiver_provider.dart';
import 'package:apoorv_app/providers/user_info_provider.dart';
import 'package:apoorv_app/screens/homepage/Transactions/payment.dart';
import 'package:apoorv_app/screens/homepage/points/all_transactions.dart';
import 'package:provider/provider.dart';
import '../../../widgets/points-widget/qr/generate_qr.dart';
import '../../../widgets/points-widget/qr/scan_qr.dart';
import 'package:flutter/material.dart';

import '../../../constants.dart';
import '../../../widgets/spinning_apoorv.dart';
import 'leaderboard.dart';

StreamController<bool> st = StreamController<bool>.broadcast();

class PointsScreen extends StatefulWidget {
  static const routeName = '/points';
  final Stream<bool>? stream;
  const PointsScreen({this.stream, super.key});

  @override
  State<PointsScreen> createState() => _PointsScreenState();
}

class _PointsScreenState extends State<PointsScreen> {
  Future<Map<String, dynamic>>? myFuture;

  final searchController = TextEditingController();
  bool searchFocus = false;
  FocusNode searchFocusNode = FocusNode();

  Map<String, dynamic>? _searchResults = {
    'success': false,
    'results': null,
  };

  Timer? timer;

  @override
  void initState() {
    super.initState();
    getTransactionHistory();
    if (widget.stream != null) {
      widget.stream!.listen((event) {
        if (event) {
          getTransactionHistory();
        }
      });
    }
    // searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    searchController.dispose();
    timer?.cancel();
    super.dispose();
  }

  Future<void> getTransactionHistory() async {
    Provider.of<UserProvider>(context, listen: false).getUserInfo();
    if (context.mounted) {
      setState(() {
        myFuture = Provider.of<UserProvider>(context, listen: false)
            .getLatest2Transactions();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: myFuture,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return const Scaffold(
                body: Center(
                  child: SpinningApoorv(),
                ),
              );

            case ConnectionState.done:
            default:
              if (snapshot.hasError) {
                return Scaffold(
                  body: Center(child: Text(snapshot.error.toString())),
                );
              } else if (snapshot.hasData) {
                // print(snapshot.data);
                if (snapshot.data['success']) {
                  Provider.of<UserProvider>(context);
                  var providerContext = context.read<UserProvider>();

                  return GestureDetector(
                    onTap: () {
                      FocusManager.instance.primaryFocus?.unfocus();
                      setState(() {
                        searchFocus = false;
                        _searchResults!['results'] = null;
                      });
                    },
                    child: Scaffold(
                      resizeToAvoidBottomInset: false,
                      floatingActionButton: FloatingActionButton(
                        onPressed: () => getTransactionHistory(),
                        child: const Icon(Icons.refresh_rounded),
                      ),
                      body: Container(
                        // height: MediaQuery.of(context).size.height -
                        //     kBottomNavigationBarHeight,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Constants.gradientHigh,
                              Constants.gradientLow
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.center,
                          ),
                        ),
                        // color: Constants.yellowColor,
                        child: SafeArea(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Stack(
                                children: [
                                  if (searchFocus)
                                    Container(
                                        margin: EdgeInsets.symmetric(
                                            horizontal: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.033),
                                        decoration: BoxDecoration(
                                          color: Constants.blackColor,
                                          borderRadius:
                                              BorderRadius.circular(30),
                                        ),
                                        padding:
                                            const EdgeInsets.only(bottom: 16),
                                        width: double.infinity,
                                        child: Column(
                                          children: [
                                            const SizedBox(
                                              height: kToolbarHeight,
                                              width: double.infinity,
                                            ),
                                            if (_searchResults == null)
                                              const Text('Some error occured'),
                                            if (_searchResults != null &&
                                                _searchResults!['results'] ==
                                                    null)
                                              const Text(
                                                  "Enter name to search for"),
                                            if (_searchResults != null &&
                                                _searchResults!['results'] !=
                                                    null &&
                                                _searchResults!['results']
                                                    .isEmpty)
                                              const Text("No users found"),
                                            if (_searchResults != null &&
                                                _searchResults!['results'] !=
                                                    null &&
                                                _searchResults!['results']
                                                    ?.isNotEmpty)
                                              ListView.builder(
                                                shrinkWrap: true,
                                                itemBuilder: (context, i) =>
                                                    ListTile(
                                                  title: Text(
                                                      _searchResults!['results']
                                                          [i]['fullName']),
                                                  subtitle: Text(
                                                      _searchResults!['results']
                                                          [i]['email']),
                                                  trailing: Text(
                                                      '${_searchResults!['results'][i]['points']} pts'),
                                                  onTap: () {
                                                    Provider.of<ReceiverProvider>(
                                                            context,
                                                            listen: false)
                                                        .setReceiverDataFromSearch(
                                                            _searchResults![
                                                                'results'][i]);
                                                    Navigator.of(context)
                                                        .pushNamed(
                                                            Payment.routeName)
                                                        .then((value) {
                                                      searchController.clear();
                                                      FocusManager
                                                          .instance.primaryFocus
                                                          ?.unfocus();
                                                      _searchResults![
                                                          'results'] = null;
                                                      setState(() {
                                                        searchFocus = false;
                                                      });
                                                    });
                                                  },
                                                ),
                                                itemCount:
                                                    _searchResults!['results']
                                                        .length,
                                              )
                                          ],
                                        )),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        searchFocus = true;
                                        searchFocusNode.requestFocus();
                                      });
                                    },
                                    child: Container(
                                      margin: EdgeInsets.symmetric(
                                          horizontal: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.033),
                                      decoration: BoxDecoration(
                                        color: Constants.blackColor,
                                        // border: Border.all(
                                        //   color: Colors.white,
                                        // ),
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      child: AbsorbPointer(
                                        child: TextField(
                                          autofocus: searchFocus,
                                          decoration: const InputDecoration(
                                              border: InputBorder.none,
                                              hintText: "Search Someone",
                                              prefixIcon: Icon(
                                                Icons.search,
                                                size: 30,
                                              )),
                                          style: const TextStyle(
                                              color: Colors.white),
                                          controller: searchController,
                                          focusNode: searchFocusNode,
                                          onChanged: (value) {
                                            if (value.isNotEmpty &&
                                                value.trim().isNotEmpty) {
                                              if (timer != null) {
                                                timer!.cancel();
                                                timer = null;
                                              }
                                              timer = Timer(
                                                const Duration(seconds: 1),
                                                // userWrites,
                                                () async {
                                                  var res = await APICalls()
                                                      .getUsersSearchList(
                                                    searchController.text
                                                        .trim(),
                                                    context
                                                        .read<UserProvider>()
                                                        .idToken,
                                                  );

                                                  setState(() {
                                                    if (res['success']) {
                                                      _searchResults![
                                                          'success'] = true;
                                                      _searchResults![
                                                              'results'] =
                                                          res['results'];
                                                    } else {
                                                      _searchResults = null;
                                                    }
                                                  });
                                                },
                                              );
                                            } else {
                                              if (timer != null) {
                                                timer!.cancel();
                                              }
                                              setState(() {
                                                _searchResults!['results'] =
                                                    null;
                                              });
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              // Constants.gap,
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    context
                                        .read<UserProvider>()
                                        .points
                                        .toString(),
                                    style: const TextStyle(
                                      fontSize: 72,
                                      fontWeight: FontWeight.bold,
                                      color: Constants.blackColor,
                                    ),
                                  ),
                                  const Text(
                                    "Points",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 36,
                                      color: Constants.blackColor,
                                    ),
                                  ),
                                ],
                              ),
                              Constants.gap,
                              Flexible(
                                child: Container(
                                  // Container(
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
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        const Text(
                                          "LAST TRANSACTIONS",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 19,
                                          ),
                                        ),
                                        if (providerContext
                                            .transactions.isEmpty) ...[
                                          Constants.gap,
                                          const Center(
                                            child: Text(
                                                "No transactions to show here"),
                                          ),
                                          // Constants.gap,
                                        ],
                                        if (providerContext
                                            .transactions.isNotEmpty)
                                          ...snapshot.data['transactions'],
                                        // Constants.gap,
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: TextButton(
                                            onPressed: providerContext
                                                    .transactions.isNotEmpty
                                                ? () {
                                                    Navigator.of(context)
                                                        .restorablePushNamed(
                                                            AllTransactions
                                                                .routeName);
                                                  }
                                                : null, // Disable the button if there are no transactions
                                            style: const ButtonStyle(),
                                            child: const Text(
                                              'View More ->',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              // textAlign: TextAlign.end,
                                            ),
                                          ),
                                        ),
                                        // Constants.gap,
                                        const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [GenerateQR(), ScanQR()],
                                        ),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        SizedBox(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: ElevatedButton(
                                            onPressed: () {
                                              Navigator.pushNamed(
                                                context,
                                                Leaderboard.routeName,
                                              );
                                            },
                                            style: ElevatedButton.styleFrom(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  24,
                                                ),
                                              ),
                                            ),
                                            child: const Text(
                                              "View Leaderboard",
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                        // Constants.gap,
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // ),
                      ),
                    ),
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
