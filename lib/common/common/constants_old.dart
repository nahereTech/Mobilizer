import 'package:flutter/material.dart';
import 'package:mobilizer/common/common/sharepreference.dart';

import 'colors.dart';

const String socketException = 'Please check your internet connection';
const String formatException =
    'Sorry there was an error processing the request. Please try again later.';
const String timeoutException =
    'It seems the request took longer than expected to process. Please try again later.';
const String unknown = "Sorry, something went wrong. Please try again later.";
//const String domainName = '62.151.180.28';
const String domainName =
    "https://townhall.empl-dev.com.ng"; //Development server
//const String domainName = "https://empl-staging.com"; //Staging server
//const String domainName = "https://townhall.mobi"; //Live server
//const String domainName = "62.151.180.28";
const String IOSPackageID = 'com.ugo.nahere';
const String androidPackageID = 'com.naheretownhall.nahere';
final ButtonStyle raisedButtonStyleGreen = ElevatedButton.styleFrom(
  // onPrimary: Colors.white,
  // primary: Color(0xFF116685),
  backgroundColor: Color(0xFF00AFEF),
  minimumSize: Size(88, 50),
  padding: EdgeInsets.symmetric(horizontal: 16),
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(50)),
  ),
);
final ButtonStyle raisedButtonStyleYellow = ElevatedButton.styleFrom(
  // onPrimary: Colors.black87,
  // primary: yellow,
  backgroundColor: yellow,
  minimumSize: Size(88, 50),
  padding: EdgeInsets.symmetric(horizontal: 16),
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(20)),
  ),
);

final ButtonStyle raisedButtonStyleBlue = ElevatedButton.styleFrom(
  // onPrimary: Colors.white,
  // primary: blue,
  backgroundColor: blue,
  minimumSize: Size(88, 50),
  padding: EdgeInsets.symmetric(horizontal: 16),
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(20)),
  ),
);

final ButtonStyle raisedButtonStyle = ElevatedButton.styleFrom(
  // onPrimary: Colors.white,
  // primary: Colors.blue,
  backgroundColor: Color(0xFF00AFEF),
  minimumSize: Size(500, 45),
  padding: EdgeInsets.symmetric(horizontal: 16),
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.all(
      Radius.circular(10),
    ),
  ),
);

final OutlineInputBorder border = OutlineInputBorder(
// width: 0.0 produces a thin "hairline" border
  borderRadius: BorderRadius.circular(15.0),
  borderSide: const BorderSide(color: Colors.white, width: 0.0),
);

final kMessageContainerDecoration = BoxDecoration(
    border: Border.all(color: Colors.blue, width: 2.0), color: Colors.white);

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
void clearCache() async {
  // await AppSharedPreferences.removeValue(key: 'token');
  // await AppSharedPreferences.removeValue(key: 'townhallView');
  // await AppSharedPreferences.removeValue(key: 'groupID');
  // await AppSharedPreferences.removeValue(key: 'orgID');
  // await AppSharedPreferences.removeValue(key: 'orgName');
  // await AppSharedPreferences.removeValue(key: 'isLeader');
  // await AppSharedPreferences.removeValue(key: 'login');
  // await AppSharedPreferences.removeValue(key: 'page_message');
  // await AppSharedPreferences.removeValue(key: 'page_notification');
  // await AppSharedPreferences.removeValue(key: 'page_chat');
  // await AppSharedPreferences.removeValue(key: 'page_event');
  // await AppSharedPreferences.removeValue(key: 'page_organization');
  // await AppSharedPreferences.removeValue(key: 'page_search_people');
  // await AppSharedPreferences.removeValue(key: 'page_search_organization');

  // var dismissedVersion = await _getDismissedVersion();
  var deviceToken = await getDeviceToken();

  await AppSharedPreferences.clearCache();
  // AppSharedPreferences.setValue(
  //     key: 'dismissedVersion', value: dismissedVersion.toString());
  await AppSharedPreferences.setValue(
      key: 'deviceToken', value: deviceToken.toString());
  print("Clear cache was called");
}

Future<String?> _getDismissedVersion() async {
  return await AppSharedPreferences.getValue(key: 'dismissedVersion');
}

Future<String?> getDeviceToken() async {
  return await AppSharedPreferences.getValue(key: 'deviceToken');
}

const String base_url = "https://townhall.empl-dev.com.ng/api/"; //Development server
// const String base_url = "https://townhall.mobi/api/"; //Development server
