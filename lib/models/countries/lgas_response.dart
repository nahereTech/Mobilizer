import 'package:json_annotation/json_annotation.dart';

part 'lgas_response.g.dart';

@JsonSerializable()
class LgasResponse {
  LgasResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  int status;
  String message;
  List<LgaData> data;

  factory LgasResponse.fromJson(Map<String, dynamic> json) {
    print(json);
    return _$LgasResponseFromJson(json);
  }

  Map<String, dynamic> toJson() => _$LgasResponseToJson(this);
}

@JsonSerializable()
class LgaData {
  LgaData({
    required this.lga_id,
    required this.lga_name,
  });

  int lga_id;
  String lga_name;

  factory LgaData.fromJson(Map<String, dynamic> json) =>
      _$LgaDataFromJson(json);

  Map<String, dynamic> toJson() => _$LgaDataToJson(this);
}
