import 'package:json_annotation/json_annotation.dart' as js;

part 'content_model.g.dart';

@js.JsonSerializable()
class ContentModel {
  final String id;
  final String type;
  final String title;
  final String description;
  
  ContentModel(this.id, this.type, this.title, this.description);
  
  factory ContentModel.fromJson(Map<String, dynamic> json) => _$ContentModelFromJson(json);

  Map<String, dynamic> toJson() => _$ContentModelToJson(this);
}
