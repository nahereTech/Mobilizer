import 'package:json_annotation/json_annotation.dart';

part 'register_request.g.dart';

@JsonSerializable()
class RegisterRequest {
  RegisterRequest(
      {
      // this.firstname,
      // this.lastname,
      this.email,
      //this.phone,
      this.password,
      this.app_name
      // this.username,
      // this.country,
      // this.state,
      // this.lga,
      //this.ward
      });

  // dynamic firstname;
  // dynamic lastname;
  dynamic email;
  // dynamic phone;
  dynamic password;
  dynamic app_name;
  // dynamic username;
  // dynamic country;
  // dynamic state;
  // dynamic lga;
  // dynamic ward;

  factory RegisterRequest.fromJson(Map<String, dynamic> json) =>
      _$RegisterRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterRequestToJson(this);
}
