import 'package:flutter/foundation.dart';
import 'package:pambe_ac_ifa/database/interfaces/errors.dart';
import 'package:pambe_ac_ifa/database/interfaces/user.dart';
import 'package:pambe_ac_ifa/models/container.dart';
import 'package:pambe_ac_ifa/models/user.dart';

class UserController extends ChangeNotifier {
  final IUserResourceManager userManager;
  String? userId;
  UserController({required this.userManager, this.userId});

  Future<UserModel?> get(String userId) {
    return userManager.get(userId);
  }

  Future<UserModel?> getMe() {
    return userId == null ? Future.value(null) : userManager.get(userId!);
  }

  Future<UserModel> register(String userId, RegisterPayload payload) async {
    final result = await userManager.put(userId,
        email: Optional.some(payload.email),
        image: Optional.some(payload.image),
        bio: Optional.some(payload.bio),
        name: Optional.some(payload.name));
    notifyListeners();
    return result;
  }

  Future<UserModel> updateProfile(UserEditPayload payload) async {
    if (userId == null) {
      throw InvalidStateError(
          "UserController.userId should not be null when put is called.");
    }
    final result = await userManager.put(
      userId!,
      name: Optional.some(payload.name),
      bio: Optional.some(payload.bio),
      image: Optional.some(payload.image),
      birthdate: Optional.some(payload.birthdate),
      country: Optional.some(payload.country),
    );
    notifyListeners();
    return result;
  }

  Future<UserModel> updateEmail(String email) {
    if (userId == null) {
      throw InvalidStateError(
          "UserController.userId should not be null when updateEmail is called.");
    }
    return userManager.put(
      userId!,
      email: Optional.some(email),
    );
  }

  Future<void> remove({required LoginPayload credentials}) async {
    if (userId == null) {
      throw InvalidStateError(
          "UserController.userId should not be null when put is called.");
    }
    await userManager.remove(userId!);
    notifyListeners();
  }
}
