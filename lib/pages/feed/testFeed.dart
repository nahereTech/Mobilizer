import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
// import '../views/chat_page.dart';
// import '../_commons/bottomnav_widget.dart';
// import '../_commons/appbar_widget.dart';

class NotificationsPage extends StatefulWidget {
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<Map<String, dynamic>> _notifications = [
    {
      'profile_pic':
          'https://imagedelivery.net/BgK_7WpdFl6ls9CBX3q89Q/28da1872-8865-47fa-edae-a0f0c6a3a200/mid',
      'message': 'Abraham liked your kulturee',
    },
    {
      'profile_pic':
          'https://imagedelivery.net/BgK_7WpdFl6ls9CBX3q89Q/28da1872-8865-47fa-edae-a0f0c6a3a200/mid',
      'message': 'John commented on your post',
    },
    {
      'profile_pic':
          'https://imagedelivery.net/BgK_7WpdFl6ls9CBX3q89Q/28da1872-8865-47fa-edae-a0f0c6a3a200/mid',
      'message': 'Jane shared your story',
    },
    {
      'profile_pic':
          'https://imagedelivery.net/BgK_7WpdFl6ls9CBX3q89Q/28da1872-8865-47fa-edae-a0f0c6a3a200/mid',
      'message': 'Abraham liked your kulturee',
    },
    {
      'profile_pic':
          'https://imagedelivery.net/BgK_7WpdFl6ls9CBX3q89Q/28da1872-8865-47fa-edae-a0f0c6a3a200/mid',
      'message': 'John commented on your post',
    },
    {
      'profile_pic':
          'https://imagedelivery.net/BgK_7WpdFl6ls9CBX3q89Q/28da1872-8865-47fa-edae-a0f0c6a3a200/mid',
      'message': 'Jane shared your story',
    },
    {
      'profile_pic':
          'https://imagedelivery.net/BgK_7WpdFl6ls9CBX3q89Q/28da1872-8865-47fa-edae-a0f0c6a3a200/mid',
      'message': 'Abraham liked your kulturee',
    },
    {
      'profile_pic':
          'https://imagedelivery.net/BgK_7WpdFl6ls9CBX3q89Q/28da1872-8865-47fa-edae-a0f0c6a3a200/mid',
      'message': 'John commented on your post',
    },
    {
      'profile_pic':
          'https://imagedelivery.net/BgK_7WpdFl6ls9CBX3q89Q/28da1872-8865-47fa-edae-a0f0c6a3a200/mid',
      'message': 'Jane shared your story',
    },
    {
      'profile_pic':
          'https://imagedelivery.net/BgK_7WpdFl6ls9CBX3q89Q/28da1872-8865-47fa-edae-a0f0c6a3a200/mid',
      'message': 'Abraham liked your kulturee',
    },
    {
      'profile_pic':
          'https://imagedelivery.net/BgK_7WpdFl6ls9CBX3q89Q/28da1872-8865-47fa-edae-a0f0c6a3a200/mid',
      'message': 'John commented on your post',
    },
    {
      'profile_pic':
          'https://imagedelivery.net/BgK_7WpdFl6ls9CBX3q89Q/28da1872-8865-47fa-edae-a0f0c6a3a200/mid',
      'message': 'Jane shared your story',
    },
    {
      'profile_pic':
          'https://imagedelivery.net/BgK_7WpdFl6ls9CBX3q89Q/28da1872-8865-47fa-edae-a0f0c6a3a200/mid',
      'message': 'Abraham liked your kulturee',
    },
    {
      'profile_pic':
          'https://imagedelivery.net/BgK_7WpdFl6ls9CBX3q89Q/28da1872-8865-47fa-edae-a0f0c6a3a200/mid',
      'message': 'John commented on your post',
    },
    {
      'profile_pic':
          'https://imagedelivery.net/BgK_7WpdFl6ls9CBX3q89Q/28da1872-8865-47fa-edae-a0f0c6a3a200/mid',
      'message': 'Jane shared your story',
    },
    {
      'profile_pic':
          'https://imagedelivery.net/BgK_7WpdFl6ls9CBX3q89Q/28da1872-8865-47fa-edae-a0f0c6a3a200/mid',
      'message': 'Jane shared your story',
    },
    {
      'profile_pic':
          'https://imagedelivery.net/BgK_7WpdFl6ls9CBX3q89Q/28da1872-8865-47fa-edae-a0f0c6a3a200/mid',
      'message': 'Jane shared your story',
    },
    {
      'profile_pic':
          'https://imagedelivery.net/BgK_7WpdFl6ls9CBX3q89Q/28da1872-8865-47fa-edae-a0f0c6a3a200/mid',
      'message': 'Jane shared your story',
    },
    {
      'profile_pic':
          'https://imagedelivery.net/BgK_7WpdFl6ls9CBX3q89Q/28da1872-8865-47fa-edae-a0f0c6a3a200/mid',
      'message': 'Jane shared your story',
    },
    {
      'profile_pic':
          'https://imagedelivery.net/BgK_7WpdFl6ls9CBX3q89Q/28da1872-8865-47fa-edae-a0f0c6a3a200/mid',
      'message': 'Jane shared your story',
    },
    {
      'profile_pic':
          'https://imagedelivery.net/BgK_7WpdFl6ls9CBX3q89Q/28da1872-8865-47fa-edae-a0f0c6a3a200/mid',
      'message': 'Jane shared your story',
    },
    {
      'profile_pic':
          'https://imagedelivery.net/BgK_7WpdFl6ls9CBX3q89Q/28da1872-8865-47fa-edae-a0f0c6a3a200/mid',
      'message': 'Jane shared your story',
    },
    // Add more notifications here as needed
  ];

