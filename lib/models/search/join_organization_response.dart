import 'package:json_annotation/json_annotation.dart';
part 'join_organization_response.g.dart';

@JsonSerializable()
class JoinOrganizationResponse {
  JoinOrganizationResponse({
    required this.status,
    required this.msg,
    this.tag,
    List<DropData>? dropdown,
  }) : dropdown = dropdown ?? [];

  int status;
  String msg;
  String? tag;
  List<DropData>? dropdown;

  factory JoinOrganizationResponse.fromJson(Map<String, dynamic> json) {
    print(json);
    return _$JoinOrganizationResponseFromJson(json);
  }

  Map<String, dynamic> toJson() => _$JoinOrganizationResponseToJson(this);
}

@JsonSerializable()
class DropData {
  DropData({
    required this.id,
    required this.selected,
    required this.required,
    List<LevelData>? level_list,
  }) : level_list = level_list ?? [];
  int id;
  int selected;
  bool required;
  List<LevelData>? level_list;
  factory DropData.fromJson(Map<String, dynamic> json) =>
      _$DropDataFromJson(json);
  Map<String, dynamic> toJson() => _$DropDataToJson(this);
}

@JsonSerializable()
class LevelData {
  LevelData({required this.id, required this.name});
  int id;
  String name;

  factory LevelData.fromJson(Map<String, dynamic> json) =>
      _$LevelDataFromJson(json);
  Map<String, dynamic> toJson() => _$LevelDataToJson(this);
}
