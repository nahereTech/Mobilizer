import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mobilizer/common/common/sharepreference.dart';
import 'package:mobilizer/common/common/constants.dart';
import 'package:mobilizer/models/notifications/notifications_response.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:mobilizer/pages/menu/bottom_menu.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:mobilizer/common/common/theme_provider.dart';
import 'package:shimmer/shimmer.dart'; // Add shimmer import
import 'package:html/parser.dart' as html_parser; // Add this import
import 'package:mobilizer/pages/people/people_profile.dart';

class Notifications extends StatefulWidget {
  const Notifications({Key? key}) : super(key: key);
  static String routeName = 'notification';

  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> with WidgetsBindingObserver {
  List<NotificationsData> notifications = [];
  bool loading = true;
  bool noResult = false;
  double _previousOffset = 0;
  bool _showBottomMenu = true;
  bool _showCircleRow = true;
  late ScrollController _scrollController;
  String _userID = '';
  String _token = '';
  int _page = 1;
  final int _limit = 25;

  double _bottomMenuProgress = 1.0;
  static const double _bottomMenuHeight = 60.0;
  static const double _scrollThreshold = 300.0;

  @override
  void initState() {
    super.initState();
    _setUserID();
    _setToken();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    WidgetsBinding.instance.addObserver(this);
    _loadInitialData();
  }

  void _scrollListener() {
    final currentOffset = _scrollController.offset;
    final direction = currentOffset - _previousOffset;

    if (!mounted) return;
    setState(() {
      if (direction > 0) {
        _bottomMenuProgress -= direction / _scrollThreshold;
      } else if (direction < 0) {
        _bottomMenuProgress += (-direction) / _scrollThreshold;
      }
      _bottomMenuProgress = _bottomMenuProgress.clamp(0.0, 1.0);
      _showBottomMenu = _bottomMenuProgress > 0.5;
      _showCircleRow = direction < 0;
      _previousOffset = currentOffset;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    await _getCachedData();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    try {
      final response = await http.get(
        Uri.parse('$base_url/townhall/list_notifications?page=$_page&limit=$_limit'),
        headers: <String, String>{
          'Accept': 'application/json',
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': token ?? '',
        },
      ).timeout(const Duration(seconds: 60));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200 && jsonResponse['status'] == true) {
        final notificationsResponse = NotificationsResponse.fromJson(jsonResponse);
        print('Parsed notifications: ${notificationsResponse.data?.length} items');
        setState(() {
          notifications = notificationsResponse.data ?? [];
          loading = false;
          noResult = notifications.isEmpty;
          print('Notifications list length: ${notifications.length}');
          AppSharedPreferences.setValue(
            key: 'page_notification',
            value: jsonEncode(notifications.map((e) => e.toJson()).toList()),
          );
        });
      } else {
        print('API returned unsuccessful: ${jsonResponse['msg']}');
        setState(() {
          notifications = [];
          loading = false;
          noResult = true;
        });
      }
    } catch (e) {
      setState(() {
        loading = false;
        noResult = true;
      });
      print('Error fetching notifications: $e');
    }
  }

  Widget _buildShimmerLoader() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: themeProvider.isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
          highlightColor: themeProvider.isDarkMode ? Colors.grey[600]! : Colors.grey[100]!,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 15,
                    backgroundColor: Colors.grey,
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 16.0,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 8.0),
                        Container(
                          width: 100.0,
                          height: 12.0,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: themeProvider.isDarkMode ? Brightness.light : Brightness.dark,
      statusBarBrightness: themeProvider.isDarkMode ? Brightness.dark : Brightness.light,
    ));

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight + 20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: _bottomMenuProgress > 0.5 ? kToolbarHeight + 15 : 0,
          child: AppBar(
            title: Text("Notification"),
            centerTitle: true,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(
                Icons.arrow_back,
                color: themeProvider.isDarkMode ? Colors.white : Colors.blue,
              ),
            ),
            elevation: 2,
          ),
        ),
      ),
      body: SafeArea(
        child: loading
            ? _buildShimmerLoader()
            : notifications.isEmpty
                ? Center(
                    child: Text(
                      "No notifications found.",
                      style: TextStyle(
                        color: themeProvider.isDarkMode ? Colors.white70 : Colors.grey,
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.only(
                      left: 16.0,
                      right: 16.0,
                      top: 8.0,
                      bottom: _bottomMenuHeight * _bottomMenuProgress + 40.0,
                    ),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final item = notifications[index];
                      DateTime notTime = DateFormat("yyyy-MM-dd hh:mm:ss").parse(item.date!);
                      return GestureDetector(
                        onTap: () {
                          if (item.notification_type == "follow") {
                            // Prepare mapData for PeopleProfile with username
                            Map<String, dynamic> mapData = {
                              'subjectID': item.sender_id.toString(),
                              'picture': item.notification_image ?? '',
                              'post_update_by': item.sender_names ?? '',
                              'username': item.username ?? '', // Now using the username from the endpoint
                            };
                            
                            // Navigate to PeopleProfile
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PeopleProfile(mapData: mapData),
                              ),
                            );
                          }
                          // Add else if conditions for other notification types if needed
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          decoration: BoxDecoration(
                            color: themeProvider.isDarkMode ? const Color(0xFF1E1E1E) : Colors.grey[200],
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: themeProvider.isDarkMode ? Colors.grey[700] : Colors.grey[300],
                                  backgroundImage: NetworkImage(item.notification_image ?? ''),
                                ),
                                const SizedBox(width: 16.0),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        htmlToPlainText(item.notification_txt ?? ''),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                                          fontSize: 16.0,
                                        ),
                                      ),
                                      const SizedBox(height: 4.0),
                                      Text(
                                        timeago.format(notTime),
                                        style: TextStyle(
                                          fontSize: 13.0,
                                          color: themeProvider.isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
      ),
      bottomNavigationBar: BottomMenu(
        bottomMenuProgress: _bottomMenuProgress,
        bottomMenuHeight: _bottomMenuHeight,
      ),
    );
  }

  String htmlToPlainText(String htmlString) {
    var document = html_parser.parse(htmlString);
    return document.body?.text ?? '';
  }

  Future<void> _setUserID() async {
    var prefUserID = await AppSharedPreferences.getValue(key: 'user_id');
    setState(() {
      _userID = prefUserID ?? "";
    });
  }

  Future<void> _setToken() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    setState(() {
      _token = token ?? "";
    });
  }

  Future<void> _getCachedData() async {
    var pageData = await AppSharedPreferences.getValue(key: 'page_notification');
    if (pageData != null) {
      var json = jsonDecode(pageData);
      setState(() {
        notifications = json.map<NotificationsData>((json) => NotificationsData.fromJson(json)).toList();
        loading = notifications.isEmpty;
        noResult = notifications.isEmpty;
      });
    } else {
      setState(() {
        loading = true;
      });
    }
  }
}

