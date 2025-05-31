import 'package:json_annotation/json_annotation.dart';
part 'profile_image_response.g.dart';

@JsonSerializable()
class ProfileImageResponse {
  ProfileImageResponse({
    required this.status,
    required this.msg,
    required this.data,
  });

  int status;
  String msg;
  UserData data;

  factory ProfileImageResponse.fromJson(Map<String, dynamic> json) =>
      _$ProfileImageResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileImageResponseToJson(this);
}

@JsonSerializable()
class UserData {
  UserData({
    required this.photo_path,
    required this.photo_path_mid,
    required this.photo_path_lg,
  });

  String photo_path;
  String photo_path_mid;
  String photo_path_lg;

  factory UserData.fromJson(Map<String, dynamic> json) =>
      _$UserDataFromJson(json);

  Map<String, dynamic> toJson() => _$UserDataToJson(this);
}
