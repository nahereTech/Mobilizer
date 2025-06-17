import 'package:json_annotation/json_annotation.dart';

part 'event_create_response.g.dart';

@JsonSerializable()
class CreateEventResponse {
  CreateEventResponse({
    required this.status,
    required this.msg,
    this.data,
  });

  int status;
  String msg;
  EventData? data;

  factory CreateEventResponse.fromJson(Map<String, dynamic> json) =>
      _$CreateEventResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CreateEventResponseToJson(this);
}

@JsonSerializable()
class EventData {
  EventData({
    required this.event_id,
    required this.title,
    required this.desc,
    required this.event_type,
    required this.event_time_full,
    required this.meeting_point,
    // this.event_files,
  });

  int event_id;
  String title;
  String desc;
  String event_type;
  String event_time_full;
  String meeting_point;
  // List<String>? event_files;

  factory EventData.fromJson(Map<String, dynamic> json) {
    print(json);
    return _$EventDataFromJson(json);
  }

  Map<String, dynamic> toJson() => _$EventDataToJson(this);
}
