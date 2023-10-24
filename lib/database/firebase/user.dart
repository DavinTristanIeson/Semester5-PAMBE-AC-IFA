import 'package:pambe_ac_ifa/database/interfaces/resource.dart';
import 'package:pambe_ac_ifa/models/user.dart';

class FirebaseUserManager implements IUserController {
  @override
  Future<UserModel> getMe() async {
    return UserModel(
        id: "0",
        name: "User",
        email: "placeholder@email.com",
        imagePath: "https://www.google.com");
  }

  @override
  Future<UserModel> register(RegisterPayload payload) {
    // TODO: implement register
    throw UnimplementedError();
  }

  @override
  Future<UserModel> login(LoginPayload payload) {
    // TODO: implement login
    throw UnimplementedError();
  }
}
