import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mobilizer/bloc/auth/auth_bloc.dart';
import 'package:mobilizer/bloc/search/organization_bloc.dart' as o;
import 'package:mobilizer/common/common/constants.dart';
import 'package:mobilizer/common/common/navigation.dart';
import 'package:mobilizer/common/common/sharepreference.dart';
//import 'package:getwidget/getwidget.dart';
import 'package:mobilizer/pages/login/login.dart';
import 'package:mobilizer/pages/organization/my_organizations.dart';
import 'package:mobilizer/pages/profile/profile.dart';

import 'package:mobilizer/pages/settings/my_account.dart';
import 'package:package_info_plus/package_info_plus.dart';
//import 'package:rflutter_alert/rflutter_alert.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool loading = false;
  bool absorbPointer = false;
  String _version = '';
  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    buildSignature: 'Unknown',
  );

  void initState() {
    super.initState();
    _initPackageInfo();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return AbsorbPointer(
      absorbing: absorbPointer,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            iconSize: 25,
            icon: FaIcon(
              FontAwesomeIcons.arrowLeft,
              size: 25,
              color: Colors.blue,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'Settings',
            style: TextStyle(color: Colors.black),
          ),
        ),
        body: SafeArea(
          child: BlocConsumer<AuthBloc, AuthState>(listener: (context, state) {
            if (state is LoadingState) {
              loading = true;
            }
            if (state is DeactivationState) {
              setState(() {
                loading = false;
              });
              print("successfully deactivated");

              //absorbPointer = true;
              final snackBar = SnackBar(
                  backgroundColor: Colors.green,
                  content: Text("Account was successfully deactivated"));
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen(showSnack: null)),
                (Route<dynamic> route) => false,
              );
            }
            if (state is ErrorState) {
              loading = false;
              print(state.message);
              if (state.message != "Error fetching profile data") {
                final snackBar =
                    SnackBar(content: Text(state.message.toString()));
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              }
            }

            if (state is NetworkState) {
              loading = false;
              final snackBar = SnackBar(
                  backgroundColor: Color(0xFFcf5555),
                  content: Text(state.message.toString()));
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            }
          }, builder: (context, state) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: size.height / 20.5,
                  ),
                  GestureDetector(
                    onTap: () {
                      print('Profile page link');
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return BlocProvider(
                          create: (context) => AuthBloc(),
                          child: Profile(),
                        );
                      }));
                    },
                    child: Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                              top: 0, bottom: 8, left: 20, right: 8),
                          child: Icon(
                            Icons.person,
                            color: Colors.black54,
                            size: 42,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              top: 8, bottom: 8, left: 20, right: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'My Profile',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Container(
                                width: size.width - 110,
                                child: Text(
                                  'View and edit your profile, townhall locations, profession and more.',
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.grey.shade700),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) {
                        return BlocProvider(
                          create: (context) => AuthBloc(),
                          child: MyAccount(),
                        );
                      }));
                    },
                    child: Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 0, bottom: 8, left: 20, right: 8),
                          child: Icon(
                            Icons.folder_shared_outlined,
                            size: 42,
                            color: Colors.black54,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 8, bottom: 8, left: 20, right: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'My Account',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Container(
                                width: size.width - 110,
                                child: Text(
                                  'Manage account information, deactivate account. Logout from account',
                                  style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // SizedBox(
                  //   height: 20,
                  // ),
                  // GestureDetector(
                  //   onTap: () {
                  //     debugPrint("Group");
                  //     Navigator.push(context,
                  //         MaterialPageRoute(builder: (context) {
                  //       return BlocProvider(
                  //         create: (context) => o.OrganizationBloc(),
                  //         child: MyOrganizationsScreen(),
                  //       );
                  //     }));
                  //   },
                  //   child: Row(
                  //     children: [
                  //       Padding(
                  //         padding: EdgeInsets.only(
                  //             top: 0, bottom: 8, left: 20, right: 8),
                  //         child: Icon(
                  //           Icons.people,
                  //           size: 42,
                  //           color: Colors.black54,
                  //         ),
                  //       ),
                  //       Padding(
                  //         padding: EdgeInsets.only(
                  //             top: 8, bottom: 8, left: 20, right: 8),
                  //         child: Column(
                  //           crossAxisAlignment: CrossAxisAlignment.start,
                  //           children: [
                  //             Text(
                  //               'Create and Manage Townhalls',
                  //               style: TextStyle(
                  //                   fontSize: 18, fontWeight: FontWeight.bold),
                  //             ),
                  //             Container(
                  //               width: size.width - 110,
                  //               child: Column(
                  //                 crossAxisAlignment: CrossAxisAlignment.start,
                  //                 children: [
                  //                   Text(
                  //                     'Create and Manage Townhalls. Delete and upgrade Townhalls',
                  //                     style: TextStyle(
                  //                         fontSize: 15,
                  //                         color: Colors.grey.shade700),
                  //                   ),
                  //                 ],
                  //               ),
                  //             )
                  //           ],
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  SizedBox(
                    height: 20,
                  ),
                  GestureDetector(
                    onTap: () async {
                      // BlocProvider.of<AuthBloc>(context).add(LogoutEvent());
                      // Navigation.intentWithClearAllRoutes(
                      //     context, LoginScreen.routeName);
                      // clearCache();
                    },
                    child: Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                              top: 0, bottom: 8, left: 20, right: 8),
                          child: Icon(
                            Icons.campaign_outlined,
                            color: Colors.black54,
                            size: 42,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              top: 8, bottom: 8, left: 20, right: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Advertise',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                              ),
                              Container(
                                  width: size.width - 110,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '+234 808 432 2878',
                                        style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.grey.shade700),
                                      ),
                                      Text(
                                        'contact@townhall.mobi',
                                        style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.grey.shade700),
                                      ),
                                    ],
                                  )
                                  // Text(
                                  //   'Promote your groups and services to millions of users',
                                  //   style: TextStyle(
                                  //       fontSize: 15,
                                  //       color: Colors.grey.shade700),
                                  // ),
                                  )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  // GestureDetector(
                  //   onTap: () async {
                  //     // BlocProvider.of<AuthBloc>(context).add(LogoutEvent());
                  //     // Navigation.intentWithClearAllRoutes(
                  //     //     context, LoginScreen.routeName);
                  //     // clearCache();
                  //   },
                  //   child: Row(
                  //     children: [
                  //       Padding(
                  //         padding: EdgeInsets.only(
                  //             top: 0, bottom: 8, left: 20, right: 8),
                  //         child: Icon(
                  //           Icons.person_add_outlined,
                  //           color: Colors.black54,
                  //           size: 42,
                  //         ),
                  //       ),
                  //       Padding(
                  //         padding: EdgeInsets.only(
                  //             top: 8, bottom: 8, left: 20, right: 8),
                  //         child: Column(
                  //           crossAxisAlignment: CrossAxisAlignment.start,
                  //           children: [
                  //             Text(
                  //               'Invite Friends',
                  //               style: TextStyle(
                  //                   fontSize: 18,
                  //                   fontWeight: FontWeight.bold,
                  //                   color: Colors.black),
                  //             ),
                  //             Container(
                  //               width: size.width - 110,
                  //               child: Text(
                  //                 'Send an invite to your friends and network to join Townhall',
                  //                 style: TextStyle(
                  //                     fontSize: 15,
                  //                     color: Colors.grey.shade700),
                  //               ),
                  //             )
                  //           ],
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  // SizedBox(
                  //   height: 20,
                  // ),
                  GestureDetector(
                    onTap: () async {
                      // BlocProvider.of<AuthBloc>(context).add(LogoutEvent());
                      // Navigation.intentWithClearAllRoutes(
                      //     context, LoginScreen.routeName);
                      // clearCache();
                    },
                    child: Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                              top: 0, bottom: 8, left: 25, right: 8),
                          child: ImageIcon(
                            AssetImage("images/icon_blue.png"),
                            color: Colors.black54,
                            size: 36.0,
                          ),
                          //  Icon(
                          //   Icons.person_add_outlined,
                          //   color: Colors.black54,
                          //   size: 42,
                          // ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              top: 8, bottom: 8, left: 20, right: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'About Townhall',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                              ),
                              Container(
                                width: size.width - 110,
                                child: Text(
                                  'v${_packageInfo.version}',
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.grey.shade700),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }
}
