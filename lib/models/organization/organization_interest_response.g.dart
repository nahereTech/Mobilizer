// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'organization_interest_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrganizationInterestResponse _$OrganizationInterestResponseFromJson(
        Map<String, dynamic> json) =>
    OrganizationInterestResponse(
      status: (json['status'] as num).toInt(),
      msg: json['msg'] as String,
      data: (json['data'] as List<dynamic>)
          .map((e) => InterestData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$OrganizationInterestResponseToJson(
        OrganizationInterestResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'msg': instance.msg,
      'data': instance.data,
    };

InterestData _$InterestDataFromJson(Map<String, dynamic> json) => InterestData(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
    );

Map<String, dynamic> _$InterestDataToJson(InterestData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
    };
