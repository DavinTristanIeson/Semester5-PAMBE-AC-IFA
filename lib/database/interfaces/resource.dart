import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pambe_ac_ifa/models/user.dart';

typedef LoginPayload = ({String email, String password});
typedef RegisterPayload = ({
  String email,
  String password,
  String name,
  String? bio,
  XFile? image,
});

abstract class IImageResourceManager {
  Future<File?> get(String imagePath);
  Future<File?> put(XFile? resource, {String? former});
  Future<void> remove(String imagePath);
}

abstract class IUserResourceManager {
  Future<UserCredential> login(LoginPayload payload);
  Future<UserCredential> register(RegisterPayload payload);
  Future<UserCredential> getMe();
}
