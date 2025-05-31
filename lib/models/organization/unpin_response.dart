import 'package:json_annotation/json_annotation.dart';
part 'unpin_response.g.dart';

@JsonSerializable()
class UnpinResponse {
  UnpinResponse({
    required this.status,
    required this.msg,
  });

  int status;
  String msg;

  factory UnpinResponse.fromJson(Map<String, dynamic> json) {
    print(json);
    return _$UnpinResponseFromJson(json);
  }

  Map<String, dynamic> toJson() => _$UnpinResponseToJson(this);
}
