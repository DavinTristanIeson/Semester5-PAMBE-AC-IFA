import 'package:flutter/material.dart';

class User {
  String id;
  String name;
  String email;
  String onlineImage;
  User({
    required this.id,
    required this.name,
    required this.email,
    required this.onlineImage,
  });

  ImageProvider get image {
    return NetworkImage(onlineImage);
  }
}
