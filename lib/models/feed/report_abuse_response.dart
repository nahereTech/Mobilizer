import 'package:json_annotation/json_annotation.dart';

part 'report_abuse_response.g.dart';

@JsonSerializable()
class ReportAbuseResponse {
  ReportAbuseResponse({
    required this.status,
    required this.msg,
  });

  int status;
  String msg;

  factory ReportAbuseResponse.fromJson(Map<String, dynamic> json) =>
      _$ReportAbuseResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ReportAbuseResponseToJson(this);
}
