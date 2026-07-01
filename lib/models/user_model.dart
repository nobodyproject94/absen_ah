import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

int? _stringToInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is String) return int.tryParse(value);
  return null;
}

@JsonSerializable()
class UserModel {
  final int? id;
  final String? name;
  final String? email;
  @JsonKey(name: 'jenis_kelamin')
  final String? jenisKelamin;
  @JsonKey(name: 'profile_photo')
  final String? profilePhoto;
  @JsonKey(name: 'batch_id', fromJson: _stringToInt)
  final int? batchId;
  @JsonKey(name: 'training_id', fromJson: _stringToInt)
  final int? trainingId;
  @JsonKey(name: 'email_verified_at')
  final String? emailVerifiedAt;

  UserModel({
    this.id,
    this.name,
    this.email,
    this.jenisKelamin,
    this.profilePhoto,
    this.batchId,
    this.trainingId,
    this.emailVerifiedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}
