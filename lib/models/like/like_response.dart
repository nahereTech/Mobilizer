import 'package:json_annotation/json_annotation.dart';

part 'like_response.g.dart';

@JsonSerializable()
class LikeResponse {
  LikeResponse({
    required this.status,
    required this.msg,
  });

  int status;
  String msg;

  factory LikeResponse.fromJson(Map<String, dynamic> json) =>
      _$LikeResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LikeResponseToJson(this);
}
