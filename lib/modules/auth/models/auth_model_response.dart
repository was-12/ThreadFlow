import 'package:thread_flow/modules/auth/domain/entities/user.dart';

class UserModel extends User {
  UserModel({required super.username, required super.userId});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['user_id'] as int,
      username: json['username'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'user_id': userId, 'username': username};
  }
}
