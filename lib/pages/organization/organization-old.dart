import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:indexed/indexed.dart';
import 'package:intl/intl.dart';
import 'package:mobilizer/bloc/posts/posts_bloc.dart' as p;
import 'package:mobilizer/bloc/search/organization_bloc.dart';
// import 'package:mobilizer/bloc/search/people_bloc.dart';
// import 'package:mobilizer/bloc/social/social_bloc.dart';
import 'package:mobilizer/common/common/navigation.dart';
import 'package:mobilizer/common/common/sharepreference.dart';
import 'package:mobilizer/models/organization/organization_ccf_response.dart';
import 'package:mobilizer/pages/comments/comments.dart';
import 'package:mobilizer/pages/feed/feed.dart';
import 'package:mobilizer/pages/home/home.dart';
import 'package:mobilizer/pages/organization/organization_details.dart';
import 'package:mobilizer/pages/organization/organization_edit.dart';
import 'package:mobilizer/pages/people/people_profile.dart';
import 'package:mobilizer/models/organization/organization_response.dart';
// import 'package:getwidget/getwidget.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';

class OrganizationScreen extends StatefulWidget {
  //final String? ref;
  const OrganizationScreen({Key? key}) : super(key: key);
  static String routeName = 'search_organization';

  @override
  OrganizationScreenState createState() => OrganizationScreenState();
}

class OrganizationScreenState extends State<OrganizationScreen> {
  List<OrganizationData> data = [];
  List<dynamic> _pinList = [];
  bool refresh = false;
  bool pressAttention = false;
  bool isSuccessful = false; //Query is successful
  bool isMember = false;
  String _clickedID = ""; //org_id
  int count = 0;
  bool loading = true; //loader
  bool _showCCFLoader = false;

