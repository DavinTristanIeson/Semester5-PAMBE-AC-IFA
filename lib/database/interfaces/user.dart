import 'package:image_picker/image_picker.dart';
import 'package:pambe_ac_ifa/models/container.dart';
import 'package:pambe_ac_ifa/models/user.dart';

typedef LoginPayload = ({String email, String password});
typedef UpdateAuthPayload = ({String? email, String? password});
typedef RegisterPayload = ({
  String email,
  String password,
  String name,
  String? bio,
});
typedef UserEditPayload = ({
  String name,
  String? bio,
  XFile? image,
  DateTime? birthdate,
  String? country,
});

abstract class IUserResourceManager {
  Future<UserModel?> get(String id);
  Future<UserModel> put(
    String id, {
    Optional<String>? email,
    Optional<String>? name,
    Optional<String?>? bio,
    Optional<XFile?>? image,
    Optional<DateTime?>? birthdate,
    Optional<String?>? country,
  });
  Future<void> remove(String id);
  void dispose();
}
