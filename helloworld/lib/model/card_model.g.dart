// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CardModel _$CardModelFromJson(Map<String, dynamic> json) => CardModel(
      json['id'] as String,
      json['text'] as String,
      (json['x'] as num).toDouble(),
      (json['y'] as num).toDouble(),
      json['color'] as int,
      json['flipable'] as bool,
      json['flip'] as bool,
      json['fliptext'] as String,
      json['prio'] as int,
      (json['sizex'] as num).toDouble(),
      (json['sizey'] as num).toDouble(),
    );

Map<String, dynamic> _$CardModelToJson(CardModel instance) => <String, dynamic>{
      'id': instance.id,
      'text': instance.text,
      'x': instance.x,
      'y': instance.y,
      'color': instance.color,
      'flipable': instance.flipable,
      'flip': instance.flip,
      'fliptext': instance.fliptext,
      'prio': instance.prio,
      'sizex': instance.sizex,
      'sizey': instance.sizey,
    };
