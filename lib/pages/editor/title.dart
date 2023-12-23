import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:localization/localization.dart';
import 'package:pambe_ac_ifa/common/constants.dart';
import 'package:pambe_ac_ifa/components/field/field_wrapper.dart';
import 'package:pambe_ac_ifa/components/field/image_picker.dart';
import 'package:pambe_ac_ifa/components/field/text_input.dart';
import 'package:pambe_ac_ifa/pages/editor/components/models.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:pambe_ac_ifa/common/validation.dart';

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
            hintText: "screen/editor/title/title".i18n(),
            error: widget.error != null
                ? Text(widget.error!, style: AcTypography.errorRegular)
                : null,
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
    return ReactiveValueListenableBuilder<String?>(
        formControlName: RecipeFormKeys.description.name,
        builder: (context, control, child) {
          return AcTextInput(
              value: control.value ?? '',
              error:
                  ReactiveFormConfig.of(context)?.translateAny(control.errors),
              onChanged: (String? value) {
                control.value = value ?? '';
              },
              label: "screen/editor/title/description".i18n(),
              placeholder: "screen/editor/title/description_extra".i18n(),
              multiline: true,
              required: true);
        });
  }

  Widget buildTitleEditor() {
    return Column(
      children: [
        ReactiveValueListenableBuilder<XFile?>(
            formControlName: RecipeFormKeys.image.name,
            builder: (context, control, child) {
              return ImagePickerField(
                  value: control.value,
                  borderRadius: const BorderRadius.only(
                      topLeft: AcSizes.brInput, topRight: AcSizes.brInput),
                  onChanged: (image) {
                    control.value = image;
                    control.markAsDirty();
                  });
            }),
        ReactiveValueListenableBuilder<String?>(
          formControlName: RecipeFormKeys.title.name,
          builder: (context, control, child) {
            return _TitleEditorTitleField(
                value: control.value,
                error: ReactiveFormConfig.of(context)!
                    .translateAny(control.errors),
                onChanged: (value) {
                  control.value = value;
                  control.markAsDirty();
                });
          },
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
