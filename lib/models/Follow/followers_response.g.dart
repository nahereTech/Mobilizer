// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'followers_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FollowersResponse _$FollowersResponseFromJson(Map<String, dynamic> json) =>
    FollowersResponse(
      status: json['status'] as String,
      msg: json['msg'] as String,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => FollowersData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$FollowersResponseToJson(FollowersResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'msg': instance.msg,
      'data': instance.data,
    };

FollowersData _$FollowersDataFromJson(Map<String, dynamic> json) =>
    FollowersData(
      username: json['username'],
      followerID: json['followerID'],
      followerPics: json['followerPics'],
      photo_path: json['photo_path'],
      followerName: json['followerName'],
      state_name: json['state_name'],
      lga_name: json['lga_name'],
      followerProfession: json['followerProfession'],
      amFollowing: json['amFollowing'],
      total: json['total'],
    );

Map<String, dynamic> _$FollowersDataToJson(FollowersData instance) =>
    <String, dynamic>{
      'username': instance.username,
      'followerID': instance.followerID,
      'followerPics': instance.followerPics,
      'photo_path': instance.photo_path,
      'followerName': instance.followerName,
      'state_name': instance.state_name,
      'lga_name': instance.lga_name,
      'followerProfession': instance.followerProfession,
      'amFollowing': instance.amFollowing,
      'total': instance.total,
    };
