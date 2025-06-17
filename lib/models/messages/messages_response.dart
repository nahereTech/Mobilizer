import 'package:json_annotation/json_annotation.dart';
part 'messages_response.g.dart';

@JsonSerializable()
class MessagesResponse {
  MessagesResponse({
    required this.status,
    required this.msg,
    required this.data,
  });

  int status;
  String msg;
  List<MessageData> data;

  factory MessagesResponse.fromJson(Map<String, dynamic> json) {
    print(json);
    return _$MessagesResponseFromJson(json);
  }

  Map<String, dynamic> toJson() => _$MessagesResponseToJson(this);
}

@JsonSerializable()
class MessageData {
  MessageData(
      {required this.message_with,
      required this.message_with_name,
      required this.message,
      required this.unread_count,
      required this.has_new,
      required this.lastest_message_time,
      required this.profile_image});
  dynamic message_with;
  dynamic message_with_name;
  dynamic message;
  dynamic unread_count;
  dynamic has_new;
  dynamic lastest_message_time;
  dynamic profile_image;
  factory MessageData.fromJson(Map<String, dynamic> json) =>
      _$MessageDataFromJson(json);

  Map<String, dynamic> toJson() => _$MessageDataToJson(this);
}
