// import 'dart:async';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:mobilizer/bloc/auth/auth_bloc.dart';
// import 'package:mobilizer/main.dart';
// import 'package:mobilizer/pages/feed/feed.dart';
// import 'package:mobilizer/pages/joinorg/joinorg_page.dart';
// import 'package:mobilizer/pages/message/messages.dart';
// import 'package:mobilizer/pages/push_notification/like_notification_screen.dart';
// import 'package:mobilizer/pages/push_notification/notice_board_screen.dart';
// import 'package:mobilizer/pages/push_notification/post_notification_screen.dart';
// import 'package:mobilizer/pages/services/local_notifications.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:mobilizer/common/common/navigation.dart';
// import 'package:mobilizer/common/common/sharepreference.dart';
// import 'package:mobilizer/pages/home/home.dart';
// import 'package:mobilizer/pages/login/login.dart';
// import 'package:mobilizer/pages/onboarding/onboarding.dart';
// import 'package:mobilizer/pages/post/post_details.dart';
// import 'package:new_version_plus/new_version_plus.dart';
// import 'package:package_info_plus/package_info_plus.dart';
// import 'package:mobilizer/common/common/constants.dart';
// import 'package:uni_links/uni_links.dart';

// // Splash Screen widget to display initial loading screen and handle app initialization
// class SplashScreen extends StatefulWidget {
//   static String routeName = 'splash_screen';
//   const SplashScreen({Key? key}) : super(key: key);

//   @override
//   _SplashScreenState createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   // State variables
//   String notificationMsg = "";
//   bool _canUpdate = false;
//   String _currentVersion = "";
//   String _storeVersion = "";
//   String _storeUrl = "";
//   String _name = "";
//   String _username = "";
//   Uri? uri;
//   Object? _err;
//   StreamSubscription? _sub;

//   @override
//   void initState() {
//     super.initState();
//     // Initialize version check and device token
//     _initVersion();
//     var token = getDeviceToken();

//     // Setup Firebase messaging handlers
//     _setupFirebaseMessaging();

//     // Delayed navigation after 3 seconds to handle routing logic
//     _handleNavigationAfterDelay();
//   }

//   /// Sets up Firebase Messaging for handling notifications
//   void _setupFirebaseMessaging() {
//     // Handle messages when app is in terminated state
//     FirebaseMessaging.instance.getInitialMessage().then((event) {
//       Firebase.initializeApp();
//       if (event != null) {
//         LocalNotificationService.showNotificationOnForeground(event);
//         notificationMsg =
//             "${event.notification!.title} I am coming from terminated state";
//         print(event);
//       }
//     });

//     // Handle background messages
//     FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

//     // Handle messages when app is opened from notification
//     FirebaseMessaging.onMessageOpenedApp.listen((event) {
//       print("Payload ${event.data['notification_type']}");
//       if (event != null) {
//         _handleNotificationNavigation(event);
//       }
//     });
//   }

//   /// Handles navigation based on notification type
//   void _handleNotificationNavigation(RemoteMessage event) {
//     notificationMsg = "${event.notification!.title} I am coming from background";
//     final notificationType = event.data['notification_type'];

//     switch (notificationType) {
//       case "comment":
//       case "post":
//       case "feed":
//         navigatorKey.currentState?.pushNamed(
//           PostNotificationScreen.routeName,
//           arguments: _buildNotificationArguments(event),
//         );
//         break;
//       case "like":
//         navigatorKey.currentState?.pushNamed(
//           LikeNotificationScreen.routeName,
//           arguments: _buildNotificationArguments(event),
//         );
//         break;
//       case "notice_board":
//         navigatorKey.currentState?.pushNamed(
//           NoticeBoardScreen.routeName,
//           arguments: _buildNotificationArguments(event),
//         );
//         break;
//       case "chat":
//         navigatorKey.currentState?.push(
//           MaterialPageRoute(
//             builder: (context) => Messages(
//               mapData: _buildChatArguments(event),
//             ),
//           ),
//         );
//         break;
//     }
//   }

//   /// Builds arguments for notification navigation
//   Map<String, dynamic> _buildNotificationArguments(RemoteMessage event) {
//     return {
//       'item_id': event.data['item_id'],
//       'org_id': event.data['org_id'],
//       'org_name': event.data['org_name'],
//       'townhall_id': event.data['townhall_id'],
//       'n_type': event.data['notification_type'],
//     };
//   }

//   /// Builds arguments for chat navigation
//   Map<String, dynamic> _buildChatArguments(RemoteMessage event) {
//     return {
//       'from': event.data['messageTo'].toString(),
//       'fromPics': '',
//       'fromName': '',
//       'fromUsername': '',
//       'toName': event.data['fromName'],
//       'toUsername': event.data['fromUsername'],
//       'to': event.data['messageFrom'].toString(),
//       'toPics': event.data['fromPics'],
//       'conversationID': event.data['conversationID'],
//       'toDeviceTokens': [],
//     };
//   }

