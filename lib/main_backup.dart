import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:app_links/app_links.dart';
import 'package:mobilizer/bloc/events/events_bloc.dart';
import 'package:mobilizer/bloc/messages/messages_bloc.dart';
import 'package:mobilizer/bloc/search/organization_bloc.dart';
import 'package:mobilizer/bloc/search/people_bloc.dart';
import 'package:mobilizer/common/common/sharepreference.dart';
import 'package:mobilizer/common/common/theme_provider.dart';
import 'package:mobilizer/pages/comments/comments.dart';
import 'package:mobilizer/pages/events/create_event.dart';
import 'package:mobilizer/pages/events/events.dart';
import 'package:mobilizer/pages/feed/feed.dart';
import 'package:mobilizer/pages/feed/feed_outside.dart';
import 'package:mobilizer/pages/feed/show_video_screen.dart';
import 'package:mobilizer/pages/forgot_password/forgotpassword.dart';
import 'package:mobilizer/pages/forgot_password_otp/forgotpasswordotp.dart';
import 'package:mobilizer/pages/home/home.dart';
import 'package:mobilizer/pages/joinorg/joinorg_page.dart';
import 'package:mobilizer/pages/login/login.dart';
import 'package:mobilizer/pages/message/messages.dart';
import 'package:mobilizer/pages/onboarding/onboarding.dart';
import 'package:mobilizer/pages/organization/add_organizations.dart';
import 'package:mobilizer/pages/organization/organization.dart';
import 'package:mobilizer/pages/organization/organization_details.dart';
import 'package:mobilizer/pages/organization/organization_edit.dart';
import 'package:mobilizer/pages/people/people_profile.dart';
import 'package:mobilizer/pages/polls/create_polls.dart';
import 'package:mobilizer/pages/post/createpost.dart';
import 'package:mobilizer/pages/register/register.dart';
import 'package:mobilizer/pages/register_otp/registerotp.dart';
import 'package:mobilizer/pages/result/result.dart';
import 'package:mobilizer/pages/result/result_type.dart';
import 'package:mobilizer/pages/search/search.dart';
import 'package:mobilizer/pages/search/search_people.dart';
import 'package:mobilizer/pages/set_password/setpassword.dart';
import 'package:mobilizer/pages/splash/splash_screen.dart';
import 'package:mobilizer/pages/suggestion/org_suggestion.dart';
import 'package:mobilizer/pages/suggestion/suggestion.dart';
import 'bloc/auth/auth_bloc.dart';
import 'bloc/suggestion/suggestion_bloc.dart';
import 'package:mobilizer/pages/profile/profile.dart';
import 'bloc/posts/posts_bloc.dart';
import 'injector_container.dart' as di;
import 'pages/push_notification/like_notification_screen.dart';
import 'pages/push_notification/notice_board_screen.dart';
import 'pages/push_notification/post_notification_screen.dart';
import 'common/common/constants.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "your-api-key",
          appId: "your-app-id",
          messagingSenderId: "your-messaging-sender-id",
          projectId: "your-project-id",
        ),
      );
      print("Firebase initialized for web");
    } else {
      await Firebase.initializeApp();
      print("Firebase initialized for mobile");

      final FirebaseMessaging messaging = FirebaseMessaging.instance;
      await messaging.requestPermission(
        alert: true,
        badge: true,
        provisional: false,
        sound: true,
      );
      FirebaseMessaging.onBackgroundMessage(backgroundHandler);

      String? deviceToken = await messaging.getToken();
      if (deviceToken != null) {
        await AppSharedPreferences.setValue(key: 'deviceToken', value: deviceToken);
        print("Device Token (Mobile): $deviceToken");
      }
    }
  } catch (e) {
    print("Error initializing Firebase: $e");
  }

  // Initialize dependency injection
  await di.init();

  // Preload SharedPreferences values
  final prefs = await SharedPreferences.getInstance();
  await _checkCurrentOrg(prefs);

  runApp(const MyApp());
}

