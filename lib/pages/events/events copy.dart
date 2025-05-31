import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:indexed/indexed.dart';
import 'package:mobilizer/bloc/events/events_bloc.dart';
import 'package:mobilizer/common/common/navigation.dart';
import 'package:mobilizer/common/common/sharepreference.dart';
import 'package:mobilizer/pages/events/create_event.dart';
import 'package:mobilizer/pages/events/event_details.dart';
import 'package:mobilizer/pages/home/home.dart';
import 'package:mobilizer/pages/people/people_profile.dart';
import 'package:mobilizer/models/events/events_response.dart';

import 'package:getwidget/getwidget.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:mobilizer/widget/image_swipe.dart';

class EventsScreen extends StatefulWidget {
  //final String? ref;
  const EventsScreen({Key? key}) : super(key: key);
  static String routeName = 'events';

  @override
  EventsScreenState createState() => EventsScreenState();
}

class EventsScreenState extends State<EventsScreen> {
  List<EventsData> data = [];
  int count = 0;
  String? _isOrgLeader = "no";
  bool loading = false; //loader
  EventsBloc _eventsBloc = EventsBloc();

  void initState() {
    _getCachedData();
    _setLeader();
    Future.delayed(Duration.zero, () {
      BlocProvider.of<EventsBloc>(context)
          .add(GetEventsEvent(page: 1, limit: 20));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //final _eventsBloc = BlocProvider.of<EventsBloc>(context);
    return SafeArea(
      child: Indexed(
        child: Scaffold(
          appBar: AppBar(
            toolbarHeight: 90,
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
              'Events',
              style: TextStyle(color: Colors.black),
            ),
          ),
          body: BlocConsumer<EventsBloc, EventsState>(
            listener: (context, state) {
              if (state is EventListState) {
                print("Am here");
                loading = false;
                data = state.eventsResponse.data!;
                print(data);
                AppSharedPreferences.setValue(
                    key: 'page_event', value: jsonEncode(data));
              }
              if (state is LoadingState) {
                loading = true;
              }
              if (state is DeleteEventState) {
                final snackBar = SnackBar(
                    backgroundColor: Color(0xFFcf5555),
                    content: Text('Event was successfully deleted'));
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              }
              if (state is NetworkState) {
                loading = false;
                print(state.message);
                // loading = false;
                final snackBar = SnackBar(
                    backgroundColor: Color(0xFFcf5555),
                    content: Text(state.message.toString()));
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              }
            },
            builder: (context, state) {
              double width = MediaQuery.of(context).size.width;
              double height = MediaQuery.of(context).size.height;
              print(width - 150);
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
                    if (data.length < 1 && loading == false)
                      Center(
                        child: Text("No Event"),
                      ),
                    BlocProvider(
                      create: (contextA) => EventsBloc(),
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
                                      final eventsList = data[index];
                                      List<dynamic> eventImages = [];

                                      if (eventsList.event_graphics != null) {
                                        for (EventImagesData image
                                            in eventsList.event_graphics!) {
                                          eventImages.add(image.image_name);
                                        }
                                      }
                                      final isDeleteAdd = new Map();

                                      return GestureDetector(
                                        onTap: () {
                                          // Navigator.push(
                                          //   context,
                                          //   MaterialPageRoute(
                                          //     builder: (context) =>
                                          //         EventDetailsScreen(),
                                          //     settings: RouteSettings(
                                          //       arguments: eventsList,
                                          //     ),
                                          //   ),
                                          // );
                                        },
                                        child: ListTile(
                                          title: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              SizedBox(
                                                width: width - 147,
                                                child: Text(
                                                  '${eventsList.title}',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                              eventsList.can_delete == "yes"
                                                  ? SizedBox(
                                                      height: 28,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(top: 8),
                                                        child: PopupMenuButton(
                                                          icon: ImageIcon(
                                                            AssetImage(
                                                                "images/dots.png"),
                                                            color: Colors.grey,
                                                            size: 20.0,
                                                          ),
                                                          onSelected: (choice) {
                                                            // print(
                                                            //     "My choice: ${choice}");
                                                            BlocProvider.of<
                                                                        EventsBloc>(
                                                                    context)
                                                                .add(
                                                              DeleteEvent(
                                                                  eventID:
                                                                      eventsList
                                                                          .id
                                                                          .toString()),
                                                            );
                                                          },
                                                          padding:
                                                              EdgeInsets.zero,
                                                          itemBuilder:
                                                              (BuildContext
                                                                  context) {
                                                            return [
                                                              'Delete',
                                                            ].map((String
                                                                choice) {
                                                              return PopupMenuItem<
                                                                  String>(
                                                                value: choice,
                                                                child: Text(
                                                                    choice),
                                                              );
                                                            }).toList();
                                                          },
                                                        ),
                                                      ),
                                                    )
                                                  : SizedBox(),
                                            ],
                                          ),
                                          subtitle: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(4.0),
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.access_time_sharp,
                                                      color: Colors.blue,
                                                      size: 20.0,
                                                      textDirection:
                                                          TextDirection.ltr,
                                                      semanticLabel:
                                                          'Icon', // Announced in accessibility modes (e.g TalkBack/VoiceOver). This label does not show in the UI.
                                                    ),
                                                    SizedBox(
                                                      width: 5,
                                                    ),
                                                    Text(
                                                        '${eventsList.event_time_fulltxt}'),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(4.0),
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons
                                                          .location_on_outlined,
                                                      color: Colors.blue,
                                                      size: 20.0,
                                                      textDirection:
                                                          TextDirection.ltr,
                                                      semanticLabel:
                                                          'Icon', // Announced in accessibility modes (e.g TalkBack/VoiceOver). This label does not show in the UI.
                                                    ),
                                                    SizedBox(
                                                      width: 5,
                                                    ),
                                                    Text(
                                                        '${eventsList.event_venue}'),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(4.0),
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons
                                                          .chat_bubble_outline_outlined,
                                                      color: Colors.blue,
                                                      size: 20.0,
                                                      textDirection:
                                                          TextDirection.ltr,
                                                      semanticLabel:
                                                          'Icon', // Announced in accessibility modes (e.g TalkBack/VoiceOver). This label does not show in the UI.
                                                    ),
                                                    SizedBox(
                                                      width: 5,
                                                    ),
                                                    Text(
                                                        '${eventsList.posted_in}'),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(4.0),
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.person_outline,
                                                      color: Colors.blue,
                                                      size: 20.0,
                                                      textDirection:
                                                          TextDirection.ltr,
                                                      semanticLabel:
                                                          'Icon', // Announced in accessibility modes (e.g TalkBack/VoiceOver). This label does not show in the UI.
                                                    ),
                                                    SizedBox(
                                                      width: 5,
                                                    ),
                                                    Text(
                                                        '${eventsList.posted_by}'),
                                                  ],
                                                ),
                                              ),
                                              Text(
                                                  '${_substring(eventsList.event_desc_complete.toString(), 90)}'),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              if (eventImages.length > 0)
                                                ImageSwipe(
                                                    imageList: eventImages),
                                            ],
                                          ),
                                          leading: CircleAvatar(
                                            radius: 25,
                                            backgroundColor: Colors.grey,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                              child: Image.network(
                                                '${eventsList.event_icon}',
                                                width: 50,
                                                height: 50,
                                                fit: BoxFit.cover,
                                              ),
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
          floatingActionButton: _isOrgLeader == "yes"
              ? FloatingActionButton(
                  onPressed: () async {
                    var orgID = await getOrg();
                    // Navigator.push(context,
                    //     MaterialPageRoute(builder: (context) {
                    //   return BlocProvider<EventsBloc>(
                    //     create: (BuildContext contextA) => EventsBloc(),
                    //     child: CreateEventScreen(),
                    //   );
                    // }));
                  },
                  backgroundColor: Colors.blue,
                  child: const Icon(Icons.add),
                )
              : null,
        ),
      ),
    );
  }

  _setLeader() async {
    var v = await getIsOrgLeader();
    print("Leader: ${v}");
    setState(() {
      _isOrgLeader = v;
    });
  }

  _getCachedData() async {
    var pageData = await getPageData('page_event');
    if (pageData != null) {
      var json = jsonDecode(pageData!);
      setState(() {
        data =
            json.map<EventsData>((json) => EventsData.fromJson(json)).toList();
        loading = false;
      });
      // print("My Data: ${data[0].message}");
    }
  }

  String _substring(String char, int count) {
    return char.length > count ? char.substring(0, count) + '...' : char;
  }

  Future<String?> getIsOrgLeader() async {
    return await AppSharedPreferences.getValue(key: 'isOrgLeader');
  }

  Future<String?> getPageData(String value) async {
    return await AppSharedPreferences.getValue(key: value);
  }

  Future<String?> getOrg() async {
    return await AppSharedPreferences.getValue(key: 'orgID');
  }
}
