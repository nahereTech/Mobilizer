import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:indexed/indexed.dart';
import 'package:intl/intl.dart';
import 'package:mobilizer/bloc/search/organization_bloc.dart';
// import 'package:mobilizer/bloc/search/people_bloc.dart';
// import 'package:mobilizer/bloc/social/social_bloc.dart';
import 'package:mobilizer/common/common/navigation.dart';
import 'package:mobilizer/common/common/sharepreference.dart';
import 'package:mobilizer/pages/comments/comments.dart';
import 'package:mobilizer/pages/feed/feed.dart';
import 'package:mobilizer/pages/home/home.dart';
import 'package:mobilizer/pages/organization/add_organizations.dart';
import 'package:mobilizer/pages/organization/organization_details.dart';
import 'package:mobilizer/pages/organization/organization_edit.dart';
import 'package:mobilizer/pages/people/people_profile.dart';
import 'package:mobilizer/bloc/posts/posts_bloc.dart' as po;
import 'package:mobilizer/models/organization/my_organization_response.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:getwidget/getwidget.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:http/http.dart' as http;

class MyOrganizationsScreen extends StatefulWidget {
  //final String? ref;
  const MyOrganizationsScreen({Key? key}) : super(key: key);
  static String routeName = 'my_organizations';

  @override
  MyOrganizationsScreenState createState() => MyOrganizationsScreenState();
}

class MyOrganizationsScreenState extends State<MyOrganizationsScreen> {
  List<OrganizationData> data = [];

  List<dynamic> _pinList = [];
  bool refresh = false;
  bool pressAttention = false;
  bool isSuccessful = false; //Query is successful
  bool isMember = false;
  String _clickedID = ""; //org_id
  int count = 0;
  bool loading = true; //loader
  bool noResult = false;
  void initState() {
    _getCachedData();
    Future.delayed(Duration.zero, () {
      BlocProvider.of<OrganizationBloc>(context).add(MyOrganizationsEvent());
    });
    super.initState();
  }

  // Tap location will be used use to position the context menu
  Offset _tapPosition = Offset.zero;
  void _getTapPosition(TapDownDetails details) {
    final RenderBox referenceBox = context.findRenderObject() as RenderBox;
    setState(() {
      _tapPosition = referenceBox.globalToLocal(details.globalPosition);
    });
    debugPrint("Tap: ${_tapPosition}");
  }

