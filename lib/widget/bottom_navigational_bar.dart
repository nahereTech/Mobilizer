import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobilizer/bloc/auth/auth_bloc.dart';
import 'package:mobilizer/bloc/events/events_bloc.dart';
import 'package:mobilizer/bloc/messages/messages_bloc.dart';
import 'package:mobilizer/bloc/posts/posts_bloc.dart';
import 'package:mobilizer/bloc/search/organization_bloc.dart';
import 'package:mobilizer/bloc/search/people_bloc.dart';
import 'package:mobilizer/common/common/sharepreference.dart';
import 'package:mobilizer/pages/events/events.dart';
import 'package:mobilizer/pages/feed/feed.dart';
import 'package:mobilizer/pages/message/conversations_history.dart';
import 'package:mobilizer/pages/notifications/notifications.dart';
import 'package:mobilizer/pages/push_notification/post_notification_screen.dart';
import 'package:mobilizer/pages/search/search.dart';
import 'dart:io';

import 'package:mobilizer/pages/settings/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BottomNavigation extends StatefulWidget {
  bool showBottomMenu;
  String page;
  BottomNavigation({required this.page, required this.showBottomMenu});

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  int unread = 0;
  @override
  void initState() {
    _loadProfileImage();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      try {
        print('Received a message in the foreground: ${message.messageId}');
        print(message.notification!.title);
        print(message.notification!.body);
        print(message.data);
        //print("Item ID" + message.data["unread"].toString());
        setState(() {
          unread = int.parse(message.data["unread"].toString());
          AppSharedPreferences.setInt(
              key: 'unreadMessages', value: int.parse(unread.toString()));
        });
      } catch (e) {
        print(e.toString());
      }
      // Handle the message here
    });
    // TODO: implement initState
    super.initState();
  }

  String profileImage = '';
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: widget.showBottomMenu ? kBottomNavigationBarHeight : 0,
      child: widget.showBottomMenu
          ? Platform.isIOS
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.home_outlined,
                        color:
                            widget.page == "feed_screen" ? Colors.blue : null,
                      ),
                      onPressed: () async {
                        print("Am Print");
                        await AppSharedPreferences.setValue(
                            key: 'currentViewedPage', value: 'feed');
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return MultiBlocProvider(
                            providers: [
                              BlocProvider(
                                create: (contextA) => PeopleBloc(),
                              ),
                              BlocProvider(
                                create: (context) => PostsBloc(),
                              ),
                              BlocProvider(
                                  create: (context) => OrganizationBloc()),
                            ],
                            child: Feed(),
                          );
                        }));
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.search_outlined,
                        color: widget.page == "search" ? Colors.blue : null,
                      ),
                      onPressed: () async {
                        await AppSharedPreferences.setValue(
                            key: 'currentViewedPage', value: 'search');
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return MultiBlocProvider(
                            providers: [
                              BlocProvider(
                                create: (contextA) => PeopleBloc(),
                              ),
                              BlocProvider(
                                create: (context) => PostsBloc(),
                              ),
                              BlocProvider(
                                  create: (context) => OrganizationBloc()),
                            ],
                            child: Search(),
                          );
                        }));
                      },
                    ),
                    // IconButton(
                    //   icon: Icon(Icons.event_outlined,
                    //       color: widget.page == "events" ? Colors.blue : null),
                    //   onPressed: () async {
                    //     await AppSharedPreferences.setValue(
                    //         key: 'currentViewedPage', value: 'events');
                    //     Navigator.push(context,
                    //         MaterialPageRoute(builder: (context) {
                    //       return MultiBlocProvider(
                    //         providers: [
                    //           BlocProvider(
                    //             create: (contextA) => EventsBloc(),
                    //           ),
                    //           // BlocProvider(
                    //           //   create: (context) => PostsBloc(),
                    //           // ),
                    //           // BlocProvider(
                    //           //     create: (context) => OrganizationBloc()),
                    //         ],
                    //         child: EventsScreen(),
                    //       );
                    //     }));
                    //   },
                    // ),
                    IconButton(
                        icon: Icon(Icons.notifications_outlined,
                            color: widget.page == "notification"
                                ? Colors.blue
                                : null),
                        onPressed: () async {
                          await AppSharedPreferences.setValue(
                              key: 'currentViewedPage', value: 'notification');
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return MultiBlocProvider(
                              providers: [
                                BlocProvider(
                                  create: (contextA) => PostsBloc(),
                                ),
                              ],
                              child: Notifications(),
                            );
                          }));
                        }),
                    IconButton(
                      icon: Icon(Icons.chat_outlined,
                          color: widget.page == "chat" ? Colors.blue : null),
                      onPressed: () async {
                        //store unread messages counts
                        await AppSharedPreferences.setInt(
                            key: 'unreadMessages', value: unread);
                        await Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return BlocProvider(
                            create: (context) => MessagesBloc(),
                            child: ConversationsHistory(),
                          );
                        })).then((value) async {
                          //when back clicked change value in unread to the val in preference
                          // setState(() {
                          //   unread =  AppSharedPreferences.getInt(
                          //       key: 'unreadMessages');
                          // });
                          final prefUnread = await AppSharedPreferences.getInt(
                              key: 'unreadMessages');
                          setState(() {
                            unread = int.parse(prefUnread.toString());
                          });
                        });
                      },
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return BlocProvider(
                            create: (context) => AuthBloc(),
                            child: Settings(),
                          );
                        }));
                      },
                      child: Container(
                        width: 36, // Adjust based on your desired thickness
                        height: 36, // Adjust based on your desired thickness
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.grey, // Choose your border color
                            width: 1.0, // Adjust the thickness of the border
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 14,
                          backgroundImage: NetworkImage(
                            profileImage == ""
                                ? 'https://imagedelivery.net/BgK_7WpdFl6ls9CBX3q89Q/90b1661f-f2a7-47eb-414f-c7e79ceacd00/mid'
                                : profileImage,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : BottomAppBar(
                  height: 56,
                  color: Color.fromARGB(179, 255, 255, 255),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.home_outlined,
                          color:
                              widget.page == "feed_screen" ? Colors.blue : null,
                        ),
                        onPressed: () async {
                          print("Am Print");
                          await AppSharedPreferences.setValue(
                              key: 'currentViewedPage', value: 'feed');
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return MultiBlocProvider(
                              providers: [
                                BlocProvider(
                                  create: (contextA) => PeopleBloc(),
                                ),
                                BlocProvider(
                                  create: (context) => PostsBloc(),
                                ),
                                BlocProvider(
                                    create: (context) => OrganizationBloc()),
                              ],
                              child: Feed(),
                            );
                          }));
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.search_outlined,
                          color: widget.page == "search" ? Colors.blue : null,
                        ),
                        onPressed: () async {
                          await AppSharedPreferences.setValue(
                              key: 'currentViewedPage', value: 'search');
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return MultiBlocProvider(
                              providers: [
                                BlocProvider(
                                  create: (contextA) => PeopleBloc(),
                                ),
                                BlocProvider(
                                  create: (context) => PostsBloc(),
                                ),
                                BlocProvider(
                                    create: (context) => OrganizationBloc()),
                              ],
                              child: Search(),
                            );
                          }));
                        },
                      ),
                      // IconButton(
                      //   icon: Icon(Icons.event_outlined,
                      //       color:
                      //           widget.page == "events" ? Colors.blue : null),
                      //   onPressed: () async {
                      //     await AppSharedPreferences.setValue(
                      //         key: 'currentViewedPage', value: 'events');
                      //     Navigator.push(context,
                      //         MaterialPageRoute(builder: (context) {
                      //       return MultiBlocProvider(
                      //         providers: [
                      //           BlocProvider(
                      //             create: (contextA) => EventsBloc(),
                      //           ),
                      //           // BlocProvider(
                      //           //   create: (context) => PostsBloc(),
                      //           // ),
                      //           // BlocProvider(
                      //           //     create: (context) => OrganizationBloc()),
                      //         ],
                      //         child: EventsScreen(),
                      //       );
                      //     }));
                      //   },
                      // ),
                      IconButton(
                          icon: Icon(Icons.notifications_outlined,
                              color: widget.page == "notification"
                                  ? Colors.blue
                                  : null),
                          onPressed: () async {
                            await AppSharedPreferences.setValue(
                                key: 'currentViewedPage',
                                value: 'notification');
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return MultiBlocProvider(
                                providers: [
                                  BlocProvider(
                                    create: (contextA) => PostsBloc(),
                                  ),
                                ],
                                child: Notifications(),
                              );
                            }));

                            //  Navigator.push(context,
                            //     MaterialPageRoute(builder: (context) {
                            //   return MultiBlocProvider(
                            //     providers: [
                            //       BlocProvider(
                            //         create: (contextA) => PostsBloc(),
                            //       ),
                            //     ],
                            //     child: PostNotificationScreen(),
                            //   );
                            // }));
                            // pushNamed(PostNotificationScreen.routeName, arguments: {
                            //   'item_id': event.data['item_id'],
                            //   'org_id': event.data['org_id'],
                            //   'org_name': event.data['org_name'],
                            //   'townhall_id': event.data['townhall_id'],
                            //   'n_type': event.data['notification_type'],
                            // });
                            // Navigator.pushNamed(
                            //     context, PostNotificationScreen.routeName,
                            //     arguments: {
                            //       'item_id': '53067',
                            //       'org_id': '5',
                            //       'org_name': 'Obidient',
                            //       'townhall_id': '5',
                            //       'n_type': 'post',
                            //     });
                          }),
                      Stack(
                        children: [
                          IconButton(
                            icon: Icon(Icons.chat_outlined,
                                color:
                                    widget.page == "chat" ? Colors.blue : null),
                            onPressed: () async {
                              //store unread messages counts
                              await AppSharedPreferences.setInt(
                                  key: 'unreadMessages', value: unread);
                              await Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return BlocProvider(
                                  create: (context) => MessagesBloc(),
                                  child: ConversationsHistory(),
                                );
                              })).then((value) async {
                                //when back clicked change value in unread to the val in preference
                                final prefUnread =
                                    await AppSharedPreferences.getInt(
                                        key: 'unreadMessages');
                                setState(() {
                                  unread = int.parse(prefUnread.toString());
                                });
                              });
                            },
                          ),
                          unread == 0
                              ? SizedBox()
                              : Positioned(
                                  right: 0,
                                  top: 0,
                                  child: CircleAvatar(
                                    radius: 10,
                                    backgroundColor: Colors.red,
                                    child: Text(
                                      unread.toString(),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return BlocProvider(
                              create: (context) => AuthBloc(),
                              child: Settings(),
                            );
                          }));
                        },
                        child: Container(
                          width: 36, // Adjust based on your desired thickness
                          height: 36, // Adjust based on your desired thickness
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.grey, // Choose your border color
                              width: 1.0, // Adjust the thickness of the border
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 14,
                            backgroundImage: NetworkImage(
                              profileImage == ""
                                  ? 'https://imagedelivery.net/BgK_7WpdFl6ls9CBX3q89Q/90b1661f-f2a7-47eb-414f-c7e79ceacd00/mid'
                                  : profileImage,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
          : null,
    );
  }

  Future<void> _loadProfileImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      profileImage = prefs.getString('profilePic') ?? 'default_image_path';
    });
  }
}
