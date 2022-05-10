// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CardModel _$CardModelFromJson(Map<String, dynamic> json) => CardModel(
      json['id'] as String,
      json['text'] as String,
      (json['x'] as num).toDouble(),
      (json['y'] as num).toDouble(),
      json['color'] as int?,
    );

Map<String, dynamic> _$CardModelToJson(CardModel instance) => <String, dynamic>{
      'id': instance.id,
      'text': instance.text,
      'x': instance.x,
      'y': instance.y,
      'color': instance.color,
    };
