import 'package:json_annotation/json_annotation.dart';
part 'search_people_response.g.dart';

@JsonSerializable()
class SearchPeopleResponse {
  SearchPeopleResponse({
    required this.status,
    required this.msg,
    this.data,
  });

  int status;
  String msg;
  List<SearchPeopleResponseData>? data;

  factory SearchPeopleResponse.fromJson(Map<String, dynamic> json) {
    print(json);
    return _$SearchPeopleResponseFromJson(json);
  }

  Map<String, dynamic> toJson() => _$SearchPeopleResponseToJson(this);
}

@JsonSerializable()
class SearchPeopleResponseData {
  SearchPeopleResponseData(
      {required this.user_id,
      required this.pics,
      required this.photo_path,
      required this.photo_path_lg,
      required this.fullname,
      required this.username,
      required this.is_following,
      required this.state_name,
      required this.lga_name});

  String user_id;
  String pics;
  String photo_path;
  String photo_path_lg;
  String fullname;
  String username;
  String is_following;
  dynamic country_name;
  dynamic state_name;
  dynamic lga_name;

  factory SearchPeopleResponseData.fromJson(Map<String, dynamic> json) =>
      _$SearchPeopleResponseDataFromJson(json);

  Map<String, dynamic> toJson() => _$SearchPeopleResponseDataToJson(this);
}