  void initState() {
    _getCachedData();
    Future.delayed(Duration.zero, () {
      BlocProvider.of<OrganizationBloc>(context).add(GetOrganizationEvent());
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
            'Joined Townhalls',
            style: TextStyle(color: Colors.black),
          ),
          // actions: [
          //   Padding(
          //     padding: const EdgeInsets.only(top: 30.0, right: 16),
          //     child: Text(
          //       'Create',
          //       style: TextStyle(
          //         color: Colors.blue,
          //       ),
          //     ),
          //   ),
          // ],
        ),
        body: BlocConsumer<OrganizationBloc, OrganizationState>(
          buildWhen: (previousState, state) {
            return true;
          },
          listener: (context, state) {
            print("Listener has been called");
            if (state is GetOrganizationState) {
              print("Am state");
              loading = false;
              isSuccessful = true;
              data = state.getOrganizationResponse.data;
              AppSharedPreferences.setValue(
                  key: 'page_organization', value: jsonEncode(data));
            }
            if (state is OrganizationLoadingState) {
              //loading = true;
              isSuccessful = false;
            }
            if (state is PinState) {
              print("Pin state recieved");
              setState(() {
                _pinList[int.parse(_clickedID)] = "yes";
              });
              data[int.parse(_clickedID)].pinned = "yes";
              AppSharedPreferences.setValue(
                  key: 'page_organization', value: jsonEncode(data));
              Loader.hide();
              final snackBar = SnackBar(
                content: Text('Organization was successfully pinned to top'),
                backgroundColor: Colors.green.shade300,
              );
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            }
            if (state is UnpinState) {
              print("unPin state recieved");
              data[int.parse(_clickedID)].pinned = "no";
              AppSharedPreferences.setValue(
                  key: 'page_organization', value: jsonEncode(data));
              final snackBar = SnackBar(
                content:
                    Text('Organization was successfully unpinned from the top'),
                backgroundColor: Colors.green.shade300,
              );
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
              setState(() {
                _pinList[int.parse(_clickedID)] = "no";
              });
              Loader.hide();
            }
            if (state is NoReturnState) {
              loading = false;
              isSuccessful = true;
            }
            if (state is NetworkState) {
              setState(() {
                loading = false;
                Loader.hide();
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
                  BlocProvider(
                    create: (context) => OrganizationBloc(),
                    child: Column(
                      children: [
                        Expanded(
                          child: loading
                              ? SizedBox(width: 1)
                              : ListView.separated(
                                  separatorBuilder:
                                      (BuildContext context, int index) =>
                                          Column(
                                            children: [
                                              SizedBox(
                                                height: 5,
                                              ),
                                              Divider(height: 2),
                                              SizedBox(
                                                height: 10,
                                              )
                                            ],
                                          ),
                                  itemCount: data.length,
                                  itemBuilder: (context, index) {
                                    final organization = data[index];
                                    final isDeleteAdd = new Map();
                                    isDeleteAdd[data[index].org_id] =
                                        organization.member == "yes"
                                            ? true
                                            : false;
                                    isMember = organization.member == "yes"
                                        ? true
                                        : false;
                                    _pinList.add(organization.pinned);

                                    return GestureDetector(
                                      behavior: HitTestBehavior.translucent,
                                      onTapDown: (details) =>
                                          _getTapPosition(details),
                                      child: ListTile(
                                        onLongPress: () => _showContextMenu(
                                            contextA,
                                            index,
                                            organization.org_id.toString(),
                                            organization.org_name.toString(),
                                            organization.townhall_id.toString(),
                                            organization
                                                .can_update_subtownhalls),
                                        onTap: () async {
                                          var pageData = await getPageData(
                                              'page_organization');
                                          print(
                                              "Missing: ${organization.missing_custom_org_townhalls}");
                                          if (organization
                                              .missing_custom_org_townhalls) {
                                            setState(() {
                                              _showCCFLoader = true;
                                            });

                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return BlocProvider(
                                                  create: (context) =>
                                                      OrganizationBloc(),
                                                  child: MyDialogu(
                                                    orgName: organization
                                                        .org_name
                                                        .toString(),
                                                    townhallID: organization
                                                        .townhall_id
                                                        .toString(),
                                                    orgID: organization.org_id
                                                        .toString(),
                                                  ),
                                                );
                                              },
                                            );
                                          } else {
                                            if (pageData != null) {
                                              var json = jsonDecode(pageData);

                                              data = json
                                                  .map<OrganizationData>(
                                                      (json) => OrganizationData
                                                          .fromJson(json))
                                                  .toList();
                                              data[index].unread = 0;
                                              AppSharedPreferences.setValue(
                                                  key: 'page_organization',
                                                  value: jsonEncode(data));
                                            }

                                            print(
                                                "Clicked OrgName: ${organization.org_name}");
                                            await AppSharedPreferences.setValue(
                                                key: 'orgID',
                                                value: organization.org_id
                                                    .toString());

                                            await AppSharedPreferences.setValue(
                                                key: 'orgName',
                                                value: organization.org_name
                                                    .toString());
                                            await AppSharedPreferences.setValue(
                                                key: 'groupID', value: '');

                                            SharedPreferences prefs =
                                                await SharedPreferences
                                                    .getInstance();
                                            Set<String> keys = prefs.getKeys();
                                            List<String> filteredKeys = keys
                                                .where((key) =>
                                                    key.contains("page_feed_"))
                                                .toList();

                                            if (filteredKeys.length > 0) {
                                              for (var i = 0;
                                                  i < filteredKeys.length;
                                                  i++) {
                                                await AppSharedPreferences
                                                    .removeValue(
                                                        key:
                                                            '${filteredKeys[i]}');
                                              }
                                            }
                                            Navigator.push(context,
                                                MaterialPageRoute(
                                                    builder: (context) {
                                              return BlocProvider(
                                                create: (context) =>
                                                    p.PostsBloc(),
                                                child: Feed(),
                                              );
                                            }));
                                          }
                                        },
                                        title: Text(
                                          '${organization.org_name.toString().length > 30 ? _substring(organization.org_name.toString(), 31) : organization.org_name}',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        subtitle:
                                            Text('${organization.org_about}'),
                                        leading: CircleAvatar(
                                          radius: 25,
                                          backgroundColor: Colors.grey,
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(50),
                                            child: Image.network(
                                              '${organization.picture}',
                                              width: 50,
                                              height: 50,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        trailing: organization.unread! < 1
                                            ? SizedBox()
                                            : Container(
                                                width: 30,
                                                height: 30,
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                    color: Colors.red,
                                                    shape: BoxShape.circle),
                                                child: Text(
                                                  "${NumberFormat.compact().format(organization.unread ?? 0)}",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12),
                                                ),
                                              ),
                                      ),
                                    );
                                  }),
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
    var pageData = await getPageData('page_organization');
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

  void _showContextMenu(BuildContext context, int indexID, String orgID,
      String orgName, String townhallID, bool can_update_subtownhalls) async {
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
        if (can_update_subtownhalls)
          PopupMenuItem(
            value: 'Edit Sub Townhalls',
            child: Text('Edit Sub Townhalls'),
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
      case 'Edit Sub Townhalls':
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return BlocProvider(
              create: (context) => OrganizationBloc(),
              child: MyDialogu(
                orgName: orgName,
                townhallID: townhallID,
                orgID: orgID,
              ),
            );
          },
        );
        break;
      case 'Pin To Top':
        debugPrint('Pin To Top');
        break;
    }
  }

  // _showDialogue(BuildContext context, String orgName) {
  //   return showDialog(
  //       context: context,
  //       barrierColor: Colors.grey.withOpacity(0.5),
  //       barrierDismissible: false,
  //       builder: (context) {
  //         return StatefulBuilder(builder: (context, setState) {
  //           return AlertDialog(
  //             shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.all(
  //                 Radius.circular(12),
  //               ),
  //             ),
  //             title: Align(
  //               alignment: Alignment.topRight,
  //               child: GestureDetector(
  //                 onTap: () {
  //                   Navigator.pop(context);
  //                 },
  //                 child: Icon(
  //                   Icons.close,
  //                   size: 20,
  //                   color: Colors.grey,
  //                 ),
  //               ),
  //             ),
  //             content: Column(
  //               mainAxisSize: MainAxisSize.min,
  //               mainAxisAlignment: MainAxisAlignment.end,
  //               crossAxisAlignment: CrossAxisAlignment.center,
  //               children: [
  //                 Flexible(
  //                   flex: 1,
  //                   child: Text(
  //                     orgName,
  //                     style:
  //                         TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
  //                   ),
  //                 ),
  //                 _showCCFLoader
  //                     ? SpinKitWave(
  //                         color: Colors.grey,
  //                         size: 15.0,
  //                       )
  //                     : Column(
  //                         mainAxisAlignment: MainAxisAlignment.center,
  //                         children: dropdowns.map<Widget>((dropdown) {
  //                           return Padding(
  //                             padding: EdgeInsets.all(8.0),
  //                             child: dropdown,
  //                           );
  //                         }).toList(),
  //                       ),
  //               ],
  //             ),
  //           );
  //         });
  //       });
  // }

  String _substring(String char, int count) {
    return char.length > count ? char.substring(0, count) + '...' : char;
  }

  Future<void> _openOrganizationScreen(
      BuildContext context, int indexID) async {
    Navigator.pushNamed(context, OrganizationDetails.routeName,
        arguments: data[indexID]);
  }

  Future<String?> getPageData(String value) async {
    return await AppSharedPreferences.getValue(key: value);
  }
}

class MyDialogu extends StatefulWidget {
  final String orgName;
  final String townhallID;
  final String orgID;

  const MyDialogu(
      {required this.orgName, required this.townhallID, required this.orgID});
  @override
  State<MyDialogu> createState() => _MyDialoguState();
}

class _MyDialoguState extends State<MyDialogu> {
  bool _showCCFLoader = true;
  bool _isSubmitting = false;
  bool _hasLevel = false;
  int reqCounts = 0;
  int _widgetPosition = -1;
  int initPosition = 0;
  var wid = 0;
  double boxHeight = 111.0;
  List<Data> ccfData = [];
  Data? selectedValue = null;
  List<Widget> addedWidgets = [];
  List selectedTownhalls = [];
  final ScrollController _scrollController = ScrollController();
  void initState() {
    Future.delayed(Duration.zero, () {
      BlocProvider.of<OrganizationBloc>(context)
          .add(GetCCFEvent(townhall_id: widget.townhallID));
    });
    super.initState();
  }

  void onChangAction(int dropdownID) {
    setState(() {
      initPosition = dropdownID;
      _widgetPosition = dropdownID;
    });
    print("New: " + _widgetPosition.toString());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(12),
        ),
      ),
      title: Align(
        alignment: Alignment.topRight,
        child: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.close,
            size: 20,
            color: Colors.grey,
          ),
        ),
      ),
      content: BlocConsumer<OrganizationBloc, OrganizationState>(
          buildWhen: (previousState, state) {
        return true;
      }, listener: (contextA, state) {
        print("Listener has been called");

        if (state is OrganizationLoadingState) {
          //loading = true;
          //isSuccessful = false;
        }
        if (state is CCFState) {
          setState(() {
            reqCounts++;
            ccfData = state.CCFResponse.data!;
            _showCCFLoader = false;
            _isSubmitting = false;
            boxHeight += 58.0;
            if (addedWidgets.length < 2) {
              _hasLevel = true;
            }
          });
          setState(() {
            _widgetPosition += 1;
          });

          addedWidgets.add(_buildDropDownMenu(
              ccfData, state.CCFResponse.another_one!, _widgetPosition));
        }
        if (state is NoCCFState) {
          setState(() {
            _showCCFLoader = false;
            _isSubmitting = false;
          });
        }

        if (state is UpdateUsersTownhallsState) {
          setState(() {
            reqCounts = 0;
            _showCCFLoader = false;
            Loader.hide();
          });
          AppSharedPreferences.setValue(
              key: 'orgName', value: widget.orgName.toString());
          AppSharedPreferences.setValue(
              key: 'orgID', value: widget.orgID.toString());
          Navigation.intentWithClearAllRoutes(context, HomeScreen.routeName);
        }
        if (state is OrganizationErrorState) {
          setState(() {
            _showCCFLoader = false;
            _isSubmitting = false;
            Loader.hide();
          });
          final snackBar = SnackBar(
            content: Text(state.message!),
            backgroundColor: Colors.red,
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      }, builder: (_, state) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              flex: 1,
              child: Text(
                widget.orgName,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Container(
              width: double.maxFinite,
              height: boxHeight,
              child: Column(
                children: [
                  ListView.builder(
                    controller: _scrollController,
                    itemCount: addedWidgets.length,
                    itemBuilder: (context, index) {
                      return addedWidgets[index];
                    },
                    shrinkWrap: true, // Set shrinkWrap to true
                  ),
                  if (_showCCFLoader)
                    SpinKitWave(
                      color: Colors.grey,
                      size: 15.0,
                    ),
                  Container(
                    width: 370,
                    height: 75,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding: EdgeInsets.only(left: 1.0, right: 1.0, top: 26.0),
                    child: ElevatedButton(
                      onPressed: _showCCFLoader || _hasLevel || _isSubmitting
                          ? null
                          : () {
                              //final List<int> selT = [190868, 190872];

                              Map<String, dynamic> map = Map();
                              map['org_id'] = widget.orgID;
                              List uniqueTownhallList = [];
                              if (selectedTownhalls.length > 0) {
                                selectedTownhalls.sort((a, b) =>
                                    a["position"].compareTo(b["position"]));
                                uniqueTownhallList =
                                    removeDuplicate(selectedTownhalls);
                                for (int i = 0;
                                    i < uniqueTownhallList.length;
                                    i++) {
                                  map["townhall_ids[" + i.toString() + "]"] =
                                      uniqueTownhallList[i];
                                }
                              }
                              setState(() {
                                _isSubmitting = true;
                              });
                              //print(map);
                              // Map<String, dynamic> map = {
                              //   'townhall_ids': uniqueTownhallList,
                              //   'org_id': widget.orgID,
                              //   'with_index': 'yes'
                              // };
                              print(map);

                              BlocProvider.of<OrganizationBloc>(context).add(
                                UpdateUsersTownhallsEvent(
                                    updateUsersTownhallsRequest: map),
                              );
                            },
                      child: _isSubmitting
                          ? SpinKitWave(
                              color: Colors.grey,
                              size: 15.0,
                            )
                          : Text(
                              'Update',
                              style: TextStyle(fontSize: 20),
                            ),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12), // <-- Radius
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  List removeDuplicate(List townhalls) {
    List uniqueList = [];

    townhalls.forEach((element) {
      if (uniqueList.contains(element['townhallID']) == false) {
        uniqueList.add(element['townhallID']);
      }
    });
    return uniqueList;
  }

  Widget _buildDropDownMenu(
      List<Data> items, String anotherOne, int widgetPosition) {
    print('Position ${widgetPosition}');

    items.insertAll(0, [
      Data(
        townhall_id: -1,
        name: '-- Please Select --',
      ),
    ]);
    selectedValue = items[0]; // Set initial value
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      width: 390,
      height: 55,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          // set border width
          borderRadius: const BorderRadius.all(
            Radius.circular(15.0),
          ) // set rounded corner radius
          ),
      child: DropdownButtonFormField<Data>(
        value: selectedValue,
        elevation: 16,
        style: const TextStyle(color: Colors.black),
        icon: Icon(Icons.arrow_drop_down),
        decoration: InputDecoration(border: InputBorder.none),
        iconSize: 26,
        hint: Text(
          "Please Select                                         ",
          style: TextStyle(
            fontSize: 14,
          ),
        ),
        onChanged: (Data? newValue) {
          onChangAction(widgetPosition);
          print("Latest Position: " + widgetPosition.toString());

          if (newValue!.townhall_id != -1) {
            setState(() {
              selectedValue = newValue;
              selectedTownhalls.add({
                'position': widgetPosition,
                'townhallID': newValue!.townhall_id
              });
              _showCCFLoader = true;
              _hasLevel = newValue!.children_count! > 0 ? true : false;
            });
            print("Selected ID: " +
                selectedValue!.townhall_id.toString() +
                " Selected Name: " +
                selectedValue!.name.toString());
            BlocProvider.of<OrganizationBloc>(context).add(
                GetCCFEvent(townhall_id: newValue!.townhall_id.toString()));
          } else {
            int widgetLength = addedWidgets.length;
            for (initPosition; initPosition < widgetLength; initPosition++) {
              print(
                  "Loop counts:${initPosition} WidgetPos: ${widgetPosition} Total Arr: ${widgetLength}");
              if (initPosition > widgetPosition) {
                int toRemove = (addedWidgets.length - 1) - (2 - initPosition);
                print(initPosition.toString() +
                    " > " +
                    widgetPosition.toString() +
                    " To  remove " +
                    toRemove.toString());

                addedWidgets.removeAt(toRemove);
              }
              setState(() {
                boxHeight -= 35;
                _hasLevel = addedWidgets.length < 2 ? true : false;
              });
            }
          }
        },
        items: items.map<DropdownMenuItem<Data>>((Data value) {
          return DropdownMenuItem<Data>(
            value: value,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 5.0),
                  child: Text(value.name.toString()),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
