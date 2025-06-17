import 'package:json_annotation/json_annotation.dart';

part 'bulb_notifications_response.g.dart';

@JsonSerializable()
class BulbNotificationsResponse {
  BulbNotificationsResponse({
    required this.status,
    required this.msg,
    required this.data,
  });

  int status;
  String msg;
  Data? data;

  factory BulbNotificationsResponse.fromJson(Map<String, dynamic> json) {
    print(json);
    return _$BulbNotificationsResponseFromJson(json);
  }

  Map<String, dynamic> toJson() => _$BulbNotificationsResponseToJson(this);
}

@JsonSerializable()
class Data {
  Data({this.messages, this.notifications, this.events});

  int? messages;
  int? notifications;
  int? events;

  factory Data.fromJson(Map<String, dynamic> json) => _$DataFromJson(json);

  Map<String, dynamic> toJson() => _$DataToJson(this);
}
