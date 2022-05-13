// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chip_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChipModel _$ChipModelFromJson(Map<String, dynamic> json) => ChipModel(
      json['id'] as String,
      (json['x'] as num).toDouble(),
      (json['y'] as num).toDouble(),
      json['color'] as int,
    );

Map<String, dynamic> _$ChipModelToJson(ChipModel instance) => <String, dynamic>{
      'id': instance.id,
      'x': instance.x,
      'y': instance.y,
      'color': instance.color,
    };
