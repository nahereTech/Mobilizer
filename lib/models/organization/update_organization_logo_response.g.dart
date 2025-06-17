// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_organization_logo_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateOrganizationLogoResponse _$UpdateOrganizationLogoResponseFromJson(
        Map<String, dynamic> json) =>
    UpdateOrganizationLogoResponse(
      status: (json['status'] as num).toInt(),
      msg: json['msg'] as String,
      data: json['data'] == null
          ? null
          : Data.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UpdateOrganizationLogoResponseToJson(
        UpdateOrganizationLogoResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'msg': instance.msg,
      'data': instance.data,
    };

Data _$DataFromJson(Map<String, dynamic> json) => Data(
      logoimage: json['logoimage'] as String,
    );

Map<String, dynamic> _$DataToJson(Data instance) => <String, dynamic>{
      'logoimage': instance.logoimage,
    };
