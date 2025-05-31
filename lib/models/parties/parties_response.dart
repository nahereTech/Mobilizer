import 'package:json_annotation/json_annotation.dart';

part 'parties_response.g.dart';

@JsonSerializable()
class PartyResponse {
  PartyResponse({
    required this.status,
    required this.msg,
    this.page_headings,
    required this.data,
  });

  String status;
  dynamic page_headings;
  String msg;
  List<PartyData> data;
  List<ImagesData>? uploaded_images;

  factory PartyResponse.fromJson(Map<String, dynamic> json) {
    print(json);
    return _$PartyResponseFromJson(json);
  }

  Map<String, dynamic> toJson() => _$PartyResponseToJson(this);
}

@JsonSerializable()
class PartyData {
  PartyData(
      {this.id,
      this.index,
      this.name,
      this.fullname,
      this.country_id,
      this.party_logo,
      this.votes});

  String? id;
  dynamic? index;
  String? name;
  String? fullname;
  String? country_id;
  String? party_logo;
  dynamic votes;

  factory PartyData.fromJson(Map<String, dynamic> json) =>
      _$PartyDataFromJson(json);

  Map<String, dynamic> toJson() => _$PartyDataToJson(this);
}

@JsonSerializable()
class ImagesData {
  ImagesData({
    this.image_url,
  });
  dynamic image_url;
  factory ImagesData.fromJson(Map<String, dynamic> json) =>
      _$ImagesDataFromJson(json);

  Map<String, dynamic> toJson() => _$ImagesDataToJson(this);
}
