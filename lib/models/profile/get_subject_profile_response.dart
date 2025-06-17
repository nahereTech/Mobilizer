import 'package:json_annotation/json_annotation.dart';

part 'get_subject_profile_response.g.dart';

@JsonSerializable()
class GetSubjectProfileResponse {
  GetSubjectProfileResponse({
    required this.status,
    required this.msg,
    required this.data,
  });

  int status;
  String msg;
  ProfileData? data;

  factory GetSubjectProfileResponse.fromJson(Map<String, dynamic> json) {
    print("Message $json");
    return _$GetSubjectProfileResponseFromJson(json);
  }

  Map<String, dynamic> toJson() => _$GetSubjectProfileResponseToJson(this);
}

@JsonSerializable()
class ProfileData {
  ProfileData(
      {this.user_id,
      this.firstname,
      this.lastname,
      this.email,
      this.username,
      this.about_me,
      this.phone,
      this.othernames,
      this.gender,
      this.edu_level_id,
      this.edu_level_txt,
      this.country_id,
      this.country_name,
      this.state_id,
      this.state_name,
      this.state_origin_id,
      this.state_origin_name,
      this.lga_id,
      this.lga_name,
      this.ward_id,
      this.ward_name,
      this.dob,
      this.profession,
      this.profession_category,
      this.profession_category_txt,
      this.photo_path,
      this.photo_path_mid,
      this.photo_path_lg,
      this.pu_id,
      this.pu_name,
      this.party_name,
      this.party_accronym,
      this.show_polling_unit,
      this.party_id,
      this.blocked_or_not,
      this.support_group_id,
      this.support_group_name,
      this.share_link,
      this.is_following,
      required this.followers,
      required this.followings,
      required this.townhalls,
      this.self_view});

  dynamic user_id;
  dynamic firstname;
  dynamic lastname;
  dynamic email;
  dynamic phone;
  dynamic othernames;
  dynamic username;
  dynamic about_me;
  dynamic gender;
  dynamic country_id;
  dynamic country_name;
  dynamic state_id;
  dynamic state_name;
  dynamic state_origin_id;
  dynamic state_origin_name;
  dynamic lga_id;
  dynamic lga_name;
  dynamic ward_id;
  dynamic ward_name;
  dynamic pu_id;
  dynamic pu_name;
  dynamic show_polling_unit;
  dynamic party_id;
  dynamic party_name;
  dynamic party_accronym;
  dynamic dob;
  dynamic edu_level_id;
  dynamic edu_level_txt;
  dynamic profession;
  dynamic profession_category;
  dynamic profession_category_txt;
  dynamic photo_path;
  dynamic photo_path_mid;
  dynamic photo_path_lg;
  dynamic blocked_or_not;
  dynamic support_group_id;
  dynamic share_link;
  dynamic is_following;
  int followings;
  int followers;
  int townhalls;
  dynamic self_view;
  dynamic support_group_name;

  factory ProfileData.fromJson(Map<String, dynamic> json) =>
      _$ProfileDataFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileDataToJson(this);
}
