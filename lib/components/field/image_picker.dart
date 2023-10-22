import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pambe_ac_ifa/common/constants.dart';
import 'package:pambe_ac_ifa/components/app/touchable.dart';

class ImagePickerField extends StatelessWidget {
  final _picker = ImagePicker();
  final XFile? value;
  final void Function(XFile? image) onChanged;
  final BorderRadius? borderRadius;
  ImagePickerField(
      {super.key,
      required this.value,
      required this.onChanged,
      this.borderRadius});

  void pickImage(BuildContext context) async {
    XFile? result = await _picker.pickImage(source: ImageSource.gallery);
    onChanged(result);
  }

  Widget buildNoImage(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Choose Image",
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontSize: AcSizes.fontLarge,
              )),
          Icon(Icons.add_photo_alternate,
              size: 36.0, color: Theme.of(context).colorScheme.secondary)
        ],
      ),
    );
  }

  Widget buildImage(BuildContext context) {
    return Image.file(
      File(value!.path),
      fit: BoxFit.cover,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? const BorderRadius.all(AcSizes.brInput),
        gradient: LinearGradient(colors: [
          Theme.of(context).colorScheme.tertiary,
          Color.lerp(Theme.of(context).colorScheme.tertiary,
              const Color.fromRGBO(0, 0, 0, 0.1), 0.2)!,
        ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
      ),
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height / 3),
      child: OverInkwell(
          onTap: () => pickImage(context),
          child: value == null ? buildNoImage(context) : buildImage(context)),
    );
  }
}
