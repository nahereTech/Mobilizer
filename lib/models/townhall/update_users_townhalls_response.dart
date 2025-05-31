import 'package:json_annotation/json_annotation.dart';
part 'update_users_townhalls_response.g.dart';

@JsonSerializable()
class UpdateUsersTownhallsResponse {
  UpdateUsersTownhallsResponse({
    required this.status,
    required this.msg,
  });

  int status;
  String msg;

  factory UpdateUsersTownhallsResponse.fromJson(Map<String, dynamic> json) {
    print(json);
    return _$UpdateUsersTownhallsResponseFromJson(json);
  }

  Map<String, dynamic> toJson() => _$UpdateUsersTownhallsResponseToJson(this);
}

