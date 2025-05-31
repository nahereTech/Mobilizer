import 'package:json_annotation/json_annotation.dart';

part 'block_user_response.g.dart';

@JsonSerializable()
class BlockUserResponse {
  BlockUserResponse({
    required this.status,
    required this.msg,
  });

  int status;
  String msg;

  factory BlockUserResponse.fromJson(Map<String, dynamic> json) =>
      _$BlockUserResponseFromJson(json);

  Map<String, dynamic> toJson() => _$BlockUserResponseToJson(this);
}
