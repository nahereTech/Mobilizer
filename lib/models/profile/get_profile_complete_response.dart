import 'package:json_annotation/json_annotation.dart';

part 'get_profile_complete_response.g.dart';

@JsonSerializable()
class GetProfileCompleteResponse {
  GetProfileCompleteResponse({
    required this.status,
    required this.msg,
  });

  String status;
  String msg;

  factory GetProfileCompleteResponse.fromJson(Map<String, dynamic> json) {
    print(json);
    return _$GetProfileCompleteResponseFromJson(json);
  }

  Map<String, dynamic> toJson() => _$GetProfileCompleteResponseToJson(this);
}
