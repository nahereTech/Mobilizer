import 'package:json_annotation/json_annotation.dart';
part 'organization_ccf_response.g.dart';

@JsonSerializable()
class OrganizationCCFResponse {
  OrganizationCCFResponse({
    required this.status,
    required this.msg,
    this.another_one,
    List<Data>? data,
  }) : data = data ?? [];

  int status;
  String msg;
  String? another_one;
  List<Data>? data;

  factory OrganizationCCFResponse.fromJson(Map<String, dynamic> json) {
    print(json);
    return _$OrganizationCCFResponseFromJson(json);
  }

  Map<String, dynamic> toJson() => _$OrganizationCCFResponseToJson(this);
}

@JsonSerializable()
class Data {
  Data({
    required this.townhall_id,
    required this.name,
    this.level_id,
    this.level_name,
    this.children_count,
  });

  int townhall_id;
  String name;
  int? level_id;
  String? level_name;
  int? children_count;
  factory Data.fromJson(Map<String, dynamic> json) => _$DataFromJson(json);

  Map<String, dynamic> toJson() => _$DataToJson(this);
}
