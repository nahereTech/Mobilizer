import 'package:json_annotation/json_annotation.dart';

part 'qualifications_response.g.dart';

@JsonSerializable()
class QualificationResponse {
  QualificationResponse({
    required this.status,
    required this.msg,
    required this.data,
  });

  int status;
  String msg;
  List<QualificationData> data;

  factory QualificationResponse.fromJson(Map<String, dynamic> json) {
    print(json);
    return _$QualificationResponseFromJson(json);
  }

  Map<String, dynamic> toJson() => _$QualificationResponseToJson(this);
}

@JsonSerializable()
class QualificationData {
  QualificationData({
    this.id,
    this.name,
  });

  int? id;
  String? name;

  factory QualificationData.fromJson(Map<String, dynamic> json) =>
      _$QualificationDataFromJson(json);

  Map<String, dynamic> toJson() => _$QualificationDataToJson(this);
}
