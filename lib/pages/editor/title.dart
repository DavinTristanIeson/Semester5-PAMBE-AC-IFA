import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pambe_ac_ifa/common/constants.dart';
import 'package:pambe_ac_ifa/components/app/touchable.dart';
import 'package:pambe_ac_ifa/components/field/field_wrapper.dart';
import 'package:pambe_ac_ifa/components/field/text_input.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:pambe_ac_ifa/common/validation.dart';

class _TitleEditorImageChooser extends StatelessWidget {
  final _picker = ImagePicker();
  final XFile? image;
  final void Function(XFile? image) onPickImage;
  _TitleEditorImageChooser({required this.image, required this.onPickImage});

  void pickImage(BuildContext context) async {
    XFile? result = await _picker.pickImage(source: ImageSource.gallery);
    onPickImage(result);
  }

  Widget buildNoImage(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Choose Image",
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontSize: AcSizes.fontBig,
              )),
          Icon(Icons.add_photo_alternate,
              size: 36.0, color: Theme.of(context).colorScheme.secondary)
        ],
      ),
    );
  }

  Widget buildImage(BuildContext context) {
    return Image.file(
      File(image!.path),
      fit: BoxFit.cover,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: AcSizes.brInput,
          topRight: AcSizes.brInput,
        ),
        gradient: LinearGradient(colors: [
          Theme.of(context).colorScheme.tertiary,
          Color.lerp(Theme.of(context).colorScheme.tertiary,
              const Color.fromRGBO(0, 0, 0, 0.1), 0.2)!,
        ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
      ),
      constraints: const BoxConstraints(maxHeight: 300.0),
      child: OverInkwell(
          onTap: () => pickImage(context),
          child: image == null ? buildNoImage(context) : buildImage(context)),
    );
  }
}

class _TitleEditorTitleField extends StatefulWidget {
  final String? value;
  final void Function(String?) onChanged;
  final String? error;
  const _TitleEditorTitleField(
      {required this.value, required this.onChanged, this.error});

  @override
  State<_TitleEditorTitleField> createState() => _TitleEditorTitleFieldState();
}

class _TitleEditorTitleFieldState extends State<_TitleEditorTitleField> {
  late final TextEditingController _control;

  @override
  void initState() {
    super.initState();
    _control = TextEditingController(text: widget.value);
  }

  @override
  void dispose() {
    super.dispose();
    _control.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var factory = AcInputBorderFactory(context, AcInputBorderType.underline);
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: const BorderRadius.only(
            bottomLeft: AcSizes.brInput,
            bottomRight: AcSizes.brInput,
          )),
      padding: const EdgeInsets.all(AcSizes.md),
      child: TextField(
        cursorColor: Colors.black,
        decoration: factory.decorate(null).copyWith(
            focusedBorder: const UnderlineInputBorder(
                borderSide:
                    BorderSide(color: Colors.black, width: AcSizes.xs + 0.5)),
            hintText: "Title",
            error: widget.error != null ? Text(widget.error!) : null,
            hintStyle: AcTypography.placeholder),
        controller: _control,
        onChanged: widget.onChanged,
      ),
    );
  }
}

class RecipeDetailsEditor extends StatelessWidget {
  const RecipeDetailsEditor({super.key});

  Widget buildDescriptionField() {
    return ReactiveValueListenableBuilder<String>(
        formControlName: "description",
        builder: (context, control, child) {
          return AcTextInput(
              value: control.value ?? '',
              error:
                  ReactiveFormConfig.of(context)?.translateAny(control.errors),
              onChanged: (String? value) {
                control.value = value ?? '';
              },
              label: "Description",
              placeholder: "Describe your recipe!",
              required: true);
        });
  }

  Widget buildTitleEditor() {
    return Column(
      children: [
        ReactiveValueListenableBuilder<XFile?>(
            formControlName: "thumbnail",
            builder: (context, control, child) {
              return _TitleEditorImageChooser(
                  image: control.value,
                  onPickImage: (image) {
                    control.value = image;
                  });
            }),
        ReactiveValueListenableBuilder<String?>(
          formControlName: "title",
          builder: (context, control, child) {
            return _TitleEditorTitleField(
                value: control.value,
                error: ReactiveFormConfig.of(context)!
                    .translateAny(control.errors),
                onChanged: (value) {
                  control.value = value;
                });
          },
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        constraints: const BoxConstraints(maxWidth: 1024.0),
        padding: const EdgeInsets.all(AcSizes.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            buildTitleEditor(),
            const SizedBox(
              height: AcSizes.space,
            ),
            buildDescriptionField(),
          ],
        ));
  }
}
