import 'package:json_annotation/json_annotation.dart';
part 'pin_response.g.dart';

@JsonSerializable()
class PinResponse {
  PinResponse({
    required this.status,
    required this.msg,
  });

  int status;
  String msg;

  factory PinResponse.fromJson(Map<String, dynamic> json) {
    print(json);
    return _$PinResponseFromJson(json);
  }

  Map<String, dynamic> toJson() => _$PinResponseToJson(this);
}
