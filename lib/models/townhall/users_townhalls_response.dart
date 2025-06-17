import 'package:json_annotation/json_annotation.dart';
part 'users_townhalls_response.g.dart';

@JsonSerializable()
class UsersTownhallsResponse {
  UsersTownhallsResponse({
    required this.status,
    required this.msg,
    List<DataList>? data,
  }) : data = data ?? [];

  int status;
  String msg;

  List<DataList>? data;

  factory UsersTownhallsResponse.fromJson(Map<String, dynamic> json) {
    print(json);
    return _$UsersTownhallsResponseFromJson(json);
  }

  Map<String, dynamic> toJson() => _$UsersTownhallsResponseToJson(this);
}

@JsonSerializable()
class DataList {
  DataList({
    required this.id,
    required this.name,
  });
  String id;
  String name;
  factory DataList.fromJson(Map<String, dynamic> json) =>
      _$DataListFromJson(json);
  Map<String, dynamic> toJson() => _$DataListToJson(this);
}
