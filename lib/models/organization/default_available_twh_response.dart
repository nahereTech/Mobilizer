import 'package:json_annotation/json_annotation.dart';
part 'default_available_twh_response.g.dart';

@JsonSerializable()
class DefaultAvailableTWHResponse {
  DefaultAvailableTWHResponse({
    required this.status,
    required this.msg,
    required this.data,
  });

  int status;
  String msg;
  List<AvailableData> data;

  factory DefaultAvailableTWHResponse.fromJson(Map<String, dynamic> json) {
    print(json);
    return _$DefaultAvailableTWHResponseFromJson(json);
  }

  Map<String, dynamic> toJson() => _$DefaultAvailableTWHResponseToJson(this);
}

@JsonSerializable()
class AvailableData {
  AvailableData(
      {required this.name,
      this.pic,
      required this.is_checked,
      required this.circle_reduction_percentage});

  String name;
  String? pic;
  bool is_checked;
  int circle_reduction_percentage;

  factory AvailableData.fromJson(Map<String, dynamic> json) =>
      _$AvailableDataFromJson(json);

  Map<String, dynamic> toJson() => _$AvailableDataToJson(this);
}
