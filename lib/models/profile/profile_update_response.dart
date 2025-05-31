import 'package:json_annotation/json_annotation.dart';

part 'profile_update_response.g.dart';

@JsonSerializable()
class ProfileUpdateResponse {
  ProfileUpdateResponse({
    required this.status,
    required this.msg,
  });

  int status;
  String msg;

  factory ProfileUpdateResponse.fromJson(Map<String, dynamic> json) {
    print(json);
    return _$ProfileUpdateResponseFromJson(json);
  }

  Map<String, dynamic> toJson() => _$ProfileUpdateResponseToJson(this);
}
