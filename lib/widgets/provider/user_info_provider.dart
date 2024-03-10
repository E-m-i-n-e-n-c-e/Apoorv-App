import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  String userName;
  String? userCollegeName;
  String? userRollNo;
  String userPhNo;
  String? profilePhotoUrl;
  String userEmail;
  bool fromCollege = false;
  String shopkeeperEmail;
  String shopkeeperPassword;

  int points = 0;

  UserProvider({
    this.userName = "Full Name",
    this.userCollegeName,
    this.userRollNo,
    this.userPhNo = "Phone Number",
    this.profilePhotoUrl,
    this.userEmail = " ",
    this.shopkeeperEmail = " ",
    this.shopkeeperPassword = " ",
  });

  void changeSameCollegeDetails({
    required String newUserName,
    required String newUserRollNo,
    required String newUserPhNo,
  }) {
    userName = newUserName;
    userPhNo = newUserPhNo;
    userCollegeName = 'IIIT Kottayam';
    userRollNo = newUserRollNo;
    notifyListeners();
  }

  void changeOtherCollegeDetails({
    required String newUserName,
    required String newUserCollegeName,
    required String newUserPhNo,
  }) {
    userName = newUserName;
    userPhNo = newUserPhNo;
    userCollegeName = newUserCollegeName;
    notifyListeners();
  }

  void updateShopkeeper({
    required String shopEmail,
    required String shopPass,
  }) {
    shopkeeperEmail = shopEmail;
    shopkeeperPassword = shopPass;
    notifyListeners();
  }

  void updateProfilePhoto(String pf) {
    profilePhotoUrl = pf;
    notifyListeners();
  }

  void updateEmail(String em) {
    userEmail = em;
    notifyListeners();
  }

  void updatePoints(int newPoints) {
    points = newPoints;
    notifyListeners();
  }
}
