import 'package:json_annotation/json_annotation.dart';
part 'term_response.g.dart';

@JsonSerializable()
class TermResponse {
  TermResponse({
    required this.status,
    required this.msg,
    required this.data,
  });

  String status;
  String msg;
  TermData? data;

  factory TermResponse.fromJson(Map<String, dynamic> json) {
    //print(json);
    return _$TermResponseFromJson(json);
  }

  Map<String, dynamic> toJson() => _$TermResponseToJson(this);
}

@JsonSerializable()
class TermData {
  TermData({
    required this.terms,
  });

  String terms;

  factory TermData.fromJson(Map<String, dynamic> json) =>
      _$TermDataFromJson(json);

  Map<String, dynamic> toJson() => _$TermDataToJson(this);
}
