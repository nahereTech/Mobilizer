import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobilizer/bloc/auth/auth_bloc.dart';
import 'package:mobilizer/main.dart';
import 'package:mobilizer/pages/feed/feed_outside.dart';
import 'package:mobilizer/pages/joinorg/joinorg_page.dart';
import 'package:mobilizer/pages/message/messages.dart';
import 'package:mobilizer/pages/push_notification/like_notification_screen.dart';
import 'package:mobilizer/pages/push_notification/notice_board_screen.dart';
import 'package:mobilizer/pages/push_notification/post_notification_screen.dart';
import 'package:mobilizer/pages/services/local_notifications.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobilizer/common/common/navigation.dart';
import 'package:mobilizer/common/common/sharepreference.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Added import
import 'package:mobilizer/pages/home/home.dart';
import 'package:mobilizer/pages/login/login.dart';
import 'package:mobilizer/pages/onboarding/onboarding.dart';
import 'package:mobilizer/pages/post/post_details.dart';
import 'package:new_version_plus/new_version_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:mobilizer/common/common/constants.dart';
import 'package:uni_links/uni_links.dart';
import '../onboarding/set_org.dart'; // Import SetOrgPage

class SplashScreen extends StatefulWidget {
  static String routeName = 'splash_screen';
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // State variables
  String notificationMsg = "";
  bool _canUpdate = false;
  String _currentVersion = "";
  String _storeVersion = "";
  String _storeUrl = "";
  String _name = "";
  String _username = "";
  String _orgName = "Mobilizer"; // Default to 'Mobilizer'
  String _backgroundImage = "images/mobilizer_bg.jpg"; // Default to asset image
  String _logoImage = "images/mobilizer_logo.jpg"; // Default to asset logo
  Uri? uri;
  Object? _err;
  StreamSubscription? _sub;
  int _tapCount = 0; // Tap counter
  bool _hasNavigated = false; // Flag to prevent multiple navigations
  Timer? _navigationTimer; // Timer for delayed navigation

  @override
  void initState() {
    super.initState();
    // Initialize version check and device token
    _initVersion();
    var token = getDeviceToken();

    // Setup Firebase messaging handlers
    _setupFirebaseMessaging();

    // Fetch org_name, presentation_org_bg, and presentation_org_logo
    _setOrgName();
    _setBackgroundImage();
    _setLogoImage();

    // Start delayed navigation
    _startNavigationTimer();
  }

