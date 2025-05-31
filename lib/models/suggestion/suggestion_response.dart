import 'package:json_annotation/json_annotation.dart';
part 'suggestion_response.g.dart';

@JsonSerializable()
class SuggestionResponse {
  SuggestionResponse({
    required this.status,
    required this.msg,
    required this.data,
  });

  int status;
  String msg;
  List<SuggestionData> data;

  factory SuggestionResponse.fromJson(Map<String, dynamic> json) {
    //print(json);
    return _$SuggestionResponseFromJson(json);
  }

  Map<String, dynamic> toJson() => _$SuggestionResponseToJson(this);
}

@JsonSerializable()
class SuggestionData {
  SuggestionData({
    this.userName,
    this.userID,
    this.userPics,
    this.photo_path,
    this.fullname,
    this.userProfession,
  });

  dynamic userName;
  dynamic userID;
  dynamic userPics;
  dynamic photo_path;
  dynamic fullname;
  dynamic userProfession;

  factory SuggestionData.fromJson(Map<String, dynamic> json) =>
      _$SuggestionDataFromJson(json);

  Map<String, dynamic> toJson() => _$SuggestionDataToJson(this);
}
