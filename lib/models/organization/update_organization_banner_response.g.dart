// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_organization_banner_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateOrganizationBannerResponse _$UpdateOrganizationBannerResponseFromJson(
        Map<String, dynamic> json) =>
    UpdateOrganizationBannerResponse(
      status: (json['status'] as num).toInt(),
      msg: json['msg'] as String,
      data: json['data'] == null
          ? null
          : Data.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UpdateOrganizationBannerResponseToJson(
        UpdateOrganizationBannerResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'msg': instance.msg,
      'data': instance.data,
    };

Data _$DataFromJson(Map<String, dynamic> json) => Data(
      bgimage: json['bgimage'] as String,
    );

Map<String, dynamic> _$DataToJson(Data instance) => <String, dynamic>{
      'bgimage': instance.bgimage,
    };
