import 'package:json_annotation/json_annotation.dart';

part 'states_response.g.dart';

@JsonSerializable()
class StatesResponse {
  StatesResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  int status;
  String message;
  List<StatesData> data;

  factory StatesResponse.fromJson(Map<String, dynamic> json) {
    print(json);
    return _$StatesResponseFromJson(json);
  }

  Map<String, dynamic> toJson() => _$StatesResponseToJson(this);
}

@JsonSerializable()
class StatesData {
  StatesData({
    required this.state_id,
    required this.state_name,
  });

  int state_id;
  String state_name;

  factory StatesData.fromJson(Map<String, dynamic> json) =>
      _$StatesDataFromJson(json);

  Map<String, dynamic> toJson() => _$StatesDataToJson(this);
}
