// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_Request _$$_RequestFromJson(Map<String, dynamic> json) => _$_Request(
      appId: json['app_id'] as String,
      sentence: json['sentence'] as String,
      outputType: json['output_type'] as String,
    );

Map<String, dynamic> _$$_RequestToJson(_$_Request instance) =>
    <String, dynamic>{
      'app_id': instance.appId,
      'sentence': instance.sentence,
      'output_type': instance.outputType,
    };
