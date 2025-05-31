import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobilizer/bloc/messages/messages_bloc.dart';
import 'package:mobilizer/bloc/posts/posts_bloc.dart';
import 'package:mobilizer/bloc/search/organization_bloc.dart';
import 'package:mobilizer/bloc/search/people_bloc.dart';
import 'package:mobilizer/pages/events/events.dart';
import 'package:mobilizer/pages/feed/feed.dart';

import 'package:mobilizer/pages/message/conversations_history.dart';
import 'package:mobilizer/pages/message/messages.dart';
import 'package:mobilizer/pages/notifications/notifications.dart';
import 'package:mobilizer/pages/organization/organization.dart';
import 'package:mobilizer/pages/profile/profile.dart';
import 'package:mobilizer/common/common/sharepreference.dart';
import 'package:mobilizer/pages/register2/register2.dart';
import 'package:mobilizer/pages/settings/settings.dart';
import 'package:mobilizer/pages/townhall_info/townhall_info_screen.dart';
import '../search/search.dart';
import 'package:badges/badges.dart';

class HomeScreen extends StatefulWidget {
  static String routeName = 'home_screen';
  //final int msgCounts;
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  int msgCounts = 0;
  int notCounts = 0;
  int eventCounts = 0;

  static List<Widget> _widgetOptions = <Widget>[
    Feed(),
    Search(),
    EventsScreen(),
    Notifications(),
    ConversationsHistory()
    //Profile(),
    //Settings()
  ];
  @override
  void initState() {
    _initNotification();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //msgCounts = msgCounts == 0 ? widget.msgCounts : msgCounts;
    PeopleBloc _peopleBloc;
    void _onItemTapped(int index) async {
      await AppSharedPreferences.setValue(
          key: 'townhallView', value: 'location');
      BlocProvider.of<MessagesBloc>(context).add(GetBulbNotifications());
      var visitedPageID = await getVisitedPageID();
      var noMsg = await getMessageCounts();
      var noNot = await getNotificationCounts();
      var noEvent = await getEventCounts();
      if (visitedPageID != null &&
          visitedPageID == index.toString() &&
          index.toString() == "0") {
        await AppSharedPreferences.setValue(key: 'pageID', value: '1');
        // Navigator.push(context, MaterialPageRoute(builder: (context) {
        //   return BlocProvider(
        //     create: (context) => OrganizationBloc(),
        //     child: OrganizationScreen(),
        //   );
        // }));
        //go to Organization page
      } else {
        // if (index.toString() == '4') {
        //   setState(() {
        //     msgCounts = 0;
        //   });
        //   AppSharedPreferences.setValue(key: 'message_counts', value: '0');
        // }
        if (index.toString() == '3') {
          setState(() {
            notCounts = 0;
          });
          AppSharedPreferences.setValue(key: 'notification_counts', value: '0');
        }
        if (index.toString() == '2') {
          setState(() {
            eventCounts = 0;
          });
          AppSharedPreferences.setValue(key: 'event_counts', value: '0');
        }
        setState(() {
          _selectedIndex = index;
          msgCounts = noMsg == null ? 0 : int.parse(noMsg);
          notCounts = noNot == null ? 0 : int.parse(noNot);
          eventCounts = noEvent == null ? 0 : int.parse(noEvent);
        });
        await AppSharedPreferences.setValue(
            key: 'pageID', value: index.toString());
      }
    }

    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.red,
        unselectedItemColor: Colors.grey,
        unselectedLabelStyle: const TextStyle(color: Colors.grey),
        showUnselectedLabels: true,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.all(4.0),
              child: Icon(Icons.home_filled),
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.all(4.0),
              child: Icon(Icons.search),
            ),
            label: 'Discover',
          ),
          BottomNavigationBarItem(
            icon: SizedBox(
              width: 50,
              child: Padding(
                padding: EdgeInsets.only(bottom: 4.0, left: 10),
                child: Stack(
                  alignment: Alignment.topLeft,
                  children: [
                    Icon(Icons.calendar_today_outlined),
                    eventCounts == 0
                        ? SizedBox()
                        : Positioned(
                            top: 0,
                            left: 15,
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: Container(
                                width: 15,
                                height: 15,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color: Colors.red, shape: BoxShape.circle),
                                child: Text(
                                  eventCounts.toString(),
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 14),
                                ),
                              ),
                            ),
                          )
                  ],
                ),
              ),
            ),
            label: 'Events',
          ),
          BottomNavigationBarItem(
            icon: SizedBox(
              width: 50,
              child: Padding(
                padding: EdgeInsets.only(bottom: 4.0, left: 11),
                child: Stack(
                  alignment: Alignment.topLeft,
                  children: [
                    Icon(Icons.notifications),
                    notCounts == 0
                        ? SizedBox()
                        : Positioned(
                            top: 0,
                            left: 15,
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: Container(
                                width: 15,
                                height: 15,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color: Colors.red, shape: BoxShape.circle),
                                child: Text(
                                  notCounts.toString(),
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 14),
                                ),
                              ),
                            ),
                          )
                  ],
                ),
              ),
            ),
            label: 'Notifications',
          ),
          // BottomNavigationBarItem(
          //   icon: Padding(
          //     padding: EdgeInsets.all(4.0),
          //     child: Icon(Icons.notifications),
          //   ),
          //   label: 'Webview',
          // ),
          // BottomNavigationBarItem(
          //   icon: SizedBox(
          //     width: 50,
          //     child: Padding(
          //       padding: EdgeInsets.only(bottom: 4.0, left: 11),
          //       child: Stack(alignment: Alignment.topLeft, children: [
          //         Icon(
          //           Icons.mail,
          //           size: 29,
          //         ),
          //         msgCounts == 0
          //             ? SizedBox()
          //             : Positioned(
          //                 top: 0,
          //                 left: 15,
          //                 child: SizedBox(
          //                   width: 20,
          //                   height: 20,
          //                   child: Container(
          //                     width: 15,
          //                     height: 15,
          //                     alignment: Alignment.center,
          //                     decoration: BoxDecoration(
          //                         color: Colors.red, shape: BoxShape.circle),
          //                     child: Text(
          //                       msgCounts.toString(),
          //                       style: TextStyle(
          //                           color: Colors.white, fontSize: 14),
          //                     ),
          //                   ),
          //                 ),
          //               )
          //       ]),
          //     ),
          //   ),
          //   label: 'Messages',
          // )
          // BottomNavigationBarItem(
          //   icon: Padding(
          //     padding: EdgeInsets.all(4.0),
          //     child: Icon(Icons.settings),
          //   ),
          //   label: 'Settings',
          // ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.lightBlue,
        onTap: _onItemTapped,
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
    );
  }

  Future<String?> getVisitedPageID() async {
    return await AppSharedPreferences.getValue(key: 'pageID');
  }

  Future<String?> getMessageCounts() async {
    return await AppSharedPreferences.getValue(key: 'message_counts');
  }

  Future<String?> getNotificationCounts() async {
    return await AppSharedPreferences.getValue(key: 'notification_counts');
  }

  Future<String?> getEventCounts() async {
    return await AppSharedPreferences.getValue(key: 'event_counts');
  }

  void _initNotification() async {
    BlocProvider.of<MessagesBloc>(context).add(GetBulbNotifications());
    var noMsg = await getMessageCounts();
    var noNot = await getNotificationCounts();
    var noEvent = await getEventCounts();
    setState(() {
      msgCounts = noMsg == null ? 0 : int.parse(noMsg);
      notCounts = noNot == null ? 0 : int.parse(noNot);
      eventCounts = noEvent == null ? 0 : int.parse(noEvent);
    });
  }
}
