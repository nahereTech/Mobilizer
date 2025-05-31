// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'like_list_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LikeListResponse _$LikeListResponseFromJson(Map<String, dynamic> json) =>
    LikeListResponse(
      status: json['status'],
      msg: json['msg'],
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => LikeData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$LikeListResponseToJson(LikeListResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'msg': instance.msg,
      'data': instance.data,
    };

LikeData _$LikeDataFromJson(Map<String, dynamic> json) => LikeData(
      id: json['id'],
      firstname: json['firstname'],
      lastname: json['lastname'],
      username: json['username'],
      pic: json['pic'],
      user_id: json['user_id'],
      location: json['location'],
    );

Map<String, dynamic> _$LikeDataToJson(LikeData instance) => <String, dynamic>{
      'id': instance.id,
      'firstname': instance.firstname,
      'lastname': instance.lastname,
      'username': instance.username,
      'pic': instance.pic,
      'user_id': instance.user_id,
      'location': instance.location,
    };
