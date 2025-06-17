import 'package:json_annotation/json_annotation.dart';
part 'chat_history_response.g.dart';

@JsonSerializable()
class ChatHistoryResponse {
  ChatHistoryResponse({
    required this.status,
    required this.msg,
    required this.data,
  });

  int status;
  String msg;
  List<ChatData> data;

  factory ChatHistoryResponse.fromJson(Map<String, dynamic> json) {
    print(json);
    return _$ChatHistoryResponseFromJson(json);
  }

  Map<String, dynamic> toJson() => _$ChatHistoryResponseToJson(this);
}

@JsonSerializable()
class ChatData {
  ChatData(
      {required this.message_id,
      required this.message_from,
      required this.message_to,
      required this.from_me,
      required this.message,
      required this.message_time,
      required message_images});
  dynamic message_id;
  dynamic message_from;
  dynamic message_to;
  dynamic from_me;
  dynamic message;
  dynamic message_time;
  List<ImageData>? message_images;
  factory ChatData.fromJson(Map<String, dynamic> json) =>
      _$ChatDataFromJson(json);

  Map<String, dynamic> toJson() => _$ChatDataToJson(this);
}

@JsonSerializable()
class ImageData {
  ImageData({
    this.image_filepath,
    this.image_filename,
  });

  dynamic image_filepath;
  dynamic image_filename;

  factory ImageData.fromJson(Map<String, dynamic> json) =>
      _$ImageDataFromJson(json);

  Map<String, dynamic> toJson() => _$ImageDataToJson(this);
}
