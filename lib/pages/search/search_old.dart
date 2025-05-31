//import 'dart:html';
// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:indexed/indexed.dart';
import 'package:mobilizer/bloc/posts/posts_bloc.dart';
import 'package:mobilizer/bloc/search/organization_bloc.dart';
import 'package:mobilizer/bloc/search/people_bloc.dart' as p;
import 'package:mobilizer/bloc/search/organization_bloc.dart' as o;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:bloc/bloc.dart';
import 'package:mobilizer/common/common/sharepreference.dart';
import 'package:mobilizer/models/search/search_organization_response.dart';
// import 'package:mobilizer/models/social/followee_response.dart';
// import 'package:mobilizer/models/suggestion/suggestion_response.dart';
import 'package:mobilizer/models/search/search_people_response.dart';
import 'package:mobilizer/pages/feed/feed.dart';
import 'package:mobilizer/pages/home/home.dart';
import 'package:mobilizer/pages/organization/organization_details.dart';
import 'package:mobilizer/pages/people/people_profile.dart';
import 'package:mobilizer/widget/bottom_navigational_bar.dart';
import 'package:mobilizer/widget/bottom_sheet_pick_townhalls.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import '../../common/common/navigation.dart';
import 'package:getwidget/getwidget.dart';

class Search extends StatefulWidget {
  static String routeName = 'search';

