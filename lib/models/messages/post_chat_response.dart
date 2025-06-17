import 'package:json_annotation/json_annotation.dart';
part 'post_chat_response.g.dart';

@JsonSerializable()
class PostChatResponse {
  PostChatResponse({
    required this.status,
    required this.msg,
    required this.data,
  });

  int status;
  String msg;
  ChatData? data;
  //List<VideoData> videos;

  factory PostChatResponse.fromJson(Map<String, dynamic> json) {
    print(json);
    return _$PostChatResponseFromJson(json);
  }

  Map<String, dynamic> toJson() => _$PostChatResponseToJson(this);
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
      this.message_images});
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
    required this.image_filepath,
    required this.image_filename,
  });
  dynamic image_filepath;
  dynamic image_filename;
  factory ImageData.fromJson(Map<String, dynamic> json) =>
      _$ImageDataFromJson(json);

  Map<String, dynamic> toJson() => _$ImageDataToJson(this);
}
// @JsonSerializable()
// class VideoData {
//   ImageData({
//     required this.image_filepath,
//     required this.image_filename,
//   });
//   dynamic image_filepath;
//   dynamic image_filename;
//   factory VideoData.fromJson(Map<String, dynamic> json) =>
//       _$VideoDataFromJson(json);

//   Map<String, dynamic> toJson() => _$VideoDataToJson(this);
// }