//   /// Handles navigation logic after splash screen delay
//   void _handleNavigationAfterDelay() {
//     Future.delayed(const Duration(seconds: 3), () async {
//       uri = await getInitialUri();
//       var flag = await AppSharedPreferences.getValue(key: "login");
//       var getToken = await AppSharedPreferences.getValue(key: "token");
//       var deepLink = await AppSharedPreferences.getValue(key: 'deepLink');

//       print("Uri ${uri} deepLink ${deepLink}");

//       // Check if user is logged in
//       // if (flag == 'success' && getToken != null && getToken != "") {
//       if (getToken != null && getToken != "") {
//         if (_currentVersion == _storeVersion) {
//           AppSharedPreferences.setValue(
//               key: 'dismissedVersion', value: _storeVersion);
//         }
//         _navigateLoggedInUser();
//       } else {
//         if (_currentVersion == _storeVersion) {
//           AppSharedPreferences.setValue(
//               key: 'dismissedVersion', value: _storeVersion);
//         }
//         _navigateLoggedOutUser(deepLink);
//       }
//     });
//   }

//   /// Navigates for logged-in users
//   void _navigateLoggedInUser() {
//     if (uri.toString() == "null") {
//       Navigation.intentWithClearAllRoutes(context, Feed.routeName);
//     } else {
//       var splitArr = uri!.path.toString().split('/');
//       Navigator.of(context).push(
//         MaterialPageRoute(builder: (context) {
//           return BlocProvider(
//             create: (context) => AuthBloc(),
//             child: JoinOrgScreen(orgName: splitArr[1]),
//           );
//         }),
//       );
//     }
//   }

//   /// Navigates for logged-out users
//   void _navigateLoggedOutUser(String? deepLink) {
//     if (deepLink.toString() == "null") {
//       // Replace the named route navigation with direct navigation
//       Navigator.of(context).pushAndRemoveUntil(
//         MaterialPageRoute(builder: (context) => const OnBoardingPage()),
//         (route) => false,  // This removes all previous routes
//       );
//     } else {
//       var splitArr = uri!.path.toString().split('/');
//       Navigator.of(context).push(
//         MaterialPageRoute(builder: (context) {
//           return BlocProvider(
//             create: (context) => AuthBloc(),
//             child: JoinOrgScreen(orgName: splitArr[1]),
//           );
//         }),
//       );
//     }
//   }

//   @override
//   void dispose() {
//     _sub?.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Set system UI overlay style for status and navigation bars
//     SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
//       statusBarColor: Colors.white,
//       statusBarIconBrightness: Brightness.dark,
//       systemNavigationBarColor: Colors.white,
//       systemNavigationBarIconBrightness: Brightness.dark,
//     ));

//     return Scaffold(
//       body: Stack(children: [
//         Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Container(
//                 height: 60,
//                 width: 60,
//                 alignment: Alignment.center,
//                 child: Image.asset(
//                   'images/icon_blue.png',
//                   fit: BoxFit.contain,
//                 ),
//               ),
//             ],
//           ),
//         ),
//         Align(
//           alignment: FractionalOffset.bottomCenter,
//           child: Padding(
//             padding: const EdgeInsets.only(bottom: 20),
//             child: Text('Townhall'),
//           ),
//         ),
//       ]),
//     );
//   }

//   /// Background handler for Firebase Messaging
//   Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//     LocalNotificationService.showNotificationOnForeground(message);
//     print("onBackgroundMessage: $message");
//   }

//   /// Retrieves device token from shared preferences
//   Future<String?> getDeviceToken() async {
//     return await AppSharedPreferences.getValue(key: 'deviceToken');
//   }

//   /// Sets username from shared preferences
//   Future<void> setUsername() async {
//     final username = await AppSharedPreferences.getValue(key: 'username');
//     setState(() {
//       _username = username.toString() != "null" ? username.toString() : '';
//     });
//   }

//   /// Sets user ID from shared preferences
//   Future<void> setUserID() async {
//     final userID = await AppSharedPreferences.getValue(key: 'user_id');
//   }

//   /// Sets name from shared preferences
//   Future<void> setName() async {
//     final name = await AppSharedPreferences.getValue(key: 'name');
//     setState(() {
//       _name = name.toString() != "null" ? name.toString() : '';
//     });
//   }

//   /// Initializes version information for update checks
//   void _initVersion() async {
//     PackageInfo packageInfo = await PackageInfo.fromPlatform();
//     _canUpdate = false;
//     _currentVersion = packageInfo.version;
//     _storeVersion = packageInfo.version;
//     _storeUrl = packageInfo.installerStore.toString();
//   }
// }