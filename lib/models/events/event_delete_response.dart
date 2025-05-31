import 'package:json_annotation/json_annotation.dart';
part 'event_delete_response.g.dart';

@JsonSerializable()
class EventDeleteResponse {
  EventDeleteResponse({
    required this.status,
    required this.msg,
  });

  int status;
  String msg;

  factory EventDeleteResponse.fromJson(Map<String, dynamic> json) {
    print(json);
    return _$EventDeleteResponseFromJson(json);
  }
  Map<String, dynamic> toJson() => _$EventDeleteResponseToJson(this);
}