Future<void> _checkCurrentOrg(SharedPreferences prefs) async {
  final String? currentOrgRaw = prefs.getString('current_org');
  int? currentOrg = currentOrgRaw != null ? int.tryParse(currentOrgRaw) : null;
  print('main.dart _checkCurrentOrg: current_org: $currentOrgRaw');

  if (currentOrg == null || currentOrg == 0) {
    print('main.dart _checkCurrentOrg: current_org is blank or 0');
    final org = {
      'id': "1",
      'logo': 'https://imagedelivery.net/BgK_7WpdFl6ls9CBX3q89Q/8a8f1415-d6fe-44cc-5ce7-d34e25d13400/public',
      'bg': 'https://imagedelivery.net/BgK_7WpdFl6ls9CBX3q89Q/69ab5c95-f314-4caa-d279-bf8d840b0d00/public',
      'name': 'APC',
      'slide_1': 'https://imagedelivery.net/BgK_7WpdFl6ls9CBX3q89Q/f8af98a6-1b15-4533-406b-c32edd1d0900/public',
      'slide_2': 'https://imagedelivery.net/BgK_7WpdFl6ls9CBX3q89Q/8f419346-218f-4233-3e54-650b65169000/public',
      'slide_3': 'https://imagedelivery.net/BgK_7WpdFl6ls9CBX3q89Q/401f9959-95fd-4add-3c1b-7e70e29a7d00/public',
      'slide_1_title': 'Join Local APC Campaign Groups',
      'slide_2_title': 'Raise Funds Locally for APC',
      'slide_3_title': 'Raise Funds Locally for APC',
      'slide_1_desc': 'Hello AP',
      'slide_2_desc': 'Yello APC',
      'slide_3_desc': 'Akanana APC',
    };

    await prefs.setString('current_org', org['id']!);
    await prefs.setString('presentation_org_logo', org['logo']!);
    await prefs.setString('presentation_org_bg', org['bg']!);
    await prefs.setString('org_name', org['name']!);
    await prefs.setString('presentation_org_slide_1', org['slide_1']!);
    await prefs.setString('presentation_org_slide_2', org['slide_2']!);
    await prefs.setString('presentation_org_slide_3', org['slide_3']!);
    await prefs.setString('presentation_org_slide_1_title', org['slide_1_title']!);
    await prefs.setString('presentation_org_slide_2_title', org['slide_2_title']!);
    await prefs.setString('presentation_org_slide_3_title', org['slide_3_title']!);
    await prefs.setString('presentation_org_slide_1_desc', org['slide_1_desc']!);
    await prefs.setString('presentation_org_slide_2_desc', org['slide_2_desc']!);
    await prefs.setString('presentation_org_slide_3_desc', org['slide_3_desc']!);

    print('main.dart _checkCurrentOrg: Random organization data saved to SharedPreferences');
    print('main.dart _checkCurrentOrg: SharedPreferences values:');
    print('  current_org: ${prefs.getString('current_org')}');
    print('  org_name: ${prefs.getString('org_name')}');
    print('  presentation_org_bg: ${prefs.getString('presentation_org_bg')}');
    print('  presentation_org_logo: ${prefs.getString('presentation_org_logo')}');
  } else {
    print('main.dart _checkCurrentOrg: current_org is $currentOrg');
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final AppLinks _appLinks = AppLinks();
  Uri? _initialUri;

  @override
  void initState() {
    super.initState();

    if (!kIsWeb) {
      FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? event) {
        if (event != null) {
          print('Initial event data: ${event.notification?.title}');
        }
      });

      FirebaseMessaging.instance.getToken().then((String? deviceToken) async {
        if (deviceToken != null) {
          await AppSharedPreferences.setValue(key: 'deviceToken', value: deviceToken);
          print("Device Token (Mobile): $deviceToken");
        }
      });

      // Handle initial deep link
      _handleInitialLink();

      // Listen for incoming deep links
      _appLinks.uriLinkStream.listen((Uri? uri) {
        if (uri != null) {
          print('Received URI: $uri');
          _handleInitialUri(navigatorKey, uri);
        }
      }, onError: (err) {
        print('Error receiving URI: $err');
      });
    } else {
      print("Running on web: Skipping Firebase Messaging and deep link setup.");
    }

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed && !kIsWeb) {
      // Re-check initial link when app resumes
      _handleInitialLink();
    }
  }

  Future<void> _handleInitialLink() async {
    try {
      final uri = await _appLinks.getInitialLink();
      if (uri != null) {
        setState(() {
          _initialUri = uri;
        });
        _handleInitialUri(navigatorKey, uri);
      } else {
        print('No initial URI');
      }
    } catch (e) {
      print('Error getting initial URI: $e');
    }
  }

  void _setSystemUIOverlayStyle(ThemeProvider themeProvider) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: themeProvider.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
      statusBarIconBrightness: themeProvider.isDarkMode ? Brightness.light : Brightness.dark,
      statusBarBrightness: themeProvider.isDarkMode ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: themeProvider.isDarkMode ? const Color(0xFF121212) : Colors.white,
      systemNavigationBarIconBrightness: themeProvider.isDarkMode ? Brightness.light : Brightness.dark,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          _setSystemUIOverlayStyle(themeProvider);
          return MaterialApp(
            theme: themeProvider.getTheme(),
            navigatorKey: navigatorKey,
            debugShowCheckedModeBanner: false,
            title: 'Townhall',
            home: const SplashScreen(),
          );
        },
      ),
    );
  }

  Future<void> _handleInitialUri(GlobalKey<NavigatorState> key, Uri? link) async {
    try {
      if (link == null) {
        print('No initial URI');
      } else {
        print('Got initial URI: $link');
        print('Got initial URI path: ${link.path}');

        var splitArr = link.path.toString().split('/');
        if (splitArr.length > 1 && splitArr[1].isNotEmpty) {
          Navigator.of(key.currentContext!).push(
            MaterialPageRoute(
              builder: (context) => BlocProvider(
                create: (context) => AuthBloc(),
                child: JoinOrgScreen(orgName: splitArr[1]),
              ),
            ),
          );
          await AppSharedPreferences.setValue(key: 'deepLink', value: link.toString());
        } else {
          print('Invalid URI path');
        }
      }
    } catch (e) {
      print('Error handling URI: $e');
    }
  }
}

Future<String?> getDeviceToken() async {
  return await AppSharedPreferences.getValue(key: 'deviceToken');
}

Future<String?> getUserID() async {
  return await AppSharedPreferences.getValue(key: 'user_id');
}

Future<String?> getMessageCounts() async {
  return await AppSharedPreferences.getValue(key: 'message_counts');
}

Future<void> backgroundHandler(RemoteMessage message) async {
  print("This is the message from background");
  print(message.notification?.title);
  print(message.notification?.body);
  print(message.data);
  print(message.data['ref_id']);
}