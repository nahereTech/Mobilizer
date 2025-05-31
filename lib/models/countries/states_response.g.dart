// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'states_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StatesResponse _$StatesResponseFromJson(Map<String, dynamic> json) =>
    StatesResponse(
      status: (json['status'] as num).toInt(),
      message: json['message'] as String,
      data: (json['data'] as List<dynamic>)
          .map((e) => StatesData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$StatesResponseToJson(StatesResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'message': instance.message,
      'data': instance.data,
    };

StatesData _$StatesDataFromJson(Map<String, dynamic> json) => StatesData(
      state_id: (json['state_id'] as num).toInt(),
      state_name: json['state_name'] as String,
    );

Map<String, dynamic> _$StatesDataToJson(StatesData instance) =>
    <String, dynamic>{
      'state_id': instance.state_id,
      'state_name': instance.state_name,
    };
