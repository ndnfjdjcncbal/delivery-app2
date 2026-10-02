import 'package:delivert_app2/features/auth/domain/entiti/entity_login.dart';

class UserModel extends User {
  UserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.phone,
    required super.image,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final payload = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'] as Map)
        : json;
    final user = payload['user'] is Map
        ? Map<String, dynamic>.from(payload['user'] as Map)
        : payload;

    return UserModel(
      id: user['user_id'].toString(),
      name: user['user_name'].toString(),

      email: user['user_email'].toString(),
      phone: user['user_phone']?.toString(),
      image: user['user_image']?.toString(),
    );
  }

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      name: user.name,
      email: user.email,
      phone: user.phone,
      image: user.image,
    );
  }

  User toEntity() {
    return User(id: id, name: name, email: email, phone: phone, image: image);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'image': image,
    };
  }
}
