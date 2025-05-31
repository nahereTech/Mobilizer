import 'package:json_annotation/json_annotation.dart';

part 'delete_chat_history_response.g.dart';

@JsonSerializable()
class DeleteChatHistoryResponse {
  DeleteChatHistoryResponse({
    required this.status,
    required this.msg,
  });

  int status;
  String msg;

  factory DeleteChatHistoryResponse.fromJson(Map<String, dynamic> json) {
    print(json);
    return _$DeleteChatHistoryResponseFromJson(json);
  }

  Map<String, dynamic> toJson() => _$DeleteChatHistoryResponseToJson(this);
}
