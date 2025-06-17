import 'package:json_annotation/json_annotation.dart';
part 'like_list_response.g.dart';

@JsonSerializable()
class LikeListResponse {
  LikeListResponse({
    this.status,
    this.msg,
    this.data,
  });

  dynamic status;
  dynamic msg;
  List<LikeData>? data;

  factory LikeListResponse.fromJson(Map<String, dynamic> json) {
    print(json);
    return _$LikeListResponseFromJson(json);
  }

  Map<String, dynamic> toJson() => _$LikeListResponseToJson(this);
}

@JsonSerializable()
class LikeData {
  LikeData(
      {this.id,
      this.firstname,
      this.lastname,
      this.username,
      this.pic,
      this.user_id,
      this.location});
  dynamic id;
  dynamic firstname;
  dynamic lastname;
  dynamic username;
  dynamic pic;
  dynamic user_id;
  dynamic location;

  factory LikeData.fromJson(Map<String, dynamic> json) =>
      _$LikeDataFromJson(json);

  Map<String, dynamic> toJson() => _$LikeDataToJson(this);
}
