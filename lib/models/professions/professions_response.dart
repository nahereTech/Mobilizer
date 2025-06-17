import 'package:json_annotation/json_annotation.dart';

part 'professions_response.g.dart';

@JsonSerializable()
class ProfessionResponse {
  ProfessionResponse({
    required this.status,
    required this.msg,
    required this.data,
  });

  int status;
  String msg;
  List<ProfessionData> data;

  factory ProfessionResponse.fromJson(Map<String, dynamic> json) {
    print(json);
    return _$ProfessionResponseFromJson(json);
  }

  Map<String, dynamic> toJson() => _$ProfessionResponseToJson(this);
}

@JsonSerializable()
class ProfessionData {
  ProfessionData({
    this.id,
    this.name,
  });

  int? id;
  String? name;

  factory ProfessionData.fromJson(Map<String, dynamic> json) =>
      _$ProfessionDataFromJson(json);

  Map<String, dynamic> toJson() => _$ProfessionDataToJson(this);
}
