// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'followee_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FolloweeResponse _$FolloweeResponseFromJson(Map<String, dynamic> json) =>
    FolloweeResponse(
      status: (json['status'] as num).toInt(),
      msg: json['msg'] as String,
      total_rows: (json['total_rows'] as num).toInt(),
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => FolloweeData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$FolloweeResponseToJson(FolloweeResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'msg': instance.msg,
      'total_rows': instance.total_rows,
      'data': instance.data,
    };

FolloweeData _$FolloweeDataFromJson(Map<String, dynamic> json) => FolloweeData(
      followeeID: json['followeeID'] as String?,
      followeePics: json['followeePics'] as String?,
      photo_path: json['photo_path'] as String?,
      followeeName: json['followeeName'] as String?,
      followeeProfession: json['followeeProfession'] as String?,
      isFollowing: json['isFollowing'] as String?,
    );

Map<String, dynamic> _$FolloweeDataToJson(FolloweeData instance) =>
    <String, dynamic>{
      'followeeID': instance.followeeID,
      'followeePics': instance.followeePics,
      'photo_path': instance.photo_path,
      'followeeName': instance.followeeName,
      'followeeProfession': instance.followeeProfession,
      'isFollowing': instance.isFollowing,
    };
