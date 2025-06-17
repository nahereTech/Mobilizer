import 'package:json_annotation/json_annotation.dart';

part 'notifications_response.g.dart';

@JsonSerializable()
class NotificationsResponse {
  NotificationsResponse({
    required this.status,
    required this.msg,
    List<NotificationsData>? data,
  }) : data = data ?? [];

  String status;
  String msg;
  List<NotificationsData>? data;

  factory NotificationsResponse.fromJson(Map<String, dynamic> json) {
    print(json);
    return _$NotificationsResponseFromJson(json);
  }

  Map<String, dynamic> toJson() => _$NotificationsResponseToJson(this);
}

@JsonSerializable()
class NotificationsData {
  NotificationsData({
    required this.id,
    required this.post_id,
    this.notification_txt,
    required this.notification_type,
    this.app_id,
    this.notification_image,
    this.click_leads_to, //is the type of notification. Ex: click leads to "profile"
    this.subjects_id,
    required this.sender_id,
    required this.notifierProfile,
    this.date,
  });

  int id;
  String? notification_txt;
  String notification_type;
  String? notification_image;
  String? click_leads_to;
  String? subjects_id;
  int post_id;
  String? app_id;
  String? date;
  String sender_id;
  String notifierProfile;

  factory NotificationsData.fromJson(Map<String, dynamic> json) {
    print(json);
    return _$NotificationsDataFromJson(json);
  }
  Map<String, dynamic> toJson() => _$NotificationsDataToJson(this);
}
