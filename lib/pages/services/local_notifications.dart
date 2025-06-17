import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:overlay_support/overlay_support.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  // static final IOSInitializationSettings initializationSettingsIOS =
  //   IOSInitializationSettings(
  //       onDidReceiveLocalNotification: onDidReceiveLocalNotification);

  // static void initilize() {
  //   final InitializationSettings initializationSettings =
  //       InitializationSettings(
  //           android: AndroidInitializationSettings("@mipmap/ic_launcher"),
  //           iOS: IOSInitializationSettings());

  //   _notificationsPlugin.initialize(initializationSettings,
  //       onSelectNotification: (String? payload) {
  //     //print(payload);
  //   });
  // }
  static void initialize() {
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: AndroidInitializationSettings("@mipmap/ic_launcher"),
      iOS: DarwinInitializationSettings(), // Updated for iOS
    );

    _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification selection
        if (response.payload != null) {
          print("Notification payload: ${response.payload}");
          // Add your navigation or action logic here
        }
      },
    );
  }

  static void showNotificationOnForeground(RemoteMessage message) {
    // NotificationDetails for Android
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      "com.naheretownhall.nahere", // Channel ID
      "firebase_push_notification", // Channel Name
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );
    //NotificationDetails for iOS (updated to DarwinNotificationDetails)
    const DarwinNotificationDetails darwinNotificationDetails =
        DarwinNotificationDetails(presentSound: true);

    final notificationDetail = NotificationDetails(
      android: androidNotificationDetails,
      iOS: darwinNotificationDetails, // Updated class
    );

    // Example with flutter_local_notifications
    _notificationsPlugin.show(
      DateTime.now().microsecond, // Unique ID for notification
      message.notification!.title, // Notification title
      message.notification!.body, // Notification body
      notificationDetail, // Notification details
      payload: message.data["message"], // Additional data payload
    );

    // Example with overlay_support (optional)
    showSimpleNotification(
      Text("${message.notification!.title}"),
      subtitle: Text("${message.notification!.body}"),
    );
  }
}
