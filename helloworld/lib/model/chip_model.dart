import 'package:json_annotation/json_annotation.dart' as js;

part 'chip_model.g.dart';

@js.JsonSerializable()
class ChipModel {
  final String id;
  final double x, y;
  final int color;
  
  ChipModel(this.id,  this.x, this.y, this.color);
  
  factory ChipModel.fromJson(Map<String, dynamic> json) => _$ChipModelFromJson(json);

  Map<String, dynamic> toJson() => _$ChipModelToJson(this);
}
