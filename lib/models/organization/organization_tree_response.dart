// import 'package:json_annotation/json_annotation.dart';
// part 'organization_tree_response.g.dart';

// @JsonSerializable()
// class OrganizationTreeResponse {
//   OrganizationTreeResponse({
//     required this.status,
//     required this.msg,
//     required this.data,
//   });

//   int status;
//   String msg;
//   TreeData data;

//   factory OrganizationTreeResponse.fromJson(Map<String, dynamic> json) {
//     print(json);
//     return _$OrganizationTreeResponseFromJson(json);
//   }

//   Map<String, dynamic> toJson() => _$OrganizationTreeResponseToJson(this);
// }

// @JsonSerializable()
// class TreeData {
//   TreeData({
//     required this.id,
//     required this.name,
//     required this.level,
//     this.level_name,
//     required this.parent_id,
//     required this.children,
//   });
//   int id;
//   String? name;
//   int level;
//   @JsonKey(name: 'level_name')
//   String? level_name;
//   int parent_id;
//   List<ChildrenData> children;

//   factory TreeData.fromJson(Map<String, dynamic> json) =>
//       _$TreeDataFromJson(json);

//   Map<String, dynamic> toJson() => _$TreeDataToJson(this);
// }

// @JsonSerializable()
// class ChildrenData {
//   ChildrenData({
//     required this.id,
//     required this.name,
//     required this.level,
//     this.level_name,
//     required this.parent_id,
//     required this.children,
//   });
//   int id;
//   String? name;
//   int level;
//   String? level_name;
//   int parent_id;
//   List<ChildrenData> children;

//   factory ChildrenData.fromJson(Map<String, dynamic> json) =>
//       _$ChildrenDataFromJson(json);

//   Map<String, dynamic> toJson() => _$ChildrenDataToJson(this);
// }
import 'package:json_annotation/json_annotation.dart';
part 'organization_tree_response.g.dart';

@JsonSerializable()
class OrganizationTreeResponse {
  final int status;
  final String msg;
  final Data data;

  OrganizationTreeResponse({
    required this.status,
    required this.msg,
    required this.data,
  });

  factory OrganizationTreeResponse.fromJson(Map<String, dynamic> json) =>
      _$OrganizationTreeResponseFromJson(json);

  Map<String, dynamic> toJson() => _$OrganizationTreeResponseToJson(this);
}

@JsonSerializable()
class Data {
  final int id;
  final String name;
  final int level;
  // @JsonKey(name: 'level_name')
  // final String levelName;
  final String level_name;
  // @JsonKey(name: 'parent_id')
  // final int parentId;
  final parent_id;
  final List<Data>? children;

  Data({
    required this.id,
    required this.name,
    required this.level,
    //required this.levelName,
    required this.level_name,
    //required this.parentId,
    required this.parent_id,
    this.children,
  });

  factory Data.fromJson(Map<String, dynamic> json) => _$DataFromJson(json);

  Map<String, dynamic> toJson() => _$DataToJson(this);
}
