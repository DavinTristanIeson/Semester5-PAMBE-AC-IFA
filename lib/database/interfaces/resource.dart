import 'dart:io';

import 'package:image_picker/image_picker.dart';

abstract class IImageResourceController {
  Future<File?> get(String imagePath);
  Future<File?> put(XFile? resource, {String? former});
  Future<void> remove(String imagePath);
}
