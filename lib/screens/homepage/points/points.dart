import 'package:apoorv_app/widgets/provider/user_info_provider.dart';
import 'package:provider/provider.dart';

import '../../../widgets/signup-flow/qr/generate_qr.dart';
import '../../../widgets/signup-flow/qr/scan_qr.dart';
import 'package:flutter/material.dart';

import '../../../../constants.dart';
import 'leaderboard.dart';
import '../../../widgets/points-widget/transactions.dart';

class PointsScreen extends StatefulWidget {
  static const routeName = '/points';
  const PointsScreen({super.key});

  @override
  State<PointsScreen> createState() => _PointsScreenState();
}

class _PointsScreenState extends State<PointsScreen> {
  TextEditingController searchController = TextEditingController();
  List<String> searchResults = [];
  bool showDropdown = false;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // return Scaffold(
    // appBar: AppBar(
    //   backgroundColor: Constants.yellowColor,
    //   automaticallyImplyLeading: false,
    //   title: Container(
    //     decoration: BoxDecoration(
    //       color: Constants.blackColor,
    //       // border: Border.all(
    //       //   color: Colors.white,
    //       // ),
    //       borderRadius: BorderRadius.circular(30),
    //     ),
    //     child: const TextField(
    //       decoration: InputDecoration(
    //           border: InputBorder.none,
    //           hintText: "Search Contacts",
    //           prefixIcon: Icon(
    //             Icons.search,
    //             size: 30,
    //           )),
    //     ),
    //   ),
    // ),
    // body: Container(
    return Stack(
      children: [
        Container(
          // padding: const EdgeInsets.only(top: 20),
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
                      horizontal: MediaQuery.of(context).size.width * 0.033),
                  decoration: BoxDecoration(
                    color: Constants.blackColor,
                    // border: Border.all(
                    //   color: Colors.white,
                    // ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: TextField(
                    controller: searchController,
                    onChanged: (value) {
                      if (value.length >= 3) {
                        //make API call
                        _makeAPICall(value);
                      } else {
                        setState(() {
                          showDropdown = false;
                          searchResults.clear();
                        });
                      }
                    },
                    decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Search Someone",
                        prefixIcon: Icon(
                          Icons.search,
                          size: 30,
                        )),
                  ),
                ),
                if (showDropdown)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: searchResults.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(searchResults[index]),
                          onTap: () {
                            // Handle selection
                          },
                        );
                      },
                    ),
                  ),
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
                // Expanded(
                //   child: SingleChildScrollView(
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      // height: MediaQuery.of(context).size.height,
                      // width: MediaQuery.of(context).size.width,
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "LAST TRANSACTIONS",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                            ),
                          ),
                          const TransactionsWidget(
                            name: "John Doe",
                            date: "February 29, 2024 at 10:22 AM",
                            points: 54,
                            type: 'credit',
                          ),
                          const TransactionsWidget(
                            name: "John Doe",
                            date: "February 29, 2024 at 10:22 AM",
                            points: 23,
                            type: 'debit',
                          ),
                          Constants.gap,
                          const SizedBox(
                            width: double.infinity,
                            child: Text(
                              'View More',
                              style: TextStyle(fontSize: 16),
                              textAlign: TextAlign.end,
                            ),
                          ),
                          Constants.gap,
                          // QrCode(),

                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                // ),
              ],
            ),
          ),
          // ),
        ),
      ],
    );
  }

  void _makeAPICall(String searchText) {
    // Make your API call here using the searchText
    debugPrint('API call with search text: $searchText');
  }
}
