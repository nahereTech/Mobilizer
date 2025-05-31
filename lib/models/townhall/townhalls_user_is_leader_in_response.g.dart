// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'townhalls_user_is_leader_in_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TownhallsLeaderIsResponse _$TownhallsLeaderIsResponseFromJson(
        Map<String, dynamic> json) =>
    TownhallsLeaderIsResponse(
      status: (json['status'] as num).toInt(),
      msg: json['msg'] as String?,
      data: (json['data'] as List<dynamic>)
          .map((e) => Data.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TownhallsLeaderIsResponseToJson(
        TownhallsLeaderIsResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'msg': instance.msg,
      'data': instance.data,
    };

Data _$DataFromJson(Map<String, dynamic> json) => Data(
      townhall_id: json['townhall_id'],
      townhall_name: json['townhall_name'],
      org_name: json['org_name'],
      org_id: json['org_id'],
      designation: json['designation'],
    );

Map<String, dynamic> _$DataToJson(Data instance) => <String, dynamic>{
      'townhall_id': instance.townhall_id,
      'townhall_name': instance.townhall_name,
      'org_name': instance.org_name,
      'org_id': instance.org_id,
      'designation': instance.designation,
    };
