import 'package:hive/hive.dart';

part 'password_model.g.dart';

@HiveType(typeId: 0)
class PasswordModel extends HiveObject {
  // Extend HiveObject to enable delete()
  @HiveField(0)
  String name;

  @HiveField(1)
  String username;

  @HiveField(2)
  String password;

  PasswordModel({
    required this.name,
    required this.username,
    required this.password,
  });
}
