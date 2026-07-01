import 'package:json_annotation/json_annotation.dart';
import 'training_model.dart';

part 'training_response.g.dart';

@JsonSerializable()
class TrainingResponse {
  final String? message;
  final List<TrainingModel>? data;

  TrainingResponse({
    this.message,
    this.data,
  });

  factory TrainingResponse.fromJson(Map<String, dynamic> json) => _$TrainingResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TrainingResponseToJson(this);
}
