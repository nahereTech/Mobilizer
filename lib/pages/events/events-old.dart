import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get_navigation/src/routes/get_transition_mixin.dart';
import 'package:indexed/indexed.dart';
import 'package:mobilizer/bloc/events/events_bloc.dart';
import 'package:mobilizer/common/common/navigation.dart';
import 'package:mobilizer/common/common/sharepreference.dart';
import 'package:mobilizer/models/events/event_create_response.dart';
import 'package:mobilizer/models/townhall/townhalls_user_is_leader_in_response.dart';
import 'package:mobilizer/pages/events/create_event.dart';
import 'package:mobilizer/pages/events/event_details.dart';
import 'package:mobilizer/pages/home/home.dart';
import 'package:mobilizer/pages/people/people_profile.dart';
import 'package:mobilizer/models/events/events_response.dart';

import 'package:getwidget/getwidget.dart';
import 'package:mobilizer/widget/bottom_navigational_bar.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:mobilizer/widget/image_swipe.dart';
import 'dart:io' show Platform;

class EventsScreen extends StatefulWidget {
  //final String? ref;
  const EventsScreen({Key? key}) : super(key: key);
  static String routeName = 'events';

  @override
  EventsScreenState createState() => EventsScreenState();
}

class EventsScreenState extends State<EventsScreen>
    with WidgetsBindingObserver {
  List<EventsData> data = [];
  List<Data> _townhalls = [];
  int count = 0;
  int _clickedID = -1;
  bool _isLeader = false; //Is leader in any townhall
  String? _isOrgLeader = "no";
  String _userID = '';

  double _previousOffset = 0;
  bool _showBottomMenu = true;
  bool _showCircleRow = true; // Initially show circle row
  late ScrollController _scrollController;

  bool loading = true; //loader
  // EventsBloc _eventsBloc = EventsBloc();

  void initState() {
    _setUserID();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    _getCachedData();
    _setLeader();
    WidgetsBinding.instance.addObserver(this);
    Future.delayed(Duration.zero, () {
      BlocProvider.of<EventsBloc>(context)
          .add(GetEventsEvent(page: 1, limit: 20));
      BlocProvider.of<EventsBloc>(context)
          .add(GetTownhallsUserIsLeaderInEvent());
    });
    super.initState();
  }

  void _scrollListener() {
    final currentOffset = _scrollController.offset;
    final direction = currentOffset - _previousOffset;

    setState(() {
      if (direction < 0) {
        // Scrolling up
        _showBottomMenu = true;
        _showCircleRow = true;
      } else if (direction > 0) {
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
    //final _eventsBloc = BlocProvider.of<EventsBloc>(context);
    //debugPrint("context in  - " + context.hashCode.toString());
    // final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
    //     GlobalKey<ScaffoldMessengerState>();
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Color.fromARGB(255, 255, 255, 255),
        statusBarColor: Theme.of(context).primaryColor,
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AnnotatedRegion<SystemUiOverlayStyle>(
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
                    title: Center(child: Text("Events")),
                    backgroundColor: Colors.white,
                  ),
                ),
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
                if (state is GetTownhallsUserIsLeaderInState) {
                  _townhalls = state.townhallList.data;
                  setState(() {
                    _isLeader = state.status;
                  });
                }
                if (state is LoadingState) {
                  loading = true;
                }
                if (state is DeleteEventState) {
                  print("clicked: ${_clickedID}");
                  ScaffoldMessenger.of(context).removeCurrentSnackBar();
                  loading = false;
                  final snackBar = SnackBar(
                      backgroundColor: Color.fromARGB(255, 85, 207, 120),
                      content: Text('Event was successfully deleted'));
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  setState(() {
                    data.removeAt(_clickedID);
                  });
                  if (data.length > 0) {
                    List<int> reindexedData = List.from(data);
                    AppSharedPreferences.setValue(
                        key: "page_event", value: jsonEncode(reindexedData));
                  } else {
                    AppSharedPreferences.removeValue(key: 'page_event');
                  }
                }
                if (state is NetworkState) {
                  loading = false;
                  print(state.message);
                  // loading = false;
                  if (data.length < 1) {
                    final snackBar = SnackBar(
                        backgroundColor: Color(0xFFcf5555),
                        content: Text(state.message.toString()));
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  }
                }
              },
              builder: (context, state) {
                double width = MediaQuery.of(context).size.width;
                double height = MediaQuery.of(context).size.height;
                print(width - 150);
                return Container(
                  child: Indexer(
                    children: [
                      if (loading == true && data.length < 1)
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
                      Column(
                        children: [
                          SizedBox(
                            height: 20,
                          ),
                          Expanded(
                            child: loading
                                ? SizedBox(width: 1)
                                : ListView.separated(
                                    controller: _scrollController,
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
                                          eventImages.add({
                                            'name': image.image_name,
                                            'type': image.type,
                                            'thumbnail': image.thumbnail,
                                          });
                                          print("Image: " +
                                              image.image_name.toString());
                                        }
                                      }
                                      final isDeleteAdd = new Map();

                                      return _listTile(
                                          eventsList.event_time_fulltxt
                                              .toString(),
                                          eventsList.event_icon.toString(),
                                          eventsList.title.toString(),
                                          eventsList.event_desc.toString(),
                                          eventsList.event_venue.toString(),
                                          eventsList.posted_in.toString(),
                                          eventsList.posted_by.toString(),
                                          eventImages,
                                          eventsList);
                                    }),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
            floatingActionButton: _fab(context),
            bottomNavigationBar: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: _showBottomMenu ? kBottomNavigationBarHeight : 0,
              child: _showBottomMenu
                  ? BottomNavigation(
                      page: EventsScreen.routeName,
                      showBottomMenu: _showBottomMenu)
                  : null,
            )),
      ),
    );
  }

  Widget _fab(BuildContext providerContext) {
    debugPrint("context in _fab - " + providerContext.hashCode.toString());
    return FloatingActionButton(
      onPressed: () async {
        var orgID = await getOrg();

        // final List values = Navigator.pushNamed(
        //   context,
        //   CreateEventScreen.routeName,
        // );

        // final List<String>? value = await Navigator.push(
        //   context,
        //   MaterialPageRoute(builder: (context) => CreateEventScreen()),
        // );

        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (contextA) => EventsBloc(),
              ),
            ],
            child: CreateEventScreen(
              townhalls: _townhalls,
            ),
          );
        }));

        // Navigator.pushNamed(context, CreateEventScreen.routeName,
        //         arguments: _townhalls)
        //     .then((value) {
        //   if (value != null) {
        //     setState(() {
        //       loading = true;
        //     });
        //     BlocProvider.of<EventsBloc>(context)
        //         .add(GetEventsEvent(page: 1, limit: 20));
        //     // final id = (value as Map)['event_id'];
        //     print("${value} ID");

        //     //emoji = (value as Map)['emoji'];
        //   }
        // });
      },
      backgroundColor: Colors.blue,
      child: const Icon(Icons.add, color: Colors.white),
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
      var json = jsonDecode(pageData);
      setState(() {
        data =
            json.map<EventsData>((json) => EventsData.fromJson(json)).toList();
        loading = false;
      });
      // print("My Data: ${data[0].message}");
    } else {
      setState(() {
        loading = true;
      });
    }
  }

  Widget _listTile(
      String time,
      String leadingIcon,
      String title,
      String description,
      String location,
      String townhall,
      String postedBy,
      List images,
      eventData) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        Map<String, dynamic> mapData = {
          'time': time,
          'leadingIcon': leadingIcon,
          'title': title,
          'description': description,
          'location': location,
          'townhall': townhall,
          'postedBy': postedBy,
          'media': images,
        };

        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (contextA) => EventsBloc(),
              ),
            ],
            child: EventDetailsScreen(
              mapData: mapData,
            ),
          );
        }));
      },
      child: Container(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage('${leadingIcon}'),
                  ),
                ],
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${title}',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                        SizedBox(width: 10),
                      ],
                    ),

                    // SizedBox(height: 1),
                    // const Text('@ugonwagba', style: TextStyle(color: Colors.grey, fontSize: 16),),
                    const SizedBox(height: 2),
                    GestureDetector(
                      onTap: () {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => EventDetailsScreen(),
                        //     settings: RouteSettings(
                        //       arguments: eventData,
                        //     ),
                        //   ),
                        // );
                      },
                      child: Text(
                        '${description.toString()}',
                        style: TextStyle(fontSize: 16),
                        maxLines: 2, // Limit the text to two lines
                        overflow: TextOverflow
                            .ellipsis, // Add ellipses (...) if the text overflows
                      ),
                    ),
                    SizedBox(height: 3),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.access_time_sharp,
                                color: Colors.grey, size: 18.0),
                            SizedBox(width: 5.0),
                            Text('${time}',
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 14.0)),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined,
                                color: Colors.grey, size: 18.0),
                            SizedBox(width: 5.0),
                            Text('${location}',
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 14.0)),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.chat_bubble_outline_outlined,
                                color: Colors.grey, size: 18.0),
                            SizedBox(width: 5.0),
                            Text('${townhall}',
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 14.0)),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.person_outline,
                                color: Colors.grey, size: 18.0),
                            SizedBox(width: 5.0),
                            Text('${postedBy}',
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 14.0)),
                          ],
                        ),
                      ],
                    ),

                    if (images.length > 0) ImageSwipe(imageList: images),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
