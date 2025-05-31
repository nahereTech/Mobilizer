// 1. Flutter and SharedPreferences import
import 'package:flutter/material.dart';
import 'package:mobilizer/common/common/sharepreference.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 2. Color constants import
import 'colors.dart';

// 3. Error message constants
const String socketException = 'Please check your internet connection';
const String formatException =
    'Sorry there was an error processing the request. Please try again later.';
const String timeoutException =
    'It seems the request took longer than expected to process. Please try again later.';
const String unknown = "Sorry, something went wrong. Please try again later.";

// 4. Domain (used for other things, not base_url)
// const String domainName = "https://townhall.empl-dev.com.ng"; // Development server
// const String domainName = "https://empl-staging.com"; // Staging server
const String domainName = "https://townhall.mobi"; // Live server

// 5. App identifiers
const String IOSPackageID = 'com.ugo.nahere';
const String androidPackageID = 'com.naheretownhall.nahere';

// 6. Button styles
final ButtonStyle raisedButtonStyleGreen = ElevatedButton.styleFrom(
  backgroundColor: Color(0xFF00AFEF),
  minimumSize: Size(88, 50),
  padding: EdgeInsets.symmetric(horizontal: 16),
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(50)),
  ),
);

final ButtonStyle raisedButtonStyleYellow = ElevatedButton.styleFrom(
  backgroundColor: yellow,
  minimumSize: Size(88, 50),
  padding: EdgeInsets.symmetric(horizontal: 16),
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(20)),
  ),
);

final ButtonStyle raisedButtonStyleBlue = ElevatedButton.styleFrom(
  backgroundColor: blue,
  minimumSize: Size(88, 50),
  padding: EdgeInsets.symmetric(horizontal: 16),
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(20)),
  ),
);

final ButtonStyle raisedButtonStyle = ElevatedButton.styleFrom(
  backgroundColor: Color(0xFF00AFEF),
  minimumSize: Size(500, 45),
  padding: EdgeInsets.symmetric(horizontal: 16),
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.all(
      Radius.circular(10),
    ),
  ),
);

// 7. Border style
final OutlineInputBorder border = OutlineInputBorder(
  borderRadius: BorderRadius.circular(15.0),
  borderSide: const BorderSide(color: Colors.white, width: 0.0),
);

// 8. Chat UI constants
final kMessageContainerDecoration = BoxDecoration(
  border: Border.all(color: Colors.blue, width: 2.0),
  color: Colors.white,
);

const kMessageTextFieldDecoration = InputDecoration(
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  hintText: 'Type your message here...',
  border: InputBorder.none,
);

const kSendButtonTextStyle = TextStyle(
  color: Colors.blue,
  fontWeight: FontWeight.bold,
  fontSize: 18.0,
);

// 9. Clears all cached values except deviceToken
void clearCache() async {
  var deviceToken = await getDeviceToken();

  await AppSharedPreferences.clearCache();

  await AppSharedPreferences.setValue(
    key: 'deviceToken',
    value: deviceToken.toString(),
  );

  print("Clear cache was called");
}

// 10. (Optional) Get dismissed version
Future<String?> _getDismissedVersion() async {
  return await AppSharedPreferences.getValue(key: 'dismissedVersion');
}

// 11. Fetch device token from shared preferences
Future<String?> getDeviceToken() async {
  return await AppSharedPreferences.getValue(key: 'deviceToken');
}

// 12. Runtime modifiable base URL (can't be const)
// String base_url = "https://townhall.empl-dev.com.ng/api/"; // default to live
String base_url = "https://townhall.mobi/api/"; // default to live

// 13. Dynamically set base_url based on 'server_env' key
Future<void> setBaseUrlFromEnv() async {
  final prefs = await SharedPreferences.getInstance();
  String? env = prefs.getString('server_env');

  if (env == 'dev') {
    base_url = "https://townhall.empl-dev.com.ng/api/";
  } else {
    base_url = "https://townhall.mobi/api/";
  }

  // print("Base URL set to: $base_url");
}
