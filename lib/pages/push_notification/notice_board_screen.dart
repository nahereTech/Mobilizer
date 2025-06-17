import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mobilizer/bloc/auth/auth_bloc.dart';
import 'package:mobilizer/bloc/events/events_bloc.dart';
import 'package:mobilizer/bloc/messages/messages_bloc.dart';
import 'package:mobilizer/bloc/posts/posts_bloc.dart' as po;
import 'package:mobilizer/bloc/search/organization_bloc.dart';
import 'package:mobilizer/bloc/search/people_bloc.dart';
import 'package:mobilizer/common/common/navigation.dart';
import 'package:mobilizer/common/common/sharepreference.dart';
import 'package:mobilizer/pages/home/home.dart';
import 'package:mobilizer/pages/login/login.dart';
import 'package:mobilizer/pages/organization/organization.dart';
import 'package:mobilizer/pages/settings/settings.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timer_snackbar/timer_snackbar.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:mobilizer/common/common/constants.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mobilizer/bloc/auth/auth_bloc.dart' as a;
import 'package:mobilizer/bloc/search/people_bloc.dart' as p;
import 'package:mobilizer/bloc/search/organization_bloc.dart' as o;
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';

class NoticeBoardScreen extends StatefulWidget {
  static String routeName = 'register2_screen';

  const NoticeBoardScreen({Key? key}) : super(key: key);

  @override
  _NoticeBoardScreenState createState() => _NoticeBoardScreenState();
}

class _NoticeBoardScreenState extends State<NoticeBoardScreen> {
  final _controllerEmail = TextEditingController();
  var loadingPercentage = 0;
  bool loading = false;
  bool _showShimmerLoader = true;
  // late WebViewController _controller;
  late final WebViewController _controller;
  String _profileImage = "";

  String _deviceType = "";
  String _nType = "";
  String _itemID = "";
  String? _orgName;
  String? _orgID;
  String? _groupID;
  String _htmlData = "";

