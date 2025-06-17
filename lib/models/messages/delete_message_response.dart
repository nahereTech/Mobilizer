import 'package:json_annotation/json_annotation.dart';

part 'delete_message_response.g.dart';

@JsonSerializable()
class DeleteMessageResponse {
  DeleteMessageResponse({
    required this.status,
    required this.msg,
  });

  int status;
  String msg;

  factory DeleteMessageResponse.fromJson(Map<String, dynamic> json) {
    print(json);
    return _$DeleteMessageResponseFromJson(json);
  }

  Map<String, dynamic> toJson() => _$DeleteMessageResponseToJson(this);
}
