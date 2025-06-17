import 'package:json_annotation/json_annotation.dart';
part 'events_response.g.dart';

@JsonSerializable()
class EventsResponse {
  EventsResponse({
    required this.status,
    required this.msg,
    required this.data,
  });

  int status;
  String msg;
  List<EventsData>? data;

  factory EventsResponse.fromJson(Map<String, dynamic> json) {
    print(json);
    return _$EventsResponseFromJson(json);
  }

  Map<String, dynamic> toJson() => _$EventsResponseToJson(this);
}

@JsonSerializable()
class EventsData {
  EventsData(
      {this.id,
      this.title,
      this.event_desc,
      this.event_desc_complete,
      this.can_delete,
      this.event_time_fulltxt,
      this.event_time_only,
      this.event_date_only,
      this.event_icon,
      this.posted_in,
      this.posted_by,
      this.name,
      this.event_venue,
      this.event_graphics});

  int? id;
  String? title;
  String? event_desc;
  String? event_desc_complete;
  String? can_delete;
  String? event_time_fulltxt;
  String? event_time_only;
  String? event_date_only;
  String? event_icon;
  String? posted_in;
  String? posted_by;
  String? name;
  String? event_venue;
  List<EventImagesData>? event_graphics;

  factory EventsData.fromJson(Map<String, dynamic> json) =>
      _$EventsDataFromJson(json);

  Map<String, dynamic> toJson() => _$EventsDataToJson(this);
}

@JsonSerializable()
class EventImagesData {
  EventImagesData({
    required this.id,
    required this.image_name,
    this.thumbnail,
    required this.type,
  });

  String id;
  String image_name;
  String? thumbnail;
  String type;

  factory EventImagesData.fromJson(Map<String, dynamic> json) {
    print(json);
    return _$EventImagesDataFromJson(json);
  }
  Map<String, dynamic> toJson() => _$EventImagesDataToJson(this);
}
