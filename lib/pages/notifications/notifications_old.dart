import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:getwidget/getwidget.dart';
import 'package:mobilizer/bloc/posts/posts_bloc.dart';
import 'package:mobilizer/common/common/sharepreference.dart';
import 'package:mobilizer/models/notifications/notifications_response.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:mobilizer/pages/people/people_profile.dart';
import 'package:mobilizer/bloc/search/people_bloc.dart' as p;
import 'package:mobilizer/pages/home/home.dart';
import 'package:mobilizer/widget/bottom_navigational_bar.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:intl/intl.dart';
import 'dart:io' show Platform;

class Notifications extends StatefulWidget {
  const Notifications({Key? key}) : super(key: key);
  static String routeName = 'notification';

  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications>
    with WidgetsBindingObserver {
  List<NotificationsData> notifications = [];
  bool loading = true;
  bool noResult = false;
  double _previousOffset = 0;
  bool _showBottomMenu = true;
  bool _showCircleRow = true; // Initially show circle row
  late ScrollController _scrollController;
  String _userID = '';
  @override
  void initState() {
    _setUserID();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    WidgetsBinding.instance.addObserver(this);
    _getCachedData();
    Future.delayed(Duration.zero, () {
      BlocProvider.of<PostsBloc>(context).add(
        GetNotificationsEvent(limit: 50, last_row_id: ''),
      );
    });
    super.initState();
  }

  void _scrollListener() {
    final currentOffset = _scrollController.offset;
    final direction = currentOffset - _previousOffset;

    setState(() {
      if (direction < 0) {
        print("Scroll up");
        // Scrolling up
        _showBottomMenu = true;
        _showCircleRow = true;
      } else if (direction > 0) {
        print("Scroll down");
        // Scrolling down
        _showBottomMenu = false;
        _showCircleRow = false;
      }
      _previousOffset = currentOffset;
    });
  }

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
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Color.fromARGB(255, 255, 255, 255),
        statusBarColor: Theme.of(context).primaryColor,
      ),
    );
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.white, // Set status bar color to white
      ),
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight + 20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _showBottomMenu ? kToolbarHeight + 15 : 0,
            child: Padding(
              padding: EdgeInsets.only(top: Platform.isIOS ? 1 : 20),
              child: AppBar(
                title: Center(child: Text("Notification")),
                backgroundColor: Colors.white,
                leading: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.blue,
                  ),
                ),
              ),
            ),
          ),
        ),
        body: SafeArea(
          child: BlocConsumer<PostsBloc, PostsState>(
            listener: (context, state) {
              if (state is LoadingState) {
                loading = true;
              }
              if (state is NoResultState) {
                loading = false;
                noResult = true;
              }
              if (state is NotificationsState) {
                setState(() {
                  loading = false;
                  noResult = false;
                });

                print(state.notificationsResponse.msg);
                print(state.notificationsResponse.status);
                notifications = state.notificationsResponse.data!;

                AppSharedPreferences.setValue(
                    key: 'page_notification', value: jsonEncode(notifications));
              }
              if (state is ErrorState) {
                loading = false;
                noResult = false;
                print(state.message);
                final snackBar =
                    SnackBar(content: Text(state.message.toString()));
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              }
              if (state is NetworkState) {
                setState(() {
                  loading = false;
                  noResult = false;
                });
                final snackBar = SnackBar(
                    backgroundColor: Color(0xFFcf5555),
                    content: Text(state.message.toString()));
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              }
            },
            builder: (context, state) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(
                    height: 10.0,
                  ),
                  // Padding(
                  //   padding: const EdgeInsets.all(16.0),
                  //   child: Text(
                  //     'Notifications',
                  //     style:
                  //         TextStyle(fontWeight: FontWeight.bold, fontSize: 22.0),
                  //   ),
                  // ),
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
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      // Let the ListView know how many items it needs to build.
                      itemCount: notifications.length,
                      // Provide a builder function. This is where the magic happens.
                      // Convert each item into a widget based on the type of item it is.
                      itemBuilder: (context, index) {
                        final item = notifications[index];
                        DateTime notTime = new DateFormat("yyyy-MM-dd hh:mm:ss")
                            .parse(item.date!);
                        return GestureDetector(
                          onTap: () {
                            // print("click_ leads: ${item.click_leads_to}");
                            // if (item.click_leads_to == "profile") {
                            //   Navigator.push(context,
                            //       MaterialPageRoute(builder: (context) {
                            //     return BlocProvider(
                            //       create: (context) => p.PeopleBloc(),
                            //       child: PeopleProfile(
                            //           subjectID: item.subjects_id.toString()),
                            //     );
                            //   }));
                            // }
                            // if (item.click_leads_to == "post") {
                            //   Navigator.push(context,
                            //       MaterialPageRoute(builder: (context) {
                            //     return BlocProvider(
                            //       create: (context) => PostsBloc(),
                            //       child: HomeScreen(),
                            //     );
                            //   }));
                            // }
                            // if (item.click_leads_to == "comment") {}
                            // Navigator.pushNamed(
                            //     context, PostNotificationScreen.routeName,
                            //     arguments: {
                            //       'item_id': '54911',
                            //       'org_id': '5',
                            //       'org_name': 'OBidients',
                            //       'townhall_id': '160',
                            //       'n_type': 'post'
                            //     });
                          },
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            9.0, 9.0, 6.0, 8.0),
                                        child: CircleAvatar(
                                          radius: 15,
                                          backgroundColor: Colors.grey,
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(25),
                                            child: Image.network(
                                              item.notification_image
                                                  .toString(),
                                              width: 30,
                                              height: 30,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 8.0),
                                          child: SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                60,
                                            child: HtmlWidget(
                                              item.notification_txt!,
                                              //style: TextStyle(color: Colors.black),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(53, 1, 0, 8),
                                    child: Text('. ' + timeago.format(notTime),
                                        style: TextStyle(fontSize: 12.0)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  )
                ],
              );
            },
          ),
        ),
        bottomNavigationBar: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: _showBottomMenu ? kBottomNavigationBarHeight : 0,
          child: _showBottomMenu
              ? BottomNavigation(
                  page: Notifications.routeName,
                  showBottomMenu: _showBottomMenu)
              : null,
        ),
      ),
    );
  }

  Future<String?> getPageData(String value) async {
    return await AppSharedPreferences.getValue(key: value);
  }

  Future<String?> getNotificationCounts() async {
    return await AppSharedPreferences.getValue(key: 'notification_counts');
  }

  _setUserID() async {
    var prefUserID = await AppSharedPreferences.getValue(key: 'user_id');
    setState(() {
      _userID = prefUserID ?? "";
    });
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
    var pageData = await getPageData('page_notification');
    if (pageData != null) {
      var json = jsonDecode(pageData);
      setState(() {
        notifications = json
            .map<NotificationsData>((json) => NotificationsData.fromJson(json))
            .toList();
        loading = false;
      });
      // print("My Data: ${data[0].message}");
    }
  }
}
