// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'followees_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FolloweesResponse _$FolloweesResponseFromJson(Map<String, dynamic> json) =>
    FolloweesResponse(
      status: json['status'] as String,
      msg: json['msg'] as String,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => FolloweesData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$FolloweesResponseToJson(FolloweesResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'msg': instance.msg,
      'data': instance.data,
    };

FolloweesData _$FolloweesDataFromJson(Map<String, dynamic> json) =>
    FolloweesData(
      username: json['username'],
      followeeID: json['followeeID'],
      followeePics: json['followeePics'],
      photo_path: json['photo_path'],
      followeeName: json['followeeName'],
      state_name: json['state_name'],
      lga_name: json['lga_name'],
      followeeProfession: json['followeeProfession'],
      isFollowing: json['isFollowing'],
      total: json['total'],
    );

Map<String, dynamic> _$FolloweesDataToJson(FolloweesData instance) =>
    <String, dynamic>{
      'username': instance.username,
      'followeeID': instance.followeeID,
      'followeePics': instance.followeePics,
      'photo_path': instance.photo_path,
      'followeeName': instance.followeeName,
      'state_name': instance.state_name,
      'lga_name': instance.lga_name,
      'followeeProfession': instance.followeeProfession,
      'isFollowing': instance.isFollowing,
      'total': instance.total,
    };
