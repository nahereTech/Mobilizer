import 'package:json_annotation/json_annotation.dart';

part 'get_profile_response.g.dart';

@JsonSerializable()
class GetProfileResponse {
  GetProfileResponse({
    required this.status,
    required this.msg,
    required this.data,
    required this.compulsory,
    required this.visible,
  });

  int status;
  String msg;
  ProfileData? data;
  CompulsoryData? compulsory;
  VisibleData visible;

  factory GetProfileResponse.fromJson(Map<String, dynamic> json) {
    print(json);
    return _$GetProfileResponseFromJson(json);
  }

  Map<String, dynamic> toJson() => _$GetProfileResponseToJson(this);
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
      this.can_opt_out,
      this.support_group_name});

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
  dynamic can_opt_out;
  dynamic support_group_name;

  factory ProfileData.fromJson(Map<String, dynamic> json) =>
      _$ProfileDataFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileDataToJson(this);
}

@JsonSerializable()
class CompulsoryData {
  CompulsoryData(
      {this.profile_image,
      this.username,
      this.firstname,
      this.lastname,
      this.phone,
      this.about,
      this.gender,
      this.dob,
      this.edu,
      this.prof_cat,
      this.prof_desc,
      this.email,
      this.state,
      this.state_origin,
      this.country,
      this.lga,
      this.ward,
      this.pu,
      this.supportg});
  dynamic profile_image;
  dynamic username;
  dynamic firstname;
  dynamic lastname;
  dynamic phone;
  dynamic about;
  dynamic gender;
  dynamic dob;
  dynamic edu;
  dynamic prof_cat;
  dynamic prof_desc;
  dynamic email;
  dynamic state;
  dynamic state_origin;
  dynamic country;
  dynamic lga;
  dynamic ward;
  dynamic pu;
  dynamic supportg;

  factory CompulsoryData.fromJson(Map<String, dynamic> json) =>
      _$CompulsoryDataFromJson(json);

  Map<String, dynamic> toJson() => _$CompulsoryDataToJson(this);
}

@JsonSerializable()
class VisibleData {
  VisibleData(
      {required this.profile_image,
      required this.username,
      required this.firstname,
      required this.lastname,
      required this.phone,
      required this.about,
      required this.gender,
      required this.dob,
      required this.edu,
      required this.prof_cat,
      required this.prof_desc,
      required this.email,
      required this.state,
      required this.state_origin,
      required this.country,
      required this.lga,
      required this.ward,
      required this.pu,
      required this.supportg});
  bool profile_image;
  bool username;
  bool firstname;
  bool lastname;
  bool phone;
  bool about;
  bool gender;
  bool dob;
  bool edu;
  bool prof_cat;
  bool prof_desc;
  bool email;
  bool state;
  bool state_origin;
  bool country;
  bool lga;
  bool ward;
  bool pu;
  bool supportg;

  factory VisibleData.fromJson(Map<String, dynamic> json) =>
      _$VisibleDataFromJson(json);

  Map<String, dynamic> toJson() => _$VisibleDataToJson(this);
}
