// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'organization_plan_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrganizationPlanResponse _$OrganizationPlanResponseFromJson(
        Map<String, dynamic> json) =>
    OrganizationPlanResponse(
      status: (json['status'] as num?)?.toInt(),
      msg: json['msg'] as String?,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => PlanData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$OrganizationPlanResponseToJson(
        OrganizationPlanResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'msg': instance.msg,
      'data': instance.data,
    };

PlanData _$PlanDataFromJson(Map<String, dynamic> json) => PlanData(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      desc: json['desc'] as String,
      temp_creation_id: json['temp_creation_id'] as String?,
    );

Map<String, dynamic> _$PlanDataToJson(PlanData instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'desc': instance.desc,
      'temp_creation_id': instance.temp_creation_id,
    };