// ... (NotificationsResponse and NotificationsData classes remain unchanged)

class NotificationsResponse {
  bool? status;
  String? msg;
  String? tag;
  List<NotificationsData>? data;

  NotificationsResponse({this.status, this.msg, this.tag, this.data});

  factory NotificationsResponse.fromJson(Map<String, dynamic> json) {
    return NotificationsResponse(
      status: json['status'] as bool?,
      msg: json['msg'] as String?,
      tag: json['tag'] as String?,
      data: json['data'] != null
          ? (json['data'] as List<dynamic>)
              .map((e) => NotificationsData.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }
}

class NotificationsData {
  int? id;
  String? notification_txt;
  String? date;
  String? notification_type;
  int? subjects_id;
  int? sender_id;
  String? sender_names;
  String? username; // Add this field
  String? notification_image;

  NotificationsData({
    this.id,
    this.notification_txt,
    this.date,
    this.notification_type,
    this.subjects_id,
    this.sender_id,
    this.sender_names,
    this.username, // Add this to constructor
    this.notification_image,
  });

  factory NotificationsData.fromJson(Map<String, dynamic> json) {
    return NotificationsData(
      id: json['id'] as int?,
      notification_txt: json['notification_txt'] as String?,
      date: json['date'] as String?,
      notification_type: json['notification_type'] as String?,
      subjects_id: json['subjects_id'] as int?,
      sender_id: json['sender_id'] as int?,
      sender_names: json['sender_names'] as String?,
      username: json['username'] as String?, // Add this parsing
      notification_image: json['notification_image'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'notification_txt': notification_txt,
        'date': date,
        'notification_type': notification_type,
        'subjects_id': subjects_id,
        'sender_id': sender_id,
        'sender_names': sender_names,
        'username': username, // Add this to JSON serialization
        'notification_image': notification_image,
      };
}