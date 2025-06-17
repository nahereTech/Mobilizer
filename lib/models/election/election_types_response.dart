import 'package:json_annotation/json_annotation.dart';

part 'election_types_response.g.dart';

@JsonSerializable()
class ElectionTypesResponse {
  ElectionTypesResponse({
    required this.status,
    required this.msg,
    required this.data,
  });

  int status;
  String msg;
  List<TypesData> data;

  factory ElectionTypesResponse.fromJson(Map<String, dynamic> json) {
    print(json);
    return _$ElectionTypesResponseFromJson(json);
  }

  Map<String, dynamic> toJson() => _$ElectionTypesResponseToJson(this);
}

@JsonSerializable()
class TypesData {
  TypesData({
    required this.id,
    required this.name,
  });

  int id;
  String name;

  factory TypesData.fromJson(Map<String, dynamic> json) =>
      _$TypesDataFromJson(json);

  Map<String, dynamic> toJson() => _$TypesDataToJson(this);
}
