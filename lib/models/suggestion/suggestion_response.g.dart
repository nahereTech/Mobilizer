// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'suggestion_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SuggestionResponse _$SuggestionResponseFromJson(Map<String, dynamic> json) =>
    SuggestionResponse(
      status: (json['status'] as num).toInt(),
      msg: json['msg'] as String,
      data: (json['data'] as List<dynamic>)
          .map((e) => SuggestionData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SuggestionResponseToJson(SuggestionResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'msg': instance.msg,
      'data': instance.data,
    };

SuggestionData _$SuggestionDataFromJson(Map<String, dynamic> json) =>
    SuggestionData(
      userName: json['userName'],
      userID: json['userID'],
      userPics: json['userPics'],
      photo_path: json['photo_path'],
      fullname: json['fullname'],
      userProfession: json['userProfession'],
    );

Map<String, dynamic> _$SuggestionDataToJson(SuggestionData instance) =>
    <String, dynamic>{
      'userName': instance.userName,
      'userID': instance.userID,
      'userPics': instance.userPics,
      'photo_path': instance.photo_path,
      'fullname': instance.fullname,
      'userProfession': instance.userProfession,
    };
