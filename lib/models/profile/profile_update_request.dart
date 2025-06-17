import 'package:json_annotation/json_annotation.dart';

part 'profile_update_request.g.dart';

@JsonSerializable()
class ProfileUpdateRequest {
  ProfileUpdateRequest(
      {this.username,
      this.about,
      this.firstname,
      this.lastname,
      this.phone,
      //this.othernames,
      this.gender,
      this.dob,
      this.edu_level_id,
      this.profession_category,
      this.user_profession,
      this.country,
      this.state,
      this.state_origin,
      this.lga,
      this.ward,
      this.pu,
      this.party,
      this.support_group_id});
  dynamic username;
  dynamic about;
  dynamic firstname;
  dynamic lastname;
  dynamic phone;
  //dynamic othernames;
  dynamic gender;
  dynamic dob;
  dynamic edu_level_id;
  dynamic profession_category;
  dynamic user_profession;
  dynamic country;
  dynamic state;
  dynamic state_origin;
  dynamic lga;
  dynamic ward;
  dynamic pu;
  dynamic party;
  dynamic support_group_id;

  factory ProfileUpdateRequest.fromJson(Map<String, dynamic> json) =>
      _$ProfileUpdateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileUpdateRequestToJson(this);
}
