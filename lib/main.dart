import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
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
import 'package:uni_links/uni_links.dart';
import 'bloc/auth/auth_bloc.dart';
import 'bloc/suggestion/suggestion_bloc.dart';
import 'package:mobilizer/pages/profile/profile.dart';
import 'bloc/posts/posts_bloc.dart';
import 'injector_container.dart' as di;
import 'pages/push_notification/like_notification_screen.dart';
import 'pages/push_notification/notice_board_screen.dart';
import 'pages/push_notification/post_notification_screen.dart';
import 'common/common/constants.dart';


// Global navigator key for deep linking and navigation
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // setBaseUrlFromEnv();

  // Initialize Firebase for both mobile and web
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

      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        provisional: false,
        sound: true,
      );

      FirebaseMessaging.onBackgroundMessage(backgroundHandler);

      String? deviceToken = await messaging.getToken();
      if (deviceToken != null) {
        await AppSharedPreferences.setValue(
            key: 'deviceToken', value: deviceToken);
        print("Device Token (Mobile): $deviceToken");
      }
    }
  } catch (e) {
    print("Error initializing Firebase: $e");
  }

  // Initialize dependency injection
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  Uri? uri;

  @override
  void initState() {
    super.initState();

    if (!kIsWeb) {
      FirebaseMessaging.instance
          .getInitialMessage()
          .then((RemoteMessage? message) {
        if (message != null) {
          print('Initial message data: ${message.notification?.title}');
        }
      });

      FirebaseMessaging.instance.getToken().then((String? deviceToken) async {
        if (deviceToken != null) {
          await AppSharedPreferences.setValue(
              key: 'deviceToken', value: deviceToken);
          print("Device Token (Mobile): $deviceToken");
        }
      });
    } else {
      print("Running on web: Skipping Firebase Messaging setup.");
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
    uri = await getInitialUri();
    if (state == AppLifecycleState.resumed) {
      _handleInitialUri(navigatorKey, uri);
    }
  }

  // Helper method to set system UI overlay style based on the current theme
  void _setSystemUIOverlayStyle(ThemeProvider themeProvider) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: themeProvider.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
      statusBarIconBrightness:
          themeProvider.isDarkMode ? Brightness.light : Brightness.dark,
      statusBarBrightness:
          themeProvider.isDarkMode ? Brightness.dark : Brightness.light,
      systemNavigationBarColor:
          themeProvider.isDarkMode ? const Color(0xFF121212) : Colors.white,
      systemNavigationBarIconBrightness:
          themeProvider.isDarkMode ? Brightness.light : Brightness.dark,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          // Update system UI overlay style whenever the theme changes
          _setSystemUIOverlayStyle(themeProvider);

          return MaterialApp(
            theme: themeProvider.getTheme(),
            navigatorKey: navigatorKey,
            debugShowCheckedModeBanner: false,
            title: 'Townhall',
            home: const SplashScreen(), // Redirect directly to SplashScreen
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
          AppSharedPreferences.setValue(
              key: 'deepLink', value: link.toString());
        } else {
          print('Invalid URI path');
        }
      }
    } on PlatformException {
      print('Failed to get initial URI');
    } on FormatException catch (err) {
      print('Malformed initial URI');
    }
  }
}

// Utility functions
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