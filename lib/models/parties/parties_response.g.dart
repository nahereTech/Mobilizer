// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parties_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PartyResponse _$PartyResponseFromJson(Map<String, dynamic> json) =>
    PartyResponse(
      status: json['status'] as String,
      msg: json['msg'] as String,
      page_headings: json['page_headings'],
      data: (json['data'] as List<dynamic>)
          .map((e) => PartyData.fromJson(e as Map<String, dynamic>))
          .toList(),
    )..uploaded_images = (json['uploaded_images'] as List<dynamic>?)
        ?.map((e) => ImagesData.fromJson(e as Map<String, dynamic>))
        .toList();

Map<String, dynamic> _$PartyResponseToJson(PartyResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'page_headings': instance.page_headings,
      'msg': instance.msg,
      'data': instance.data,
      'uploaded_images': instance.uploaded_images,
    };

PartyData _$PartyDataFromJson(Map<String, dynamic> json) => PartyData(
      id: json['id'] as String?,
      index: json['index'],
      name: json['name'] as String?,
      fullname: json['fullname'] as String?,
      country_id: json['country_id'] as String?,
      party_logo: json['party_logo'] as String?,
      votes: json['votes'],
    );

Map<String, dynamic> _$PartyDataToJson(PartyData instance) => <String, dynamic>{
      'id': instance.id,
      'index': instance.index,
      'name': instance.name,
      'fullname': instance.fullname,
      'country_id': instance.country_id,
      'party_logo': instance.party_logo,
      'votes': instance.votes,
    };

ImagesData _$ImagesDataFromJson(Map<String, dynamic> json) => ImagesData(
      image_url: json['image_url'],
    );

Map<String, dynamic> _$ImagesDataToJson(ImagesData instance) =>
    <String, dynamic>{
      'image_url': instance.image_url,
    };
