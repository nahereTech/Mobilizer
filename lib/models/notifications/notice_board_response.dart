import 'package:json_annotation/json_annotation.dart';

part 'notice_board_response.g.dart';

@JsonSerializable()
class NoticeBoardResponse {
  NoticeBoardResponse({
    required this.status,
    required this.msg,
    required this.data,
  });

  int status;
  String msg;
  Data data;

  factory NoticeBoardResponse.fromJson(Map<String, dynamic> json) {
    print(json);
    return _$NoticeBoardResponseFromJson(json);
  }

  Map<String, dynamic> toJson() => _$NoticeBoardResponseToJson(this);
}

@JsonSerializable()
class Data {
  Data({
    required this.message,
  });

  String message;

  factory Data.fromJson(Map<String, dynamic> json) => _$DataFromJson(json);

  Map<String, dynamic> toJson() => _$DataToJson(this);
}
