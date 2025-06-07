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
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobilizer/pages/home/home.dart';
import 'package:mobilizer/pages/login/login.dart';
import 'package:mobilizer/pages/onboarding/onboarding.dart';
import 'package:mobilizer/pages/post/post_details.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:mobilizer/common/common/constants.dart';
import '../onboarding/set_org.dart';

class SplashScreen extends StatefulWidget {
  static const String routeName = 'splash_screen';
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String? _orgName;
  String? _backgroundImage;
  String? _logoImage;
  String notificationMsg = "";
  bool _canUpdate = false;
  String _currentVersion = "";
  String _storeVersion = "";
  String _storeUrl = "";
  String _name = "";
  String _username = "";
  Uri? uri;
  Object? _err;
  StreamSubscription? _sub;
  int _tapCount = 0;
  bool _hasNavigated = false;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    print('SplashScreen initState: Initial _backgroundImage: $_backgroundImage');

    _initVersion();
    getDeviceToken();
    // _setupFirebaseMessaging(); // Temporarily disabled for debugging
    _loadPreferencesWithRetry().then((_) {
      _startNavigationTimer(); // Start navigation after preferences are loaded
    });
  }

  Future<void> _loadPreferencesWithRetry({int retries = 5, int delayMs = 500}) async {
    for (int attempt = 0; attempt < retries; attempt++) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final currentOrgRaw = prefs.getString('current_org');
        final orgName = prefs.getString('org_name');
        final backgroundImage = prefs.getString('presentation_org_bg');
        final logoImage = prefs.getString('presentation_org_logo');

        print('SplashScreen _loadPreferencesWithRetry [Attempt ${attempt + 1}]:');
        print('  current_org: $currentOrgRaw');
        print('  org_name: $orgName');
        print('  presentation_org_bg: $backgroundImage');
        print('  presentation_org_logo: $logoImage');

        if (backgroundImage != null && orgName != null && logoImage != null) {
          setState(() {
            _orgName = orgName;
            _backgroundImage = backgroundImage;
            _logoImage = logoImage;
          });
          print('SplashScreen _loadPreferencesWithRetry: Values set in state:');
          print('  _orgName: $_orgName');
          print('  _backgroundImage: $_backgroundImage');
          print('  _logoImage: $_logoImage');
          return;
        }

        print('SplashScreen _loadPreferencesWithRetry: Values not ready, retrying...');
        await Future.delayed(Duration(milliseconds: delayMs));
      } catch (e) {
        print('SplashScreen _loadPreferencesWithRetry: Error on attempt ${attempt + 1}: $e');
      }
    }

    // Fallback if retries fail
    print('SplashScreen _loadPreferencesWithRetry: Max retries reached, using fallbacks');
    setState(() {
      _orgName = 'Mobilizer';
      _backgroundImage = 'images/mobilizer_bg.jpg';
      _logoImage = 'images/mobilizer_logo.jpg';
    });
    print('SplashScreen _loadPreferencesWithRetry: Fallback values set:');
    print('  _orgName: $_orgName');
    print('  _backgroundImage: $_backgroundImage');
    print('  _logoImage: $_logoImage');
  }

  void _startNavigationTimer() {
    _navigationTimer?.cancel();
    _navigationTimer = Timer(const Duration(seconds: 5), () async {
      if (_hasNavigated) return;

      var getToken = await AppSharedPreferences.getValue(key: "token");
      print('SplashScreen _startNavigationTimer: Token: $getToken');

      if (getToken != null && getToken != "") {
        print('SplashScreen _startNavigationTimer: Navigating to FeedOutsidePage');
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const FeedOutsidePage()),
          (route) => false,
        );
      } else {
        print('SplashScreen _startNavigationTimer: Navigating to OnBoardingPage');
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const OnBoardingPage()),
          (route) => false,
        );
      }
      _hasNavigated = true;
    });
  }

  void _setupFirebaseMessaging() {
    FirebaseMessaging.instance.getInitialMessage().then((event) async {
      try {
        await Firebase.initializeApp();
        if (event != null) {
          LocalNotificationService.showNotificationOnForeground(event);
          notificationMsg = "${event.notification?.title} I am coming from terminated state";
          print('SplashScreen _setupFirebaseMessaging: $notificationMsg');
        }
      } catch (e) {
        print('SplashScreen _setupFirebaseMessaging: Error initializing Firebase: $e');
      }
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      print("SplashScreen _setupFirebaseMessaging: Payload ${event.data['notification_type']}");
      if (event != null) {
        _handleNotificationNavigation(event);
      }
    });
  }

  void _handleNotificationNavigation(RemoteMessage event) {
    notificationMsg = "${event.notification?.title} I am coming from background";
    final notificationType = event.data['notification_type'];
    print('SplashScreen _handleNotificationNavigation: Type: $notificationType');

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

  Map<String, dynamic> _buildNotificationArguments(RemoteMessage event) {
    return {
      'item_id': event.data['item_id'],
      'org_id': event.data['org_id'],
      'org_name': event.data['org_name'],
      'townhall_id': event.data['townhall_id'],
      'n_type': event.data['notification_type'],
    };
  }

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

  void _handleLogoTap() {
    setState(() {
      _tapCount++;
      print('SplashScreen _handleLogoTap: Tap count: $_tapCount');
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
    try {
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ));
    } catch (e) {
      print('SplashScreen: Error setting System UI Overlay: $e');
    }

    print('SplashScreen build: _backgroundImage before rendering: $_backgroundImage');

    if (_backgroundImage == null) {
      print('SplashScreen build: Showing loading indicator (_backgroundImage is null)');
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Builder(
      builder: (BuildContext context) {
        try {
          return Scaffold(
            body: DecoratedBox(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: _backgroundImage!.startsWith('http')
                      ? NetworkImage(_backgroundImage!)
                      : AssetImage(_backgroundImage!) as ImageProvider,
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.5),
                    BlendMode.darken,
                  ),
                  onError: (exception, stackTrace) {
                    print('SplashScreen: Image loading error: $exception');
                    print(stackTrace);
                    setState(() {
                      _backgroundImage = 'images/mobilizer_bg.jpg';
                    });
                  },
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
                            backgroundImage: _logoImage?.startsWith('http') ?? false
                                ? NetworkImage(_logoImage!)
                                : AssetImage(_logoImage ?? 'images/mobilizer_logo.jpg') as ImageProvider,
                            onBackgroundImageError: (exception, stackTrace) {
                              print('SplashScreen: Logo image loading error: $exception');
                              print(stackTrace);
                              setState(() {
                                _logoImage = 'images/mobilizer_logo.jpg';
                              });
                            },
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
                        _orgName ?? 'Mobilizer',
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
        } catch (e, stackTrace) {
          print('SplashScreen: Render error: $e');
          print(stackTrace);
          return const Scaffold(
            body: Center(child: Text('Error rendering splash screen')),
          );
        }
      },
    );
  }

  Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    LocalNotificationService.showNotificationOnForeground(message);
    print("SplashScreen _firebaseMessagingBackgroundHandler: $message");
  }

  Future<String?> getDeviceToken() async {
    final token = await AppSharedPreferences.getValue(key: 'deviceToken');
    print('SplashScreen getDeviceToken: Token: $token');
    return token;
  }

  Future<void> setUsername() async {
    final username = await AppSharedPreferences.getValue(key: 'username');
    setState(() {
      _username = username.toString() != "null" ? username.toString() : '';
      print('SplashScreen setUsername: Username: $_username');
    });
  }

  Future<void> setUserID() async {
    final userID = await AppSharedPreferences.getValue(key: 'user_id');
    print('SplashScreen setUserID: User ID: $userID');
  }

  Future<void> setName() async {
    final name = await AppSharedPreferences.getValue(key: 'name');
    setState(() {
      _name = name.toString() != "null" ? name.toString() : '';
      print('SplashScreen setName: Name: $_name');
    });
  }

  void _initVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    _canUpdate = false;
    _currentVersion = packageInfo.version;
    _storeVersion = packageInfo.version;
    _storeUrl = packageInfo.installerStore?.toString() ?? '';
    print('SplashScreen _initVersion: Current version: $_currentVersion');
  }
}