  @override
  void initState() {
    super.initState();
    initPlatformState();
    _setProfilePic();
    Future.delayed(Duration.zero, () {
      final args = ModalRoute.of(context)!.settings.arguments as Map;
      BlocProvider.of<po.PostsBloc>(context).add(
        po.ShowNoticeBoardEvent(),
      );
      setState(() {
        _nType = args['n_type'];
        _itemID = args['item_id'];
        _orgID = args['org_id'];
        _groupID = args['townhall_id'];
        _orgName = args['org_name'];
        AppSharedPreferences.setValue(key: 'orgID', value: _orgID!);
        AppSharedPreferences.setValue(key: 'orgName', value: _orgName!);
        AppSharedPreferences.setValue(key: 'groupID', value: _groupID!);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Material(
      child: WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: Scaffold(
          body: SafeArea(
            child: BlocConsumer<po.PostsBloc, po.PostsState>(
              listener: (context, state) {
                if (state is po.ShowNoticeBoardState) {
                  setState(() {
                    _htmlData = state.htmlMessage;
                    _showShimmerLoader = false;
                  });
                }
                if (state is po.ErrorState) {
                  setState(() {
                    _showShimmerLoader = false;
                  });
                }
                if (state is po.NetworkState) {
                  setState(() {
                    _showShimmerLoader = false;
                  });
                }
              },
              builder: (context, state) {
                return Column(
                  children: [
                    SizedBox(
                      height: 1.0,
                    ),
                    Column(
                      children: [
                        GestureDetector(
                          onTap: () async {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return BlocProvider(
                                create: (context) => o.OrganizationBloc(),
                                child: OrganizationScreen(),
                              );
                            }));
                          },
                          child: Container(
                            padding: EdgeInsets.only(
                                left: 1.0, right: 6.0, top: 2.0),
                            height: 50.0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    IconButton(
                                      iconSize: 15,
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) {
                                            return MultiBlocProvider(
                                                providers: [
                                                  BlocProvider(
                                                    create: (context) =>
                                                        AuthBloc(),
                                                  ),
                                                  BlocProvider(
                                                    create: (context) =>
                                                        EventsBloc(),
                                                  ),
                                                  BlocProvider(
                                                    create: (context) =>
                                                        MessagesBloc(),
                                                  ),
                                                  BlocProvider(
                                                    create: (context) =>
                                                        PeopleBloc(),
                                                  ),
                                                  BlocProvider(
                                                    create: (context) =>
                                                        po.PostsBloc(),
                                                  ),
                                                  BlocProvider(
                                                    create: (context) =>
                                                        OrganizationBloc(),
                                                  ),
                                                ],
                                                child: HomeScreen());
                                          }),
                                        );
                                      },
                                      icon: FaIcon(
                                        FontAwesomeIcons.arrowLeft,
                                        size: 25,
                                        color: Colors.blue,
                                      ),
                                    )
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    _orgName == null
                                        ? SizedBox()
                                        : Container(
                                            height: 30,
                                            //width: 120,
                                            padding: EdgeInsets.only(left: 5),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Colors.blue,
                                                width: 1,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Row(
                                              children: [
                                                Text(
                                                  "${_orgName == null ? '' : _substring(_orgName.toString(), 10)}",
                                                  style: TextStyle(
                                                      color: Colors.blue),
                                                ),
                                                SizedBox(
                                                  width: 25,
                                                  child: IconButton(
                                                    padding: EdgeInsets.only(
                                                        bottom: 3, right: 20.0),
                                                    onPressed: () async {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    iconSize: 20,
                                                    icon: Icon(
                                                      Icons.keyboard_arrow_down,
                                                      color: Colors.blue,
                                                      //size: 30,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(context,
                                            MaterialPageRoute(
                                                builder: (context) {
                                          return BlocProvider(
                                            create: (context) => a.AuthBloc(),
                                            child: Settings(),
                                          );
                                        }));
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 8.0, right: 8.0),
                                        child: CircleAvatar(
                                          radius: 15,
                                          backgroundColor: Colors.lightBlue,
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(25),
                                            child: Image.network(
                                              _profileImage == ""
                                                  ? 'https://${domainName}/files/images/user_profile_images/mid_default.png'
                                                  : _profileImage,
                                              width: 55,
                                              height: 55,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        Divider(
                          thickness: 0.1,
                          color: Colors.black,
                        ),
                      ],
                    ),
                    if (_showShimmerLoader == false && _htmlData == "")
                      Center(
                        child: Text("No message"),
                      ),
                    if (_showShimmerLoader) shimmerLoading(),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.only(
                            left: 16, right: 16, top: 16, bottom: 16),
                        child: SingleChildScrollView(
                          child: HtmlWidget(_htmlData),
                        ),
                      ),
                    )
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<void> initPlatformState() async {
    var deviceData = <String, dynamic>{};
    try {
      if (Platform.isAndroid) {
        _deviceType = "Android";
      } else if (Platform.isIOS) {
        _deviceType = "IOS";
      } else if (Platform.isLinux) {
        _deviceType = "Linux";
      } else if (Platform.isMacOS) {
        _deviceType = "MacOS";
      } else if (Platform.isWindows) {
        _deviceType = "Window";
      }
    } on PlatformException {
      deviceData = <String, dynamic>{
        'Error:': 'Failed to get platform version.'
      };
    }
    print("My device type: ${_deviceType}");
  }

  Future<String?> getDeviceToken() async {
    return await AppSharedPreferences.getValue(key: 'deviceToken');
  }

  Future<String?> _getProfilePic() async {
    return await AppSharedPreferences.getValue(key: 'profilePic');
  }

  void _setProfilePic() async {
    var picture = await _getProfilePic();
    setState(() {
      _profileImage = picture!;
    });
  }

  String _substring(String char, int count) {
    return char.length > count ? char.substring(0, count) + '...' : char;
  }

  Future<String?> getTownhallView() async {
    return await AppSharedPreferences.getValue(key: 'townhallView');
  }

  Widget shimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      direction: ShimmerDirection.ltr,
      enabled: true,
      child: Column(
        children: [
          Padding(
              padding: const EdgeInsets.only(top: 25),
              child: Container(
                color: null,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(9.0, 9.0, 6.0, 8.0),
                      child: CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.grey,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.asset(
                            "images/profile1.jpeg",
                            width: 55,
                            height: 55,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 4.0, bottom: 1.0, left: 7.0, right: 4.0),
                              child: Row(
                                children: [
                                  Container(
                                    width: 230,
                                    padding: EdgeInsets.only(left: 7, right: 7),
                                    decoration: BoxDecoration(
                                        color: Colors.lightBlue, //0xffCCE9FD
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(1))),
                                    alignment: Alignment.centerLeft,
                                    height: 18,
                                    child: SizedBox(),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: 4.0,
                                      right: 4.0,
                                      left: 5.0,
                                      top: 7),
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 315,
                                        padding:
                                            EdgeInsets.only(left: 7, right: 7),
                                        decoration: BoxDecoration(
                                            color:
                                                Colors.lightBlue, //0xffCCE9FD
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(1))),
                                        alignment: Alignment.centerLeft,
                                        height: 18,
                                        child: SizedBox(),
                                      ),
                                      SizedBox(height: 8),
                                      Container(
                                        width: 315,
                                        padding:
                                            EdgeInsets.only(left: 7, right: 7),
                                        decoration: BoxDecoration(
                                            color:
                                                Colors.lightBlue, //0xffCCE9FD
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(1))),
                                        alignment: Alignment.centerLeft,
                                        height: 18,
                                        child: SizedBox(),
                                      ),
                                      SizedBox(height: 8),
                                      Container(
                                        width: 315,
                                        padding:
                                            EdgeInsets.only(left: 7, right: 7),
                                        decoration: BoxDecoration(
                                            color:
                                                Colors.lightBlue, //0xffCCE9FD
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(1))),
                                        alignment: Alignment.centerLeft,
                                        height: 18,
                                        child: SizedBox(),
                                      ),
                                      //SizedBox(height: 15),

                                      Column(
                                        children: [
                                          Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 20),
                                              child: Container(
                                                color: null,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets
                                                              .fromLTRB(
                                                          9.0, 9.0, 6.0, 8.0),
                                                      child: CircleAvatar(
                                                        radius: 25,
                                                        backgroundColor:
                                                            Colors.grey,
                                                        child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(50),
                                                          child: Image.asset(
                                                            "images/profile1.jpeg",
                                                            width: 45,
                                                            height: 45,
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(1.0),
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .stretch,
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      top: 4.0,
                                                                      bottom:
                                                                          1.0,
                                                                      left: 4.0,
                                                                      right:
                                                                          4.0),
                                                              child: Row(
                                                                children: [
                                                                  Container(
                                                                    width: 160,
                                                                    padding: EdgeInsets.only(
                                                                        left: 7,
                                                                        right:
                                                                            7),
                                                                    decoration:
                                                                        BoxDecoration(
                                                                            color:
                                                                                Colors.lightBlue, //0xffCCE9FD
                                                                            borderRadius: BorderRadius.all(Radius.circular(1))),
                                                                    alignment:
                                                                        Alignment
                                                                            .centerLeft,
                                                                    height: 18,
                                                                    child:
                                                                        SizedBox(),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Padding(
                                                                  padding: const EdgeInsets
                                                                          .only(
                                                                      bottom:
                                                                          4.0,
                                                                      right:
                                                                          4.0,
                                                                      left: 5.0,
                                                                      top: 7),
                                                                  child: Column(
                                                                    children: [
                                                                      Container(
                                                                        width:
                                                                            315,
                                                                        padding: EdgeInsets.only(
                                                                            left:
                                                                                7,
                                                                            right:
                                                                                7),
                                                                        decoration: BoxDecoration(
                                                                            color: Colors.lightBlue, //0xffCCE9FD
                                                                            borderRadius: BorderRadius.all(Radius.circular(1))),
                                                                        alignment:
                                                                            Alignment.centerLeft,
                                                                        height:
                                                                            18,
                                                                        child:
                                                                            SizedBox(),
                                                                      ),
                                                                      SizedBox(
                                                                          height:
                                                                              8),
                                                                      Container(
                                                                        width:
                                                                            315,
                                                                        padding: EdgeInsets.only(
                                                                            left:
                                                                                7,
                                                                            right:
                                                                                7),
                                                                        decoration: BoxDecoration(
                                                                            color: Colors.lightBlue, //0xffCCE9FD
                                                                            borderRadius: BorderRadius.all(Radius.circular(1))),
                                                                        alignment:
                                                                            Alignment.centerLeft,
                                                                        height:
                                                                            18,
                                                                        child:
                                                                            SizedBox(),
                                                                      ),
                                                                      SizedBox(
                                                                          height:
                                                                              20),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            // if(_imageList.length > 0)
                                                            //  ImageSwipe(
                                                            //                                                 imageList:
                                                            //                                                     _imageList),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )),
                                          Divider(),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 28,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: ImageIcon(
                          AssetImage("images/dots.png"),
                          color: Colors.grey,
                          size: 20.0,
                        ),
                      ),
                    ),
                    Divider(),
                  ],
                ),
              )),
          Divider(),
        ],
      ),
    );
  }
}