  String _profilePicPath =
      'https://imagedelivery.net/BgK_7WpdFl6ls9CBX3q89Q/28da1872-8865-47fa-edae-a0f0c6a3a200/mid';

  @override
  void initState() {
    super.initState();
    _loadProfilePic();
  }

  Future<void> _loadProfilePic() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _profilePicPath = prefs.getString('profile_pic') ?? '';
    });
  }

  Widget _buildPostList() {
    return Column(
      children: _notifications.map((notification) {
        return Container(
          margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          padding: EdgeInsets.all(0.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 1,
                blurRadius: 5,
                offset: Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 16.0, top: 16.0),
                          child: GestureDetector(
                            onTap: () {},
                            child: CircleAvatar(
                              backgroundImage: CachedNetworkImageProvider(
                                  notification['profile_pic']),
                              radius: 24,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                                left: 14.0, top: 16.0, right: 16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  notification['message'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                                SizedBox(height: 4.0),
                                Text(
                                  'Just now', // Example subtext, you can change it accordingly
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10.0),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.white, // Make status bar white
      statusBarIconBrightness: Brightness.dark, // Dark icons on the status bar
      systemNavigationBarColor:
          Colors.white, // Make bottom navigation bar white
      systemNavigationBarIconBrightness:
          Brightness.dark, // Dark icons on the bottom navigation bar
    ));

    return Scaffold(
        // extendBodyBehindAppBar: true,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFd0e4f7),
                Color(0xFFDBD7C8),
                Color(0xFFEDD1DD),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.0, 0.5, 1.0],
              tileMode: TileMode.clamp,
            ),
          ),
          child: NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return buildSliverAppBar(context, _profilePicPath);
            },
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 15.0, top: 10, bottom: 10),
                    child: Text(
                      'Notifications',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontFamily: 'Arial',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildPostList(),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          backgroundColor: Colors.blue, // Set background color to blue
          child: Icon(Icons.post_add, color: Colors.white), // Add post icon
        ),
        bottomNavigationBar: null
        // CustomBottomNavigationBar(),
        );
  }

  List<Widget> buildSliverAppBar(BuildContext context, String profilePicPath) {
    // void _handleProfilePicTap() {
    //   // Do something when the profile picture is tapped
    //   Navigator.push(
    //     context,
    //     MaterialPageRoute(builder: (context) => ProfilePage()),
    //   );
    // }

    return [
      SliverAppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Image.asset(
              'images/icon_blue.png',
              height: 25,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 8),
            // Add a placeholder SizedBox to separate the logo and profile icon
            Expanded(child: Container()),
            // Circular profile icon
            GestureDetector(
              onTap: null,
              child: CircleAvatar(
                backgroundImage: NetworkImage(
                    profilePicPath), // _profilePicUrl should be the URL of the network image
                radius: 18,
              ),
            ),
          ],
        ),
        automaticallyImplyLeading: false,
        floating: true,
        snap: true,
      ),
    ];
  }
}
