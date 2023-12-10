import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:localization/localization.dart';
import 'package:pambe_ac_ifa/common/constants.dart';
import 'package:pambe_ac_ifa/components/app/confirmation.dart';
import 'package:pambe_ac_ifa/components/app/touchable.dart';

class ImagePickerField extends StatelessWidget {
  static const _localePrefix = "components/field/image_picker";
  final _picker = ImagePicker();
  final XFile? value;
  final void Function(XFile? image) onChanged;
  final String? error;
  final BorderRadius? borderRadius;
  ImagePickerField(
      {super.key,
      required this.value,
      required this.onChanged,
      this.borderRadius,
      this.error});

  void pickImage(BuildContext context) async {
    showDialog(
        context: context,
        builder: (context) {
          return ImagePickMethodDialog(
            context: context,
            onPickSource: (source) async {
              XFile? result = await _picker.pickImage(
                  source: source, maxHeight: 600.0, maxWidth: 800.0);
              onChanged(result);
            },
          );
        });
  }

  Widget buildNoImage(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("$_localePrefix/choose_image".i18n(),
              style: TextStyle(
                color: Theme.of(context).colorScheme.tertiary,
                fontSize: AcSizes.fontLarge,
                fontWeight: FontWeight.bold,
              )),
          Icon(Icons.add_photo_alternate,
              size: 36.0, color: Theme.of(context).colorScheme.tertiary)
        ],
      ),
    );
  }

  Widget buildImageError(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.warning_amber,
              size: 36.0, color: Theme.of(context).colorScheme.error),
          Text(error!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: AcSizes.fontLarge,
                fontWeight: FontWeight.bold,
              )),
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
        color: error != null ? Colors.black54 : null,
        gradient: error != null
            ? null
            : LinearGradient(colors: [
                Theme.of(context).colorScheme.tertiary,
                Color.lerp(Theme.of(context).colorScheme.tertiary,
                    const Color.fromRGBO(0, 0, 0, 0.1), 0.2)!,
              ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
      ),
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height / 3),
      child: OverInkwell(
          onTap: () => pickImage(context),
          child: error != null
              ? buildImageError(context)
              : value == null
                  ? buildNoImage(context)
                  : buildImage(context)),
    );
  }
}