  @override
  Widget build(BuildContext contextA) {
    return WillPopScope(
      onWillPop: () async => !Loader.isShown,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 70,
          //automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          bottomOpacity: 0.0,
          elevation: 0.0,
          shadowColor: Colors.white,
          centerTitle: true,
          iconTheme: IconThemeData(
            color: Colors.blue, //change your color here
          ),
          title: Text(
            'Manage Organizations',
            style: TextStyle(color: Colors.black),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: GestureDetector(
                onTap: () async {
                  await Navigator.pushNamed(context, AddOrganization.routeName);
                },
                child: Text(
                  'Create',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 17,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: BlocConsumer<OrganizationBloc, OrganizationState>(
          buildWhen: (previousState, state) {
            return true;
          },
          listener: (context, state) {
            print("Listener has been called");
            if (state is MyOrganizationsState) {
              loading = false;
              isSuccessful = true;
              data = state.getOrganizationsResponse.data!;
              AppSharedPreferences.setValue(
                  key: 'page_my_organization', value: jsonEncode(data));
            }
            if (state is OrganizationLoadingState) {
              //loading = true;
              isSuccessful = false;
            }

            if (state is NoReturnState) {
              setState(() {
                loading = false;
                noResult = true;
                Loader.hide();
              });
            }
            if (state is NetworkState) {
              setState(() {
                loading = false;
                Loader.hide();
                noResult = false;
              });
              isSuccessful = false;
              print(state.message);
              // loading = false;
              final snackBar = SnackBar(
                  backgroundColor: Color(0xFFcf5555),
                  content: Text(state.message.toString()));
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            }
            if (state is LeaveState) {
              setState(() {
                loading = false;
                noResult = false;
                _clickedID = "";
              });
              print("Am inside leave view state");
              isSuccessful = true;
              BlocProvider.of<OrganizationBloc>(context)
                  .add(GetOrganizationEvent());
            }
            if (state is JoinState) {
              setState(() {
                loading = false;
                _clickedID = "";
              });
              print("Am inside join state");
              isSuccessful = true;
              BlocProvider.of<OrganizationBloc>(context)
                  .add(GetOrganizationEvent());
            }
          },
          builder: (contextA, state) {
            double width = MediaQuery.of(context).size.width;
            double height = MediaQuery.of(context).size.height;
            return Container(
              child: Indexer(
                children: [
                  if (loading)
                    Center(
                      child: Container(
                        width: 80.0,
                        height: 80.0,
                        child: SpinKitCircle(
                          color: Colors.blue,
                          size: 50.0,
                        ),
                      ),
                    ),
                  if (noResult)
                    Center(
                      child: Container(
                        child: Column(children: [
                          SizedBox(
                            height: height / 3.0,
                          ),
                          Text('No Group'),
                          Icon(
                            Icons.people,
                            size: 42,
                            color: Colors.black54,
                          ),
                        ]),
                      ),
                    ),
                  BlocProvider(
                    create: (context) => OrganizationBloc(),
                    child: Column(
                      children: [
                        Expanded(
                          child: loading
                              ? SizedBox(width: 1)
                              : ListView.builder(
                                  itemCount: data.length,
                                  itemBuilder: (context, index) {
                                    final organization = data[index];
                                    final backgroundColor = Color.fromARGB(255, 230, 230, 230);
                                    return Padding(
                                      padding: EdgeInsets.only(bottom: 15, left: 18, right: 18),
                                      child: Container(
                                        margin: EdgeInsets.only(bottom: 3),
                                        padding: EdgeInsets.only(left: 0, right: 0, top: 5, bottom: 5),
                                        decoration: BoxDecoration(
                                          color: backgroundColor,
                                          borderRadius: BorderRadius.circular(15),
                                        ),
                                        child: GestureDetector(
                                          behavior: HitTestBehavior.translucent,
                                          onTapDown: (details) => _getTapPosition(details),
                                          child: ListTile(
                                            onLongPress: () => _showContextMenu(contextA, index, organization.org_id.toString()),
                                            onTap: () async {
                                              var pageData = await getPageData('page_my_organization');
                                              print("Clicked OrgName: ${organization.org_name}");
                                              await AppSharedPreferences.setValue(
                                                  key: 'orgID', value: organization.org_id.toString());
                                              await AppSharedPreferences.setValue(
                                                  key: 'orgName', value: organization.org_name.toString());
                                              await AppSharedPreferences.removeValue(key: 'groupID');
                                              SharedPreferences prefs = await SharedPreferences.getInstance();
                                              Set<String> keys = prefs.getKeys();
                                              List<String> filteredKeys = keys.where((key) => key.contains("page_feed_")).toList();
                                              if (filteredKeys.length > 0) {
                                                for (var i = 0; i < filteredKeys.length; i++) {
                                                  await AppSharedPreferences.removeValue(key: '${filteredKeys[i]}');
                                                }
                                              }
                                              Navigator.push(context, MaterialPageRoute(builder: (context) {
                                                return BlocProvider(
                                                  create: (context) => po.PostsBloc(),
                                                  child: Feed(),
                                                );
                                              }));
                                            },
                                            title: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '${organization.org_name}',
                                                  style: TextStyle(fontWeight: FontWeight.bold),
                                                ),
                                                Text(
                                                  '@${organization.org_username}',
                                                  style: TextStyle(color: Colors.grey, fontWeight: FontWeight.normal),
                                                ),
                                              ],
                                            ),
                                            leading: CircleAvatar(
                                              radius: 25,
                                              backgroundColor: Colors.grey,
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(50),
                                                child: Image.network(
                                                  '${organization.org_image}',
                                                  width: 50,
                                                  height: 50,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            trailing: SizedBox(
                                              width: 30,
                                              child: PopupMenuButton(
                                                onSelected: (choice) {
                                                  if (choice == "Info/Edit") {
                                                    Navigator.push(context, MaterialPageRoute(builder: (context) {
                                                      return MultiBlocProvider(
                                                        providers: [
                                                          BlocProvider(create: (context) => OrganizationBloc()),
                                                          BlocProvider(create: (context) => po.PostsBloc()),
                                                        ],
                                                        child: OrganizationEdit(
                                                          orgId: organization.org_id.toString(),
                                                          picture: organization.org_image,
                                                          orgBg: organization.org_image,
                                                          orgName: organization.org_name,
                                                          username: organization.org_username,
                                                          orgAbout: organization.org_desc,
                                                          onSuccess: () {
                                                            // Refresh the organization list
                                                            setState(() {
                                                              loading = true;
                                                            });
                                                            BlocProvider.of<OrganizationBloc>(context).add(MyOrganizationsEvent());
                                                            Navigator.pop(context); // Return to MyOrganizationsScreen
                                                          },
                                                          onError: (message) {
                                                            // Show error message
                                                            ScaffoldMessenger.of(context).showSnackBar(
                                                              SnackBar(
                                                                content: Text(message),
                                                                backgroundColor: Colors.red,
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      );
                                                    }));
                                                  } else if (choice == "Share") {
                                                    share(
                                                      organization.org_image!,
                                                      organization.org_full_url!,
                                                      '',
                                                    );
                                                  }
                                                },
                                                itemBuilder: (BuildContext context) {
                                                  return [
                                                    'Info/Edit',
                                                    'Stats',
                                                    'Manage Leaders',
                                                    'Share'
                                                  ].map((String choice) {
                                                    return PopupMenuItem<String>(
                                                      value: choice,
                                                      child: Text(choice),
                                                    );
                                                  }).toList();
                                                },
                                                icon: ImageIcon(
                                                  AssetImage("images/dots.png"),
                                                  color: Colors.grey,
                                                  size: 20.0,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                )
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String? _getButtonText(member) {
    if (member == "yes") {
      return "Leave";
    } else if (member == "no") {
      return "Join";
    } else {
      return "Pending";
    }
  }

  Color _getButtonColor(member) {
    Color color;
    if (member == "yes") {
      color = Colors.red;
    } else if (member == "no") {
      color = Colors.blue;
    } else {
      color = Colors.grey;
    }
    return color;
  }

  void _loadEndPoint(String member, String orgID) {
    print("Member: ${member}");
    if (member == "Leave") {
      Alert(
        context: context,
        style: AlertStyle(
            titleStyle: TextStyle(fontWeight: FontWeight.bold),
            overlayColor: Colors.black54),
        title: "Confirm",
        desc:
            "Are you sure you want to leave this organization? You will need to join and be approved to get back in",
        buttons: [
          DialogButton(
            color: Colors.black45,
            child: Text(
              "No",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: () {
              Navigator.pop(context);
              _clickedID = "";
            },
            width: 120,
          ),
          DialogButton(
            child: Text(
              "Yes",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: () {
              BlocProvider.of<OrganizationBloc>(context)
                  .add(LeaveEvent(org_id: orgID.toString()));
              Navigator.pop(context);
            },
            width: 120,
          )
        ],
      ).show();
    } else if (member == "Join") {
      Alert(
        context: context,
        style: AlertStyle(
            titleStyle: TextStyle(fontWeight: FontWeight.bold),
            overlayColor: Colors.black54),
        title: "Confirm",
        desc:
            "Are you sure you want to join? Your join request will be pending till approved by organization",
        buttons: [
          DialogButton(
            color: Colors.black45,
            child: Text(
              "No",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: () {
              Navigator.pop(context);
              _clickedID = "";
            },
            width: 120,
          ),
          DialogButton(
            child: Text(
              "Yes",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: () {
              BlocProvider.of<OrganizationBloc>(context)
                  .add(JoinEvent(org_id: orgID.toString()));
              Navigator.pop(context);
            },
            width: 120,
          )
        ],
      ).show();
    } else if (member == "Pending") {
      Alert(
        context: context,
        style: AlertStyle(
            titleStyle: TextStyle(fontWeight: FontWeight.bold),
            overlayColor: Colors.black54),
        title: "Confirm",
        desc:
            "Are you sure you want to cancel? Your pending join request will be terminated if you cancel?",
        buttons: [
          DialogButton(
            color: Colors.black45,
            child: Text(
              "No",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _clickedID = "";
              });
            },
            width: 120,
          ),
          DialogButton(
            child: Text(
              "Yes",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: () {
              BlocProvider.of<OrganizationBloc>(context)
                  .add(LeaveEvent(org_id: orgID.toString()));
              Navigator.pop(context);
            },
            width: 120,
          )
        ],
      ).show();
    }
  }

  _getCachedData() async {
    var pageData = await getPageData('page_my_organization');
    if (pageData != null) {
      var json = jsonDecode(pageData);
      setState(() {
        data = json
            .map<OrganizationData>((json) => OrganizationData.fromJson(json))
            .toList();
        loading = false;
      });
      // print("My Data: ${data[0].message}");
    }
  }

  void _showContextMenu(BuildContext context, int indexID, String orgID) async {
    final RenderObject? overlay =
        Overlay.of(context)?.context.findRenderObject();

    final result = await showMenu(
      context: context,

      // Show the context menu at the tap location
      position: RelativeRect.fromRect(
          Rect.fromLTWH(_tapPosition.dx, _tapPosition.dy, 30, 30),
          Rect.fromLTWH(0, 0, overlay!.paintBounds.size.width,
              overlay.paintBounds.size.height)),

      // set a list of choices for the context menu
      items: [
        PopupMenuItem(
          value: 'Info',
          child: Text('Info'),
        ),
        PopupMenuItem(
          onTap: () {
            setState(() {
              _clickedID = indexID.toString();
            });
            if (_pinList[indexID] == "no") {
              BlocProvider.of<OrganizationBloc>(context)
                  .add(PinToTopEvent(org_id: orgID));
            } else {
              BlocProvider.of<OrganizationBloc>(context)
                  .add(UnpinFromTopEvent(org_id: orgID));
            }
            Loader.show(
              context,
              //isSafeAreaOverlay: false,
              //isBottomBarOverlay: false,
              //overlayFromBottom: 80,
              overlayColor: Colors.black26,
              progressIndicator: Container(
                width: 200.0,
                height: 120.0,
                child: Column(
                  children: [
                    SpinKitCircle(
                      color: Colors.blue,
                      size: 45.0,
                    ),
                    Text(
                      '${_pinList[indexID] == "yes" ? "unpin" : "pin"}ing...',
                      style: TextStyle(
                          fontSize: 17,
                          decoration: TextDecoration.none,
                          color: Colors.black54),
                    )
                  ],
                ),
              ),
            );
          },
          value: '${_pinList[indexID] == "yes" ? "Unpin From" : "Pin To"} Top',
          child: Text(
              '${_pinList[indexID] == "yes" ? "Unpin From" : "Pin To"} Top'),
        ),
      ],
    );

    // Implement the logic for each choice here
    switch (result) {
      case 'Info':
        _openOrganizationScreen(context, indexID);
        break;
      case 'Pin To Top':
        debugPrint('Pin To Top');
        break;
    }
  }

  Future<void> share(String orgImage, String text, String title) async {
    final box = context.findRenderObject() as RenderBox?;
    final imageUrl = "https://empl-dev.site/image1.jpg";
    final url = Uri.parse(imageUrl);
    final response = await http.get(url);
    final bytes = response.bodyBytes;
    final temp = await getTemporaryDirectory();
    final path = '${temp.path}/image.jpg';
    File(path).writeAsBytesSync(bytes);
    // if (imageList.length > 0) {
    await Share.shareXFiles([XFile(path)],
        text: text,
        //subject: title,
        sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size);
    //}
    //} else {
    //   Share.shareXFiles([orgImage],,sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size)
    // // await Share.share(text,
    //     subject: title,
    //     sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size);
    //}
  }

  Future<void> _openOrganizationScreen(
      BuildContext context, int indexID) async {
    Navigator.pushNamed(context, OrganizationDetails.routeName,
        arguments: data[indexID]);
  }

  String _substring(String char, int count) {
    return char.length > count ? char.substring(0, count) + '...' : char;
  }

  Future<String?> getPageData(String value) async {
    return await AppSharedPreferences.getValue(key: value);
  }
}
