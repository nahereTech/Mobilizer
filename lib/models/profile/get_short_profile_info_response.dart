import 'package:json_annotation/json_annotation.dart';

part 'get_short_profile_info_response.g.dart';

@JsonSerializable()
class GetShortProfileInfoResponse {
  GetShortProfileInfoResponse({
    required this.status,
    required this.msg,
    required this.data,
  });

  int status;
  String msg;
  ProfileData? data;

  factory GetShortProfileInfoResponse.fromJson(Map<String, dynamic> json) {
    // print(json);
    return _$GetShortProfileInfoResponseFromJson(json);
  }
  Map<String, dynamic> toJson() => _$GetShortProfileInfoResponseToJson(this);
}

@JsonSerializable()
class ProfileData {
  ProfileData(
      {this.user_id,
      this.username,
      this.firstname,
      this.lastname,
      this.email,
      this.photo_path,
      this.photo_path_mid,
      this.photo_path_lg,
      this.country_id,
      this.country_name,
      this.state_id,
      this.state_name,
      this.lga_id,
      this.lga_name,
      this.ward_id,
      this.ward_name,
      this.pu_id,
      this.pu_name,
      this.self_view,
      this.share_link,
      this.is_following,
      this.followers,
      this.followings,
      this.townhalls,
      this.blocked_or_not,
      this.profession,
      this.profession_category,
      this.device_tokens});

  dynamic user_id;
  dynamic username;
  dynamic firstname;
  dynamic lastname;
  dynamic email;
  dynamic photo_path;
  dynamic photo_path_mid;
  dynamic photo_path_lg;
  dynamic country_id;
  dynamic country_name;
  dynamic state_id;
  dynamic state_name;
  dynamic lga_id;
  dynamic lga_name;
  dynamic ward_id;
  dynamic ward_name;
  dynamic pu_id;
  dynamic pu_name;
  dynamic self_view;
  dynamic share_link;
  dynamic is_following;
  dynamic followers;
  dynamic followings;
  dynamic townhalls;
  dynamic blocked_or_not;
  dynamic profession;
  dynamic profession_category;
  List<DeviceTokensData>? device_tokens;
  factory ProfileData.fromJson(Map<String, dynamic> json) =>
      _$ProfileDataFromJson(json);
  Map<String, dynamic> toJson() => _$ProfileDataToJson(this);
}

@JsonSerializable()
class DeviceTokensData {
  DeviceTokensData({
    this.device_token,
  });
  dynamic device_token;

  factory DeviceTokensData.fromJson(Map<String, dynamic> json) =>
      _$DeviceTokensDataFromJson(json);
  Map<String, dynamic> toJson() => _$DeviceTokensDataToJson(this);
}
