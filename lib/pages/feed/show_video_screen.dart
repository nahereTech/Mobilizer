import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobilizer/bloc/auth/auth_bloc.dart';
import 'package:mobilizer/bloc/events/events_bloc.dart';
import 'package:mobilizer/bloc/messages/messages_bloc.dart';
import 'package:mobilizer/bloc/posts/posts_bloc.dart';
import 'package:mobilizer/bloc/search/organization_bloc.dart';
import 'package:mobilizer/bloc/search/organization_bloc.dart';
import 'package:mobilizer/bloc/search/organization_bloc.dart';
import 'package:mobilizer/bloc/search/people_bloc.dart';
import 'package:mobilizer/pages/home/home.dart';
import 'package:mobilizer/pages/organization/organization.dart';
import 'package:mobilizer/widget/video_build.dart';
import 'package:swipe_image_gallery/swipe_image_gallery.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:core';

import 'package:video_player/video_player.dart';

class ShowVideoScreen extends StatefulWidget {
  static String routeName = 'show_video_screen';
  ShowVideoScreen({required this.args, Key? key}) : super(key: key);
  List args;

  @override
  State<ShowVideoScreen> createState() => _ShowVideoScreenState();
}

class _ShowVideoScreenState extends State<ShowVideoScreen> {
  String _videoUrl = "";
  // String videoUrl =
  //     "https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4";
  @override
  void initState() {
    // TODO: implement initState
    Future.delayed(Duration.zero, () {
      // final args = ModalRoute.of(context)!.settings.arguments as List;
      setState(() {
        //args[0];
        _videoUrl = widget.args[0];
      });

      print("Arg: ${widget.args[0]}");
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            GestureDetector(
              onTap: () async {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return BlocProvider(
                    create: (context) => OrganizationBloc(),
                    child: OrganizationScreen(),
                  );
                }));
              },
              child: Container(
                padding: EdgeInsets.only(left: 1.0, right: 6.0, top: 2.0),
                height: 50.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          iconSize: 15,
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: FaIcon(
                            FontAwesomeIcons.arrowLeft,
                            size: 25,
                            color: Colors.blue,
                          ),
                        )
                      ],
                    ),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.end,
                    //   children: [
                    //     Container(
                    //       height: 30,
                    //       //width: 120,
                    //       padding: EdgeInsets.only(left: 5),
                    //       decoration: BoxDecoration(
                    //         border: Border.all(
                    //           color: Colors.blue,
                    //           width: 1,
                    //         ),
                    //         borderRadius: BorderRadius.circular(10),
                    //       ),
                    //       child: Row(
                    //         children: [
                    //           SizedBox(
                    //             width: 25,
                    //             child: IconButton(
                    //               padding: EdgeInsets.only(
                    //                   bottom: 3, right: 20.0),
                    //               onPressed: () async {
                    //                 Navigator.push(context,
                    //                     MaterialPageRoute(
                    //                         builder: (context) {
                    //                   return BlocProvider(
                    //                     create: (context) =>
                    //                         OrganizationBloc(),
                    //                     child: OrganizationScreen(),
                    //                   );
                    //                 }));
                    //               },
                    //               iconSize: 20,
                    //               icon: Icon(
                    //                 Icons.keyboard_arrow_down,
                    //                 color: Colors.blue,
                    //                 //size: 30,
                    //               ),
                    //             ),
                    //           ),
                    //         ],
                    //       ),
                    //     ),
                    //   ],
                    // ),
                  ],
                ),
              ),
            ),
            Center(
              child: _videoUrl == ""
                  ? Text("No video")
                  : VideoBuild(
                      videoUrl: _videoUrl,
                      // videoUrl:
                      //     "https://customer-tyfgbojlgvwqrwgf.cloudflarestream.com/dc2a5f888fbf326d4f2b16f31d413688/downloads/default.mp4",
                      // videoUrl:
                      //     "https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4",
                      looping: true,
                      autoplay: false),
            )
          ],
        ),
      ),
    );
  }
}
