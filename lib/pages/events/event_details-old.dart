import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:indexed/indexed.dart';
import 'package:mobilizer/bloc/posts/posts_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:bloc/bloc.dart';
import 'package:mobilizer/common/common/sharepreference.dart';
import 'package:mobilizer/models/events/events_response.dart';
import 'package:mobilizer/models/townhall/townhall_info_response.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:mobilizer/widget/image_swipe.dart';

class EventDetailsScreen extends StatefulWidget {
  Map<String, dynamic> mapData;
  EventDetailsScreen({required this.mapData, Key? key}) : super(key: key);

  static String routeName = 'event_detail_screen';

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  // final postsBloc = PostsBloc();
  // List<RepData> repData = [];
  // late String townhallName, townhallAbout;
  // List<EventsData> events = [];
  // bool noResult = false;
  List<dynamic> eventImages = [];
  bool loading = true;
  void initState() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
          'Event Details',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.grey,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Image.network(
                        //'${event.event_icon}',
                        "${widget.mapData['leadingIcon']}",
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(
                            '${widget.mapData['title']}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.access_time_sharp,
                                color: Colors.blue,
                                size: 20.0,
                                textDirection: TextDirection.ltr,
                                semanticLabel:
                                    'Icon', // Announced in accessibility modes (e.g TalkBack/VoiceOver). This label does not show in the UI.
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text('${widget.mapData['time']}'),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                color: Colors.blue,
                                size: 20.0,
                                textDirection: TextDirection.ltr,
                                semanticLabel:
                                    'Icon', // Announced in accessibility modes (e.g TalkBack/VoiceOver). This label does not show in the UI.
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text('${widget.mapData['location']}'),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.chat_bubble_outline_outlined,
                                color: Colors.blue,
                                size: 20.0,
                                textDirection: TextDirection.ltr,
                                semanticLabel:
                                    'Icon', // Announced in accessibility modes (e.g TalkBack/VoiceOver). This label does not show in the UI.
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text('${widget.mapData['townhall']}'),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.person_outline,
                                color: Colors.blue,
                                size: 20.0,
                                textDirection: TextDirection.ltr,
                                semanticLabel:
                                    'Icon', // Announced in accessibility modes (e.g TalkBack/VoiceOver). This label does not show in the UI.
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text('${widget.mapData['postedBy']}'),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Text('${widget.mapData['description']}'),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        if (widget.mapData['media'] != null)
                          ImageSwipe(imageList: widget.mapData['media']),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
