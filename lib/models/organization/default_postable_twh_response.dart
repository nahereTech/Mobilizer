import 'package:json_annotation/json_annotation.dart';
part 'default_postable_twh_response.g.dart';

@JsonSerializable()
class DefaultPostableTWHResponse {
  DefaultPostableTWHResponse({
    required this.status,
    required this.msg,
    required this.data,
  });

  int status;
  String msg;
  List<PostableData> data;

  factory DefaultPostableTWHResponse.fromJson(Map<String, dynamic> json) {
    print(json);
    return _$DefaultPostableTWHResponseFromJson(json);
  }

  Map<String, dynamic> toJson() => _$DefaultPostableTWHResponseToJson(this);
}

@JsonSerializable()
class PostableData {
  PostableData(
      {required this.name,
      this.pic,
      required this.is_checked,
      required this.circle_reduction_percentage});

  String name;
  String? pic;
  bool is_checked;
  int circle_reduction_percentage;

  factory PostableData.fromJson(Map<String, dynamic> json) =>
      _$PostableDataFromJson(json);

  Map<String, dynamic> toJson() => _$PostableDataToJson(this);
}