  const Search({Key? key}) : super(key: key);

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> with WidgetsBindingObserver {
  final controller = TextEditingController();

  final styleActive = TextStyle(color: Colors.black);
  final styleHint = TextStyle(color: Colors.black54);
  final style = TextStyle(color: Colors.black54);

  List<SearchPeopleResponseData> data = [];
  List<OrganizationData> orgData = [];
  List<dynamic> _isFollowList = [];
  List<dynamic> _isJoinList = [];

  // p.PeopleBloc _peopleBloc = p.PeopleBloc();
  bool loading = true;
  String _showLoaderFor = "";
  String _userID = '';
  bool refresh = false;
  int countFollowers = 0;
  double _previousOffset = 0;
  bool _showBottomMenu = true;
  bool _showCircleRow = true; // Initially show circle row
  late ScrollController _scrollController;
  bool isSuccessful = false; //Query is successful
  bool isMember = false;
  bool _capLoader = false;
  String _visitedTabID = "0"; //last visitedTabID
  int _tClickedID = -1;
  int _pClickedID = -1;
  String hintText = 'Search Organization';
  String query = '';
  int _selectedIndex = 0;
  late TabController _tabController;
  @override
  void initState() {
    _setUserID();
    _scrollController = ScrollController();
    //_scrollController.addListener(_scrollListener);
    _getCachedData();
    _getCachedData2();
    WidgetsBinding.instance.addObserver(this);
    Future.delayed(Duration.zero, () {
      // BlocProvider.of<p.PeopleBloc>(context).add(p.GetPeopleEvent(term: ''));
      BlocProvider.of<o.OrganizationBloc>(context)
          .add(o.SearchOrganizationEvent(term: '', interest_id: ''));
    });

    super.initState();
    _focus.addListener(_onFocusChange);
  }

  FocusNode _focus = FocusNode();
  @override
  void _onFocusChange() {
    // setState(() {
    //   refresh = true;
    // });
  }
  // void _scrollListener() {
  //   final currentOffset = _scrollController.offset;
  //   final direction = currentOffset - _previousOffset;

  //   setState(() {
  //     if (direction < 0) {
  //       // Scrolling up
  //       _showBottomMenu = true;
  //       _showCircleRow = true;
  //     } else if (direction > 0) {
  //       // Scrolling down
  //       _showBottomMenu = false;
  //       _showCircleRow = false;
  //     }
  //     _previousOffset = currentOffset;
  //   });
  // }

  final debouncer = Debouncer(milliseconds: 1000);
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (_userID != 'null' || _userID != '') {
      if (state == AppLifecycleState.resumed) {
        //_updateUserStatus(true);
      } else {
        //_updateUserStatus(false);
      }
    }
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    //_scrollController.removeListener(_scrollListener);
    //_scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Color.fromARGB(255, 255, 255, 255),
        statusBarColor: Theme.of(context).primaryColor,
      ),
    );

    // return Text("Testing");
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: DefaultTabController(
        length: 2,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle(
              statusBarColor: Colors.white, // Set status bar color to white
            ),
            child: Scaffold(
              // appBar: PreferredSize(
              //   preferredSize: Size.fromHeight(kToolbarHeight + 100),
              //   child: AnimatedContainer(
              //     duration: const Duration(milliseconds: 300),
              //     height: _showBottomMenu ? kToolbarHeight + 100 : 0,
              //     child: Padding(
              //       padding: EdgeInsets.only(top: 15),
              //       child: AppBar(
              //         title: Center(
              //           child: Padding(
              //             padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
              //             child: Container(
              //               height: 45,
              //               margin: const EdgeInsets.fromLTRB(10, 1, 10, 1),
              //               decoration: BoxDecoration(
              //                 borderRadius: BorderRadius.circular(12),
              //                 color: Colors.white,
              //                 border: Border.all(
              //                   color: Colors.blue,
              //                 ),
              //               ),
              //               padding: const EdgeInsets.symmetric(horizontal: 8),
              //               child: TextField(
              //                   controller: controller,
              //                   focusNode: _focus,
              //                   decoration: InputDecoration(
              //                     icon: Icon(Icons.search, color: style.color),
              //                     suffixIcon: controller.text.isNotEmpty
              //                         ? GestureDetector(
              //                             child: Icon(Icons.close,
              //                                 color: style.color),
              //                             onTap: () {
              //                               controller.clear();
              //                               if (_selectedIndex == 0) {
              //                                 orgData = [];
              //                                 _isJoinList = [];
              //                                 BlocProvider.of<
              //                                             o.OrganizationBloc>(
              //                                         context)
              //                                     .add(
              //                                         o.SearchOrganizationEvent(
              //                                             term: '',
              //                                             interest_id: ''));
              //                               } else {
              //                                 data = [];
              //                                 _isFollowList = [];
              //                                 BlocProvider.of<p.PeopleBloc>(
              //                                         context)
              //                                     .add(p.GetPeopleEvent(
              //                                         term: ''));
              //                               }
              //                               FocusScope.of(context)
              //                                   .requestFocus(FocusNode());
              //                             },
              //                           )
              //                         : null,
              //                     hintText: hintText,
              //                     hintStyle: style,
              //                     border: InputBorder.none,
              //                   ),
              //                   style: style,
              //                   onChanged: (val) {
              //                     debouncer.run(() {
              //                       if (_selectedIndex == 0) {
              //                         setState(() {
              //                           loading = true;
              //                           data = [];
              //                           _isFollowList = [];
              //                         });
              //                         BlocProvider.of<p.PeopleBloc>(context)
              //                             .add(p.GetPeopleEvent(term: val));
              //                         data = [];
              //                       } else {
              //                         setState(() {
              //                           loading = true;
              //                           orgData = [];
              //                           _isJoinList = [];
              //                         });
              //                         BlocProvider.of<o.OrganizationBloc>(
              //                                 context)
              //                             .add(o.SearchOrganizationEvent(
              //                                 term: val, interest_id: ''));
              //                         orgData = [];
              //                       }
              //                     });
              //                   }),
              //             ),
              //           ),
              //         ),
              //         backgroundColor: Colors.white,
              //         bottom: TabBar(
              //           onTap: (value) {
              //             setState(() {
              //               _showLoaderFor = '';
              //             });
              //             _selectedIndex = value;
              //             controller.clear();
              //             if (_selectedIndex == 0) {
              //               setState(() {
              //                 loading = false;
              //                 _visitedTabID = _selectedIndex.toString();
              //                 hintText = 'Search Townhall';
              //               });
              //               BlocProvider.of<o.OrganizationBloc>(context).add(
              //                   o.SearchOrganizationEvent(
              //                       term: '', interest_id: ''));
              //             } else {
              //               setState(() {
              //                 hintText = 'Search People';
              //                 loading =
              //                     _visitedTabID == _selectedIndex.toString()
              //                         ? false
              //                         : true;
              //                 _visitedTabID = _selectedIndex.toString();
              //               });
              //               print("Visited: ${_visitedTabID}");
              //               print("Loading: ${loading}");
              //               print("SelectedID: ${_selectedIndex}");
              //               BlocProvider.of<p.PeopleBloc>(context)
              //                   .add(p.GetPeopleEvent(term: ''));
              //             }
              //           },
              //           indicatorWeight: 3,
              //           indicatorColor: Colors.blueAccent,
              //           tabs: [
              //             Tab(
              //               child: Text(
              //                 'Townhalls',
              //                 style: TextStyle(color: Colors.black),
              //               ),
              //             ),
              //             Tab(
              //               child: Text(
              //                 'People',
              //                 style: TextStyle(color: Colors.black),
              //               ),
              //             ),
              //           ],
              //         ),
              //       ),
              //     ),
              //   ),
              // ),

              body: WillPopScope(
                onWillPop: () async {
                  return true;
                },
                child: NestedScrollView(
                  controller: _scrollController,
                  headerSliverBuilder:
                      (BuildContext context, bool innerBoxIsScrolled) {
                    return [
                      SliverAppBar(
                        expandedHeight: 130,
                        flexibleSpace: FlexibleSpaceBar(
                          background: Container(
                            margin: EdgeInsets.only(
                                left: 15, right: 15, bottom: 25),
                            padding: EdgeInsets.only(
                              top: 20.0,
                            ),
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                              child: Container(
                                height: 45,
                                margin: const EdgeInsets.fromLTRB(10, 1, 10, 1),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.white,
                                  border: Border.all(
                                    color: Colors.blue,
                                  ),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: TextField(
                                    controller: controller,
                                    focusNode: _focus,
                                    decoration: InputDecoration(
                                      icon: Icon(Icons.search,
                                          color: style.color),
                                      suffixIcon: controller.text.isNotEmpty
                                          ? GestureDetector(
                                              child: Icon(Icons.close,
                                                  color: style.color),
                                              onTap: () {
                                                controller.clear();
                                                if (_selectedIndex == 0) {
                                                  orgData = [];
                                                  _isJoinList = [];
                                                  BlocProvider.of<
                                                              o
                                                              .OrganizationBloc>(
                                                          context)
                                                      .add(o
                                                          .SearchOrganizationEvent(
                                                              term: '',
                                                              interest_id: ''));
                                                } else {
                                                  data = [];
                                                  _isFollowList = [];
                                                  BlocProvider.of<p.PeopleBloc>(
                                                          context)
                                                      .add(p.GetPeopleEvent(
                                                          term: ''));
                                                }
                                                FocusScope.of(context)
                                                    .requestFocus(FocusNode());
                                              },
                                            )
                                          : null,
                                      hintText: hintText,
                                      hintStyle: style,
                                      border: InputBorder.none,
                                    ),
                                    style: style,
                                    onChanged: (val) {
                                      debouncer.run(() {
                                        if (_selectedIndex == 0) {
                                          if (mounted) {
                                            setState(() {
                                              loading = true;
                                              orgData = [];
                                              _isJoinList = [];
                                            });
                                          }
                                          BlocProvider.of<o.OrganizationBloc>(
                                                  context)
                                              .add(o.SearchOrganizationEvent(
                                                  term: val, interest_id: ''));
                                          orgData = [];
                                        } else {
                                          if (mounted) {
                                            setState(() {
                                              loading = true;
                                              data = [];
                                              _isFollowList = [];
                                            });
                                          }
                                          BlocProvider.of<p.PeopleBloc>(context)
                                              .add(p.GetPeopleEvent(term: val));
                                          data = [];
                                        }
                                      });
                                    }),
                              ),
                            ),
                          ),
                        ),
                        // title: Center(
                        //   child: Padding(
                        //     padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                        //     child: Container(
                        //       height: 45,
                        //       margin: const EdgeInsets.fromLTRB(10, 1, 10, 1),
                        //       decoration: BoxDecoration(
                        //         borderRadius: BorderRadius.circular(12),
                        //         color: Colors.white,
                        //         border: Border.all(
                        //           color: Colors.blue,
                        //         ),
                        //       ),
                        //       padding: const EdgeInsets.symmetric(horizontal: 8),
                        //       child: TextField(
                        //           controller: controller,
                        //           focusNode: _focus,
                        //           decoration: InputDecoration(
                        //             icon: Icon(Icons.search, color: style.color),
                        //             suffixIcon: controller.text.isNotEmpty
                        //                 ? GestureDetector(
                        //                     child: Icon(Icons.close,
                        //                         color: style.color),
                        //                     onTap: () {
                        //                       controller.clear();
                        //                       if (_selectedIndex == 0) {
                        //                         orgData = [];
                        //                         _isJoinList = [];
                        //                         BlocProvider.of<o.OrganizationBloc>(
                        //                                 context)
                        //                             .add(o.SearchOrganizationEvent(
                        //                                 term: '', interest_id: ''));
                        //                       } else {
                        //                         data = [];
                        //                         _isFollowList = [];
                        //                         BlocProvider.of<p.PeopleBloc>(
                        //                                 context)
                        //                             .add(
                        //                                 p.GetPeopleEvent(term: ''));
                        //                       }
                        //                       FocusScope.of(context)
                        //                           .requestFocus(FocusNode());
                        //                     },
                        //                   )
                        //                 : null,
                        //             hintText: hintText,
                        //             hintStyle: style,
                        //             border: InputBorder.none,
                        //           ),
                        //           style: style,
                        //           onChanged: (val) {
                        //             debouncer.run(() {
                        //               if (_selectedIndex == 0) {
                        //                 setState(() {
                        //                   loading = true;
                        //                   orgData = [];
                        //                   _isJoinList = [];
                        //                 });
                        //                 BlocProvider.of<o.OrganizationBloc>(context)
                        //                     .add(o.SearchOrganizationEvent(
                        //                         term: val, interest_id: ''));
                        //                 orgData = [];
                        //               } else {
                        //                 setState(() {
                        //                   loading = true;
                        //                   data = [];
                        //                   _isFollowList = [];
                        //                 });
                        //                 BlocProvider.of<p.PeopleBloc>(context)
                        //                     .add(p.GetPeopleEvent(term: val));
                        //                 data = [];
                        //               }
                        //             });
                        //           }),
                        //     ),
                        //   ),
                        // ),

                        bottom: TabBar(
                          onTap: (value) {
                            if (mounted) {
                              setState(() {
                                _showLoaderFor = '';
                              });
                            }
                            _selectedIndex = value;
                            controller.clear();
                            if (_selectedIndex == 0) {
                              if (mounted) {
                                setState(() {
                                  _isFollowList = [];
                                  loading = false;
                                  _visitedTabID = _selectedIndex.toString();
                                  hintText = 'Search Townhall';
                                });
                              }
                              BlocProvider.of<o.OrganizationBloc>(context).add(
                                  o.SearchOrganizationEvent(
                                      term: '', interest_id: ''));
                            } else {
                              if (mounted) {
                                setState(() {
                                  _isJoinList = [];
                                  hintText = 'Search People';
                                  loading =
                                      _visitedTabID == _selectedIndex.toString()
                                          ? false
                                          : true;
                                  _visitedTabID = _selectedIndex.toString();
                                });
                              }
                              print("Visited: ${_visitedTabID}");
                              print("Loading: ${loading}");
                              print("SelectedID: ${_selectedIndex}");
                              BlocProvider.of<p.PeopleBloc>(context)
                                  .add(p.GetPeopleEvent(term: ''));
                            }
                          },
                          indicatorWeight: 3,
                          indicatorColor: Colors.blueAccent,
                          tabs: [
                            Tab(
                              child: Text(
                                'Organizations',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                            Tab(
                              child: Text(
                                'People',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                      )
                    ];
                  },
                  body: NotificationListener<ScrollUpdateNotification>(
                    onNotification: (notification) {
                      // Check if the scroll is vertical
                      if (notification.metrics.axis == Axis.vertical) {
                        if (notification.scrollDelta! > 0) {
                          // Scrolling down
                          if (mounted) {
                            setState(() {
                              _showBottomMenu = false;
                            });
                          }
                        } else if (notification.scrollDelta! < 0) {
                          // Scrolling up
                          if (mounted) {
                            setState(() {
                              _showBottomMenu = true;
                            });
                          }
                        }

                        // Check if the scroll is within the desired Container
                        if (notification.context
                                ?.findAncestorWidgetOfExactType<Container>() !=
                            null) {
                          if (notification.metrics.extentAfter == 0) {
                            // Show snackbar or perform other actions
                            //_fetchOlderPosts();
                            print(
                                "Bottom At bottom: ${notification.metrics.extentAfter}");
                          } else {
                            print(
                                "Bottom: ${notification.metrics.extentAfter}");
                          }
                        }
                      }
                      // Return true to continue receiving notifications
                      return true;
                    },
                    child: TabBarView(children: [
                      BlocConsumer<o.OrganizationBloc, o.OrganizationState>(
                        listener: (context, state) {
                          if (state is o.SearchOrganizationState) {
                            if (mounted) {
                              setState(() {
                                loading = false;
                                _showLoaderFor = '';
                                isSuccessful = true;
                                if (state.searchOrganizationResponse.data!
                                        .length <
                                    1) {
                                  orgData = [];
                                } else {
                                  orgData =
                                      state.searchOrganizationResponse.data!;
                                }
                              });
                            }
                            // AppSharedPreferences.setValue(
                            //     key: 'page_search_organization',
                            //     value: jsonEncode(orgData));
                          }

                          if (state is o.NoReturnState) {
                            loading = false;
                            isSuccessful = true;
                            _showLoaderFor = '';
                          }
                          if (state is o.NetworkState) {
                            if (mounted) {
                              setState(() {
                                loading = false;
                                _showLoaderFor = '';
                                _tClickedID = -1;
                              });
                            }
                            isSuccessful = false;
                            print(state.message);
                            // loading = false;
                            final snackBar = SnackBar(
                                backgroundColor: Color(0xFFcf5555),
                                content: Text(state.message.toString()));
                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar);
                          }
                          if (state is o.LeaveState) {
                            if (mounted) {
                              setState(() {
                                _showLoaderFor = '';
                                loading = false;
                                _isJoinList[_tClickedID] =
                                    !_isJoinList[_tClickedID];
                                _tClickedID = 0;
                              });
                            }
                            print("Am inside leave view state");
                            isSuccessful = true;
                            BlocProvider.of<o.OrganizationBloc>(context)
                                .add(o.GetOrganizationEvent());
                          }
                          if (state is o.JoinState) {
                            if (mounted) {
                              setState(() {
                                _showLoaderFor = '';
                                loading = false;
                                _isJoinList[_tClickedID] =
                                    !_isJoinList[_tClickedID];
                                _tClickedID = -1;
                              });
                            }
                            print("Am inside join state");
                            isSuccessful = true;
                            BlocProvider.of<o.OrganizationBloc>(context)
                                .add(o.GetOrganizationEvent());
                          }
                          if (state is o.ShowBottomSheetState) {
                            print("showBottom");
                            print(state.getDropDownList[0].level_list![0].name);
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              builder: (BuildContext context) {
                                return TownhallBottomSheet(
                                    getDropDownList: state.getDropDownList,
                                    orgID: _showLoaderFor,
                                    hasJoined: _hasJoined);
                              },
                            );
                          }
                          if (state is o.AlreadyMemberState) {
                            _showLoaderFor = '';
                            loading = false;
                            _tClickedID = -1;
                            final snackBar = SnackBar(
                                backgroundColor: Color(0xFFcf5555),
                                content: Text(state.message.toString()));
                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar);
                          }
                          if (state is o.ErrorState) {
                            loading = false;
                            _showLoaderFor = '';
                          }
                        },
                        builder: (context, state) {
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
                                if (loading == false &&
                                    orgData.length == 0 &&
                                    _selectedIndex == 0)
                                  Center(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                            'images/no-org.png',
                                            width: 150,
                                            height: 150,
                                          ),
                                          Text("Search for Organization"),
                                        ],
                                      ),
                                    ),
                                  ),
                                refresh
                                    ? SizedBox(width: 1)
                                    : ListView.builder(
                                        // controller: _scrollController,
                                        padding: const EdgeInsets.only(top: 15),
                                        shrinkWrap: true,
                                        itemCount: orgData.length,
                                        itemBuilder: (context, index) {
                                          final org = orgData[index];
                                          var bol = org.is_member == 'yes'
                                              ? true
                                              : false;
                                          print(org);
                                          _isJoinList.add(bol);
                                          return Padding(
                                            padding: EdgeInsets.only(
                                                bottom: 15,
                                                left: 18,
                                                right: 18),
                                            child: Container(
                                              margin:
                                                  EdgeInsets.only(bottom: 3),
                                              padding: EdgeInsets.only(
                                                  left: 0,
                                                  right: 0,
                                                  top: 5,
                                                  bottom: 5),
                                              decoration: BoxDecoration(
                                                color: Color.fromARGB(
                                                    255, 230, 230, 230),
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                              ),
                                              child: GestureDetector(
                                                onTap: () {
                                                  print("Pic ${org.picture}}");
                                                  print(
                                                      "Join status: ${org.join_status}");
                                                  final mapData = {
                                                    'org_id':
                                                        org.org_id.toString(),
                                                    'org_bg': org.org_bg,
                                                    'org_about': org.org_about,
                                                    'org_name': org.org_name,
                                                    'org_member_count':
                                                        org.org_member_count,
                                                    'join_status':
                                                        org.join_status!,
                                                    'username':
                                                        org.org_username,
                                                    'picture': org.picture,
                                                    'member': org.is_member,
                                                    'isLeader': org.is_leader,
                                                    'verified': org.verified,
                                                    'unread': org.unread,
                                                    'pinned': org.pinned,
                                                    'navigateTo': 'search'
                                                  };
                                                  Navigator.push(context,
                                                      MaterialPageRoute(
                                                          builder: (context) {
                                                    return MultiBlocProvider(
                                                      providers: [
                                                        BlocProvider(
                                                          create: (contextA) =>
                                                              OrganizationBloc(),
                                                        ),
                                                      ],
                                                      child:
                                                          OrganizationDetails(
                                                        mapData: mapData,
                                                      ),
                                                    );
                                                  }));
                                                },
                                                child: ListTile(
                                                  leading: Container(
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                        color: Color.fromARGB(
                                                            255,
                                                            221,
                                                            221,
                                                            221), // Adjust the shade of grey as needed
                                                        width:
                                                            1.0, // Adjust the width of the border as needed
                                                      ),
                                                    ),
                                                    child: CircleAvatar(
                                                      backgroundImage:
                                                          NetworkImage(
                                                              org.picture!),
                                                    ),
                                                  ),
                                                  title: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        org.org_name.toString(),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      Text(
                                                        '@${org.org_username.toString()}',
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color:
                                                              Colors.grey[700],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  trailing: _showLoaderFor ==
                                                          org.org_id.toString()
                                                      ? Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  right: 16.0),
                                                          child: Container(
                                                            width: 50.0,
                                                            height: 50.0,
                                                            child:
                                                                SpinKitCircle(
                                                              color:
                                                                  Colors.blue,
                                                              size: 30.0,
                                                            ),
                                                          ),
                                                        )
                                                      : _orgBuildButtons(
                                                          context,
                                                          index,
                                                          int.parse(org.org_id
                                                              .toString())),
                                                ),
                                              ),
                                            ),
                                          );
                                        }),
                              ],
                            ),
                          );
                        },
                      ),
                      BlocConsumer<p.PeopleBloc, p.PeopleState>(
                        listener: (context, state) {
                          if (state is p.GetSearchResultState) {
                            if (mounted) {
                              setState(() {
                                loading = false;
                                refresh = false;
                              });
                            }

                            print("Result Found in view");
                          }
                          if (state is p.SearchLoadingState) {
                            if (mounted) {
                              setState(() {
                                loading = true;
                                _showLoaderFor = '';
                              });
                            }
                          }
                          if (state is p.PeopleLoadingState) {
                            if (_showLoaderFor == "") {
                              if (mounted) {
                                setState(() {
                                  loading = true;
                                });
                              }
                            }
                          }
                          if (state is p.GetPeopleState) {
                            if (mounted) {
                              setState(() {
                                loading = false;
                                _showLoaderFor = '';
                                refresh = false;
                                data = state.getPeopleResponse.data!;
                              });
                            }
                            // AppSharedPreferences.setValue(
                            //     key: 'page_search_people',
                            //     value: jsonEncode(data));

                            print("Am Here2");
                          }
                          if (state is p.NoReturnState) {
                            loading = false;
                            _showLoaderFor = '';
                          }
                          if (state is p.PeopleErrorState) {
                            if (mounted) {
                              setState(() {
                                print("Am Here3");
                                loading = false;
                                _showLoaderFor = '';
                                print(state.message);
                              });
                            }

                            final snackBar = SnackBar(
                                content: Text(state.message.toString()));
                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar);
                          }
                          if (state is p.FollowState) {
                            print('am here');
                            if (mounted) {
                              setState(() {
                                _capLoader = false;
                                _showLoaderFor = '';
                                _isFollowList[_pClickedID] =
                                    !_isFollowList[_pClickedID];
                              });
                            }
                            loading = false;
                          }
                          if (state is p.UnFollowState) {
                            if (mounted) {
                              setState(() {
                                _capLoader = false;
                                _showLoaderFor = '';
                                _isFollowList[_pClickedID] =
                                    !_isFollowList[_pClickedID];
                              });
                            }
                            loading = false;
                          }
                          if (state is p.NetworkState) {
                            _showLoaderFor = '';
                          }
                        },
                        builder: (context, state) {
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
                                Container(
                                  width: double.infinity,
                                  child: ListView.builder(
                                      // controller: _scrollController,
                                      padding: const EdgeInsets.only(top: 15),
                                      shrinkWrap: true,
                                      itemCount: data.length,
                                      itemBuilder: (context, index) {
                                        final people = data[index];
                                        final String location =
                                            "${people.country_name != '' ? '${people.country_name}' : ''} ${people.state_name != '' ? '> ${people.state_name}' : ''} ${people.lga_name != '' ? '> ${people.lga_name}' : ''}";
                                        print(people);
                                        _isFollowList.add(
                                            people.is_following == "yes"
                                                ? true
                                                : false);
                                        // _isFollowList[index] =
                                        //     people.is_following == "yes" ? true : false;
                                        return Padding(
                                          padding: EdgeInsets.only(
                                              bottom: 15, left: 18, right: 18),
                                          child: Container(
                                            margin: EdgeInsets.only(bottom: 3),
                                            padding: EdgeInsets.only(
                                                left: 0,
                                                right: 0,
                                                top: 5,
                                                bottom: 5),
                                            decoration: BoxDecoration(
                                              color: Color.fromARGB(
                                                  255, 230, 230, 230),
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ),
                                            child: ListTile(
                                                leading: GestureDetector(
                                                  onTap: () {
                                                    Map<String, dynamic>
                                                        mapData = {
                                                      'subjectID':
                                                          people.user_id,
                                                      'picture':
                                                          people.photo_path_lg,
                                                      'post_update_by':
                                                          people.fullname,
                                                      'username':
                                                          people.username,
                                                      'location': location
                                                    };
                                                    Navigator.push(context,
                                                        MaterialPageRoute(
                                                            builder: (context) {
                                                      return MultiBlocProvider(
                                                        providers: [
                                                          BlocProvider(
                                                            create: (contextA) =>
                                                                p.PeopleBloc(),
                                                          ),
                                                          BlocProvider(
                                                            create: (context) =>
                                                                PostsBloc(),
                                                          ),
                                                        ],
                                                        child: PeopleProfile(
                                                            mapData: mapData),
                                                      );
                                                    }));
                                                  },
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                        color: Color.fromARGB(
                                                            255,
                                                            221,
                                                            221,
                                                            221), // Adjust the shade of grey as needed
                                                        width:
                                                            1.0, // Adjust the width of the border as needed
                                                      ),
                                                    ),
                                                    child: CircleAvatar(
                                                      backgroundImage:
                                                          NetworkImage(people
                                                              .photo_path),
                                                    ),
                                                  ),
                                                ),
                                                title: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () {
                                                        Map<String, dynamic>
                                                            mapData = {
                                                          'subjectID':
                                                              people.user_id,
                                                          'picture': people
                                                              .photo_path_lg,
                                                          'post_update_by':
                                                              people.fullname,
                                                          'username':
                                                              people.username,
                                                          'location': location
                                                        };
                                                        Navigator.push(context,
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) {
                                                          return MultiBlocProvider(
                                                            providers: [
                                                              BlocProvider(
                                                                create: (contextA) =>
                                                                    p.PeopleBloc(),
                                                              ),
                                                              BlocProvider(
                                                                create: (context) =>
                                                                    PostsBloc(),
                                                              ),
                                                            ],
                                                            child: PeopleProfile(
                                                                mapData:
                                                                    mapData),
                                                          );
                                                        }));
                                                      },
                                                      child: Text(
                                                        people.fullname,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                    GestureDetector(
                                                      onTap: () {
                                                        Map<String, dynamic>
                                                            mapData = {
                                                          'subjectID':
                                                              people.user_id,
                                                          'picture': people
                                                              .photo_path_lg,
                                                          'post_update_by':
                                                              people.fullname,
                                                          'username':
                                                              people.username,
                                                        };
                                                        Navigator.push(context,
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) {
                                                          return MultiBlocProvider(
                                                            providers: [
                                                              BlocProvider(
                                                                create: (contextA) =>
                                                                    p.PeopleBloc(),
                                                              ),
                                                              BlocProvider(
                                                                create: (context) =>
                                                                    PostsBloc(),
                                                              ),
                                                            ],
                                                            child: PeopleProfile(
                                                                mapData:
                                                                    mapData),
                                                          );
                                                        }));
                                                      },
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            '@${people.username}',
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              color: Colors
                                                                  .grey[700],
                                                            ),
                                                          ),
                                                          if (people
                                                                  .country_name !=
                                                              "")
                                                            Text(
                                                              '${location}',
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: TextStyle(
                                                                  fontSize: 10,
                                                                  color: Colors
                                                                          .grey[
                                                                      700]),
                                                            ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                trailing: _showLoaderFor ==
                                                        people.user_id
                                                            .toString()
                                                    ? Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                right: 16.0),
                                                        child: Container(
                                                          width: 50.0,
                                                          height: 50.0,
                                                          child: SpinKitCircle(
                                                            color: Colors.blue,
                                                            size: 30.0,
                                                          ),
                                                        ),
                                                      )
                                                    : _peopleBuildButtons(
                                                        context,
                                                        index,
                                                        int.parse(
                                                            people.user_id))),
                                          ),
                                        );

                                        // ListTile(
                                        //     minVerticalPadding: 10.0,
                                        //     title: GestureDetector(
                                        //       onTap: () {
                                        //         Map<String, dynamic> mapData = {
                                        //           'subjectID': people.user_id,
                                        //           'picture': people.photo_path_lg,
                                        //           'post_update_by': people.fullname,
                                        //           'username': people.username,
                                        //         };
                                        //         Navigator.push(context,
                                        //             MaterialPageRoute(
                                        //                 builder: (context) {
                                        //           return MultiBlocProvider(
                                        //             providers: [
                                        //               BlocProvider(
                                        //                 create: (contextA) =>
                                        //                     p.PeopleBloc(),
                                        //               ),
                                        //               BlocProvider(
                                        //                 create: (context) =>
                                        //                     PostsBloc(),
                                        //               ),
                                        //             ],
                                        //             child: PeopleProfile(
                                        //                 mapData: mapData),
                                        //           );
                                        //         }));
                                        //       },
                                        //       child: Text(
                                        //         people.fullname,
                                        //         style: TextStyle(
                                        //             fontWeight: FontWeight.bold),
                                        //       ),
                                        //     ),
                                        //     subtitle: GestureDetector(
                                        //       onTap: () {
                                        //         Map<String, dynamic> mapData = {
                                        //           'subjectID': people.user_id,
                                        //           'picture': people.photo_path_lg,
                                        //           'post_update_by': people.fullname,
                                        //           'username': people.username,
                                        //         };
                                        //         Navigator.push(context,
                                        //             MaterialPageRoute(
                                        //                 builder: (context) {
                                        //           return MultiBlocProvider(
                                        //             providers: [
                                        //               BlocProvider(
                                        //                 create: (contextA) =>
                                        //                     p.PeopleBloc(),
                                        //               ),
                                        //               BlocProvider(
                                        //                 create: (context) =>
                                        //                     PostsBloc(),
                                        //               ),
                                        //             ],
                                        //             child: PeopleProfile(
                                        //               mapData: mapData,
                                        //             ),
                                        //           );
                                        //         }));
                                        //       },
                                        //       child: Column(
                                        //         crossAxisAlignment:
                                        //             CrossAxisAlignment.start,
                                        //         children: [
                                        //           Text('@${people.username}'),
                                        //           Text(
                                        //             '${people.state_name} > ${people.lga_name}',
                                        //             style: TextStyle(fontSize: 11),
                                        //           ),
                                        //         ],
                                        //       ),
                                        //     ),
                                        //     leading: GestureDetector(
                                        //       onTap: () {
                                        //         Map<String, dynamic> mapData = {
                                        //           'subjectID': people.user_id,
                                        //           'picture': people.photo_path_lg,
                                        //           'post_update_by': people.fullname,
                                        //           'username': people.username,
                                        //         };
                                        //         Navigator.push(context,
                                        //             MaterialPageRoute(
                                        //                 builder: (context) {
                                        //           return MultiBlocProvider(
                                        //             providers: [
                                        //               BlocProvider(
                                        //                 create: (contextA) =>
                                        //                     p.PeopleBloc(),
                                        //               ),
                                        //               BlocProvider(
                                        //                 create: (context) =>
                                        //                     PostsBloc(),
                                        //               ),
                                        //             ],
                                        //             child: PeopleProfile(
                                        //               mapData: mapData,
                                        //             ),
                                        //           );
                                        //         }));
                                        //       },
                                        //       child: CircleAvatar(
                                        //         radius: 25,
                                        //         backgroundColor: Colors.grey,
                                        //         child: ClipRRect(
                                        //           borderRadius:
                                        //               BorderRadius.circular(50),
                                        //           child: Image.network(
                                        //             people.photo_path,
                                        //             width: 50,
                                        //             height: 50,
                                        //             fit: BoxFit.cover,
                                        //           ),
                                        //         ),
                                        //       ),
                                        //     ),
                                        //     trailing:
                                        //_showLoaderFor ==
                                        //             people.user_id.toString()
                                        //         ?
                                        // Padding(
                                        //             padding: const EdgeInsets.only(
                                        //                 right: 16.0),
                                        //             child: Container(
                                        //               width: 50.0,
                                        //               height: 50.0,
                                        //               child: SpinKitCircle(
                                        //                 color: Colors.blue,
                                        //                 size: 30.0,
                                        //               ),
                                        //             ),
                                        //           )
                                        //         : _peopleBuildButtons(
                                        //             context,
                                        //             index,
                                        //             int.parse(people.user_id)));
                                      }),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ]),
                  ),
                ),
              ),
              bottomNavigationBar: AnimatedContainer(
                duration: Duration(
                    milliseconds:
                        _showBottomMenu ? 350 : 350), // Adjusted duration
                height: _showBottomMenu ? kBottomNavigationBarHeight : 0.0,
                child: _showBottomMenu ? _bottomNavBar() : null,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _peopleBuildButtons(BuildContext context, int index, int subjectID) {
    return GFButton(
      onPressed: () {
        _pClickedID = index;
        _showLoaderFor = subjectID.toString();
        if (_isFollowList[index] == true) {
          if (mounted) {
            setState(() {
              _showLoaderFor = subjectID.toString();
              data[index].is_following = "no";
            });
          }
          BlocProvider.of<p.PeopleBloc>(context)
              .add(p.UnFollowEvent(followee: subjectID));
        } else {
          if (mounted)
            setState(() {
              _showLoaderFor = subjectID.toString();
              data[index].is_following = "yes";
            });

          BlocProvider.of<p.PeopleBloc>(context)
              .add(p.FollowEvent(followee: subjectID));
        }
      },
      text: ("${_isFollowList[index] == true ? "Unfollow" : "Follow"}"),
      shape: GFButtonShape.pills,
      color: _isFollowList[index] == true ? Colors.red : Colors.blue,
    );
  }

  Widget _bottomNavBar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _showBottomMenu ? kBottomNavigationBarHeight : 0,
      child: BottomNavigation(
          page: Search.routeName, showBottomMenu: _showBottomMenu),
    );
  }

  Widget _orgBuildButtons(BuildContext context, int index, int subjectID) {
    return GFButton(
      onPressed: () {
        _tClickedID = index;
        _confirmOrgRequest(index, subjectID.toString(), context);
      },
      text: ("${_isJoinList[index] == true ? "Leave" : "Join"}"),
      shape: GFButtonShape.pills,
      color: _isJoinList[index] == true ? Colors.red : Colors.blue,
    );
  }

  void _confirmOrgRequest(int index, String subjectID, BuildContext cont) {
    // print("Member: ${member}");
    if (_isJoinList[index] == true) {
      Alert(
        context: context,
        style: AlertStyle(
            titleStyle: TextStyle(fontWeight: FontWeight.bold),
            overlayColor: Colors.black54),
        title: "Confirm",
        desc:
            "Are you sure you want to leave this organization? You may need to re-join and be approved to get back in",
        buttons: [
          DialogButton(
            color: Colors.black45,
            child: Text(
              "No",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: () {
              Navigator.pop(context);
              _tClickedID = -1;
            },
            width: 120,
          ),
          DialogButton(
            child: Text(
              "Yes",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: () {
              Navigator.pop(context);
              if (mounted)
                setState(() {
                  _showLoaderFor = subjectID.toString();
                });
              BlocProvider.of<o.OrganizationBloc>(context)
                  .add(o.LeaveEvent(org_id: subjectID.toString()));
            },
            width: 120,
          )
        ],
      ).show();
    } else if (_isJoinList[index] == false) {
      Alert(
        context: context,
        style: AlertStyle(
            titleStyle: TextStyle(fontWeight: FontWeight.bold),
            overlayColor: Colors.black54),
        title: "Confirm",
        desc: "Are you sure you want to join?",
        buttons: [
          DialogButton(
            color: Colors.black45,
            child: Text(
              "No",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: () {
              Navigator.pop(context);
              _tClickedID = -1;
            },
            width: 120,
          ),
          DialogButton(
            child: Text(
              "Yes",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: () {
              print("Subject ID: ${subjectID}");

              BlocProvider.of<o.OrganizationBloc>(context)
                  .add(o.JoinEvent(org_id: subjectID.toString()));

              if (mounted) {
                Navigator.pop(context);
                setState(() {
                  _showLoaderFor = subjectID.toString();
                });
              }
            },
            width: 120,
          )
        ],
      ).show();
    }
  }

  _setUserID() async {
    var prefUserID = await AppSharedPreferences.getValue(key: 'user_id');
    if (mounted) {
      setState(() {
        _userID = prefUserID ?? "";
      });
    }
  }

  Future<void> _updateUserStatus(bool status) async {
    final userID = await AppSharedPreferences.getValue(key: 'user_id');
    setState(() {
      _userID = userID.toString();
    });
    print('User ID: ${_userID}');
    await FirebaseFirestore.instance.collection('users').doc(_userID).update({
      'isOnline': status,
      'lastSeen': FieldValue.serverTimestamp(),
    });
  }

  _getCachedData() async {
    var pageData = await getPageData('page_search_people');
    if (pageData != null) {
      var json = jsonDecode(pageData);
      if (mounted) {
        setState(() {
          data = json
              .map<SearchPeopleResponseData>(
                  (json) => SearchPeopleResponseData.fromJson(json))
              .toList();
          loading = false;
        });
      }
      // print("My Data: ${data[0].message}");
    }
  }

  _getCachedData2() async {
    var pageData = await getPageData('page_search_organization');
    if (pageData != null) {
      var json = jsonDecode(pageData);
      if (mounted) {
        setState(() {
          orgData = json
              .map<OrganizationData>((json) => OrganizationData.fromJson(json))
              .toList();
          loading = false;
        });
      }
      // print("My Data: ${data[0].message}");
    }
  }

  void _hasJoined(bool status, String orgID) {
    if (status == true) {
      print("_hasJoined was called");
      if (mounted) {
        setState(() {
          _showLoaderFor = '';
          loading = false;
          _isJoinList[_tClickedID] = !_isJoinList[_tClickedID];
          _tClickedID = -1;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _showLoaderFor = '';
          loading = false;
        });
      }
    }
  }

  Future<String?> getPageData(String value) async {
    return await AppSharedPreferences.getValue(key: value);
  }
}

class Debouncer {
  final int milliseconds;

  VoidCallback? action;
  Timer? _timer;
  Debouncer({required this.milliseconds});

  run(VoidCallback action) {
    if (null != _timer) {
      _timer?.cancel();
    }
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}
