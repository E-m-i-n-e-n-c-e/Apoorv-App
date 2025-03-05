import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:apoorv_app/widgets/provider/user_info_provider.dart';
import '../../../constants.dart';
import 'letsgo.dart';

class SignUpScreen extends StatefulWidget {
  static const routeName = '/sign-up-1';
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> with RestorationMixin {
  final RestorableTextEditingController userNameController =
      RestorableTextEditingController();
  final RestorableTextEditingController userPhNoController =
      RestorableTextEditingController();
  final RestorableTextEditingController userRollNoController =
      RestorableTextEditingController();
  final RestorableTextEditingController userCollegeNameController =
      RestorableTextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    userNameController.dispose();
    userRollNoController.dispose();
    userCollegeNameController.dispose();
    userPhNoController.dispose();
    super.dispose();
  }

  RestorableBool isChecked = RestorableBool(true);

  bool popStatus = true;
  int count = 0;

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
    var userProvider = Provider.of<UserProvider>(context);
    return PopScope(
      canPop: popStatus,
      onPopInvoked: (bool didPop) async {
        if (didPop) {
          return;
        }
        count += 1;
        if (count == 1) {
          showAppCloseConfirmation(context);
          setState(() {
            popStatus = true;
          });
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.05),
            child: LayoutBuilder(builder: (context, constraints) {
              return SingleChildScrollView(
                // reverse: false,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    // mainAxisAlignment: MainAxisAlignment.spaceAround,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                                text: 'Give us a Quick Introduction\n',
                                style: TextStyle(color: Constants.yellowColor)),
                            TextSpan(
                                text: 'About ',
                                style: TextStyle(color: Constants.yellowColor)),
                            TextSpan(
                                text: 'Yourself',
                                style: TextStyle(color: Constants.redColor)),
                          ],
                          style: TextStyle(
                              fontFamily: 'Libre Baskerville', fontSize: 22),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Icon(
                        Icons.account_circle_outlined,
                        color: Constants.yellowColor,
                        size: MediaQuery.of(context).size.width * 0.4,
                      ),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: userNameController.value,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Full name is required";
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16)),
                                filled: true,
                                fillColor: Constants.yellowColor,
                                hintText: "Full Name",
                                hintStyle: const TextStyle(color: Colors.black),
                              ),
                            ),
                            Constants.gap,
                            TextFormField(
                              controller: userPhNoController.value,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Phone number is required";
                                } else if (value.length != 10) {
                                  return "Phone number must be exactly 10 digits long";
                                }
                                return null;
                              },
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(10),
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16)),
                                filled: true,
                                fillColor: Constants.yellowColor,
                                hintText: 'Phone Number',
                                hintStyle: const TextStyle(color: Colors.black),
                              ),
                            ),
                            Constants.gap,
                            if (isChecked.value)
                              Column(
                                children: [
                                  TextFormField(
                                    controller: userRollNoController.value,
                                    validator: (value) {
                                      if (value == null ||
                                          value.isEmpty ||
                                          !RegExp(r"(2020|2021|2022|2023)(bcs|bec|bcy|bds)0\d{3}")
                                              .hasMatch(value.toLowerCase())) {
                                        return "You know the format";
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                          borderSide:
                                              const BorderSide(width: 50),
                                          borderRadius:
                                              BorderRadius.circular(16)),
                                      filled: true,
                                      fillColor: Constants.yellowColor,
                                      hintText: 'Roll Number',
                                      hintStyle:
                                          const TextStyle(color: Colors.black),
                                    ),
                                  ),
                                  Constants.gap,
                                ],
                              ),
                            if (!isChecked.value)
                              Column(
                                children: [
                                  TextFormField(
                                    controller: userCollegeNameController.value,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "Fill your college name!";
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(16)),
                                      filled: true,
                                      fillColor: Constants.yellowColor,
                                      hintText: "College Name",
                                      hintStyle:
                                          const TextStyle(color: Colors.black),
                                    ),
                                  ),
                                  Constants.gap,
                                ],
                              ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Transform.scale(
                                  scale: 1.2,
                                  child: Checkbox(
                                    value: isChecked.value,
                                    onChanged: (bool? value) {
                                      userCollegeNameController.value.clear();
                                      userRollNoController.value.clear();
                                      setState(() {
                                        isChecked.value = value ?? true;
                                      });
                                    },
                                  ),
                                ),
                                const Text(
                                  "From IIIT Kottayam",
                                  style: TextStyle(fontSize: 17),
                                ),
                              ],
                            ),
                            Constants.gap,
                            FilledButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  userProvider.fromCollege = isChecked.value;
                                  if (isChecked.value) {
                                    userProvider.changeSameCollegeDetails(
                                        newUserName:
                                            userNameController.value.text,
                                        newUserRollNo:
                                            userRollNoController.value.text,
                                        newUserPhNo:
                                            userPhNoController.value.text);
                                  } else {
                                    userProvider.changeOtherCollegeDetails(
                                        newUserName:
                                            userNameController.value.text,
                                        newUserCollegeName:
                                            userCollegeNameController
                                                .value.text,
                                        newUserPhNo:
                                            userPhNoController.value.text);
                                  }
                                  Navigator.of(context).restorablePushNamed(
                                      LetsGoPage.routeName);
                                }
                              },
                              style: ButtonStyle(
                                  backgroundColor:
                                      WidgetStateProperty.all<Color>(
                                          Constants.redColor),
                                  foregroundColor:
                                      WidgetStateProperty.all<Color>(
                                          Colors.white)),
                              child: Container(
                                height: 48,
                                alignment: Alignment.center,
                                child: Container(
                                  height: 48,
                                  alignment: Alignment.center,
                                  child: const Text(
                                    'Continue',
                                    style: TextStyle(fontSize: 20),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                          padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).viewInsets.bottom))
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  @override
  String? get restorationId => "signupscreen";

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(userNameController, "full_name");
    registerForRestoration(userRollNoController, "roll_number");
    registerForRestoration(userPhNoController, "phone_number");
    registerForRestoration(userCollegeNameController, "college_name");
    registerForRestoration(isChecked, "IIITK");
  }
}
