// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lgas_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LgasResponse _$LgasResponseFromJson(Map<String, dynamic> json) => LgasResponse(
      status: (json['status'] as num).toInt(),
      message: json['message'] as String,
      data: (json['data'] as List<dynamic>)
          .map((e) => LgaData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$LgasResponseToJson(LgasResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'message': instance.message,
      'data': instance.data,
    };

LgaData _$LgaDataFromJson(Map<String, dynamic> json) => LgaData(
      lga_id: (json['lga_id'] as num).toInt(),
      lga_name: json['lga_name'] as String,
    );

Map<String, dynamic> _$LgaDataToJson(LgaData instance) => <String, dynamic>{
      'lga_id': instance.lga_id,
      'lga_name': instance.lga_name,
    };