  /// Starts or restarts the navigation timer
  void _startNavigationTimer() {
    _navigationTimer?.cancel();
    _navigationTimer = Timer(const Duration(seconds: 5), () async {
      if (_hasNavigated) return;

      var getToken = await AppSharedPreferences.getValue(key: "token");

      if (getToken != null && getToken != "") {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const FeedOutsidePage()),
          (route) => false,
        );
      } else {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const OnBoardingPage()),
          (route) => false,
        );
      }
    });
  }

  /// Fetches and sets the organization name from shared preferences
  Future<void> _setOrgName() async {
    final prefs = await SharedPreferences.getInstance();
    final orgName = prefs.getString('org_name'); // Retrieve org_name
    setState(() {
      _orgName = (orgName != null && orgName.isNotEmpty) ? orgName : 'Mobilizer';
    });
  }

  /// Fetches and sets the background image from shared preferences
  Future<void> _setBackgroundImage() async {
    final prefs = await SharedPreferences.getInstance();
    final presentationOrgBg = prefs.getString('presentation_org_bg');
    setState(() {
      _backgroundImage = (presentationOrgBg != null && presentationOrgBg.isNotEmpty)
          ? presentationOrgBg
          : 'images/mobilizer_bg.jpg';
    });
  }

  /// Fetches and sets the logo image from shared preferences
  Future<void> _setLogoImage() async {
    final prefs = await SharedPreferences.getInstance();
    final presentationOrgLogo = prefs.getString('presentation_org_logo');
    setState(() {
      _logoImage = (presentationOrgLogo != null && presentationOrgLogo.isNotEmpty)
          ? presentationOrgLogo
          : 'images/mobilizer_logo.jpg';
    });
  }

  /// Sets up Firebase Messaging for handling notifications
  void _setupFirebaseMessaging() {
    FirebaseMessaging.instance.getInitialMessage().then((event) {
      Firebase.initializeApp();
      if (event != null) {
        LocalNotificationService.showNotificationOnForeground(event);
        notificationMsg =
            "${event.notification!.title} I am coming from terminated state";
        print(event);
      }
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      print("Payload ${event.data['notification_type']}");
      if (event != null) {
        _handleNotificationNavigation(event);
      }
    });
  }

  /// Handles navigation based on notification type
  void _handleNotificationNavigation(RemoteMessage event) {
    notificationMsg = "${event.notification!.title} I am coming from background";
    final notificationType = event.data['notification_type'];

    switch (notificationType) {
      case "comment":
      case "post":
      case "feed":
        navigatorKey.currentState?.pushNamed(
          PostNotificationScreen.routeName,
          arguments: _buildNotificationArguments(event),
        );
        break;
      case "like":
        navigatorKey.currentState?.pushNamed(
          LikeNotificationScreen.routeName,
          arguments: _buildNotificationArguments(event),
        );
        break;
      case "notice_board":
        navigatorKey.currentState?.pushNamed(
          NoticeBoardScreen.routeName,
          arguments: _buildNotificationArguments(event),
        );
        break;
      case "chat":
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (context) => Messages(
              mapData: _buildChatArguments(event),
            ),
          ),
        );
        break;
    }
  }

  /// Builds arguments for notification navigation
  Map<String, dynamic> _buildNotificationArguments(RemoteMessage event) {
    return {
      'item_id': event.data['item_id'],
      'org_id': event.data['org_id'],
      'org_name': event.data['org_name'],
      'townhall_id': event.data['townhall_id'],
      'n_type': event.data['notification_type'],
    };
  }

  /// Builds arguments for chat navigation
  Map<String, dynamic> _buildChatArguments(RemoteMessage event) {
    return {
      'from': event.data['messageTo'].toString(),
      'fromPics': '',
      'fromName': '',
      'fromUsername': '',
      'toName': event.data['fromName'],
      'toUsername': event.data['fromUsername'],
      'to': event.data['messageFrom'].toString(),
      'toPics': event.data['fromPics'],
      'conversationID': event.data['conversationID'],
      'toDeviceTokens': [],
    };
  }

  /// Handles logo tap to navigate to SetOrgPage after 4 taps
  void _handleLogoTap() {
    setState(() {
      _tapCount++;
      if (_tapCount >= 4 && !_hasNavigated) {
        _hasNavigated = true;
        _navigationTimer?.cancel();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SetOrgPage()),
        );
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _navigationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: _backgroundImage.startsWith('http')
                ? NetworkImage(_backgroundImage)
                : AssetImage(_backgroundImage) as ImageProvider,
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.5),
              BlendMode.darken,
            ),
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _handleLogoTap,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: _logoImage.startsWith('http')
                          ? NetworkImage(_logoImage)
                          : AssetImage(_logoImage) as ImageProvider,
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: FractionalOffset.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(
                  _orgName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        blurRadius: 2.0,
                        color: Colors.black54,
                        offset: Offset(1.0, 1.0),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Background handler for Firebase Messaging
  Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    LocalNotificationService.showNotificationOnForeground(message);
    print("onBackgroundMessage: $message");
  }

  /// Retrieves device token from shared preferences
  Future<String?> getDeviceToken() async {
    return await AppSharedPreferences.getValue(key: 'deviceToken');
  }

  /// Sets username from shared preferences
  Future<void> setUsername() async {
    final username = await AppSharedPreferences.getValue(key: 'username');
    setState(() {
      _username = username.toString() != "null" ? username.toString() : '';
    });
  }

  /// Sets user ID from shared preferences
  Future<void> setUserID() async {
    final userID = await AppSharedPreferences.getValue(key: 'user_id');
  }

  /// Sets name from shared preferences
  Future<void> setName() async {
    final name = await AppSharedPreferences.getValue(key: 'name');
    setState(() {
      _name = name.toString() != "null" ? name.toString() : '';
    });
  }

  /// Initializes version information for update checks
  void _initVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    _canUpdate = false;
    _currentVersion = packageInfo.version;
    _storeVersion = packageInfo.version;
    _storeUrl = packageInfo.installerStore.toString();
  }
}