import 'package:json_annotation/json_annotation.dart';
part 'leave_organization_response.g.dart';

@JsonSerializable()
class LeaveOrganizationResponse {
  LeaveOrganizationResponse({
    required this.status,
    required this.msg,
  });

  int status;
  String msg;

  factory LeaveOrganizationResponse.fromJson(Map<String, dynamic> json) {
    print(json);
    return _$LeaveOrganizationResponseFromJson(json);
  }

  Map<String, dynamic> toJson() => _$LeaveOrganizationResponseToJson(this);
}
