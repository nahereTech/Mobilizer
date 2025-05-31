import 'package:json_annotation/json_annotation.dart';

part 'post_result_response.g.dart';

@JsonSerializable()
class PostResultResponse {
  PostResultResponse({
    required this.status,
    required this.msg,
  });

  int status;
  String msg;

  factory PostResultResponse.fromJson(Map<String, dynamic> json) =>
      _$PostResultResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PostResultResponseToJson(this);
}
