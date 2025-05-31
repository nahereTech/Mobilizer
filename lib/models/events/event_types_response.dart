import 'package:json_annotation/json_annotation.dart';

part 'event_types_response.g.dart';

@JsonSerializable()
class EventTypesResponse {
  EventTypesResponse({
    required this.status,
    required this.msg,
    required this.data,
  });

  int status;
  String msg;
  List<TypeData> data;

  factory EventTypesResponse.fromJson(Map<String, dynamic> json) {
    print(json);
    return _$EventTypesResponseFromJson(json);
  }

  Map<String, dynamic> toJson() => _$EventTypesResponseToJson(this);
}

@JsonSerializable()
class TypeData {
  TypeData({
    required this.id,
    required this.name,
  });

  int id;
  String name;

  factory TypeData.fromJson(Map<String, dynamic> json) =>
      _$TypeDataFromJson(json);

  Map<String, dynamic> toJson() => _$TypeDataToJson(this);
}
