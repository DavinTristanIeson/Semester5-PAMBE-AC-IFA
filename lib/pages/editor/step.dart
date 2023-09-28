import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pambe_ac_ifa/common/constants.dart';
import 'package:pambe_ac_ifa/components/field/text_input.dart';
import 'package:pambe_ac_ifa/pages/editor/components/step_number.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:pambe_ac_ifa/common/validation.dart';

enum RecipeStepEditorVariant {
  regular,
  tip,
  warning,
}

class RecipeStepFormType {
  RecipeStepEditorVariant variant;
  String? content;
  XFile? image;
  Duration? timer;
  RecipeStepFormType(this.variant, {this.content, this.image, this.timer});
  static FormGroup toFormGroup() {
    return FormGroup({
      "variant": FormControl<RecipeStepEditorVariant>(
          value: RecipeStepEditorVariant.regular),
      "content": FormControl<String?>(validators: [
        Validators.required,
      ]),
      "image": FormControl<XFile?>(),
      "duration": FormControl<Duration?>(),
    });
  }
}

class _StepEditor extends StatelessWidget {
  final int index;
  final String? value;
  final void Function(String?) onChanged;
  final void Function() onDelete;
  final String? error;
  const _StepEditor(
      {required this.index,
      required this.value,
      required this.onChanged,
      this.error,
      required this.onDelete});

  Widget buildTopActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(onPressed: () {}, icon: const Icon(Icons.more_horiz)),
      ],
    );
  }

  Widget buildBottomActions(BuildContext context) {
    return Row(
      children: [
        IconButton(onPressed: () {}, icon: const Icon(Icons.keyboard_arrow_up)),
        IconButton(
            onPressed: () {}, icon: const Icon(Icons.keyboard_arrow_down)),
        const Spacer(),
        IconButton(
            onPressed: onDelete,
            color: AcColors.danger,
            icon: const Icon(Icons.delete)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(AcSizes.brInput),
          color: Theme.of(context).colorScheme.surface,
        ),
        padding: const EdgeInsets.only(
          left: AcSizes.md,
          top: AcSizes.md,
          right: AcSizes.md,
          bottom: AcSizes.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildTopActions(),
            BoxTextInput(
                placeholder: "What should the cook do?",
                value: value,
                multiline: true,
                onChanged: onChanged),
            if (error != null)
              Text(error!,
                  style: const TextStyle(
                      color: AcColors.danger, fontWeight: FontWeight.bold)),
            buildBottomActions(context),
          ],
        ));
  }
}

class RecipeStepEditor extends StatelessWidget {
  final int index;
  final void Function() onDelete;
  const RecipeStepEditor(
      {super.key, required this.index, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          top: AcSizes.lg,
          right: AcSizes.lg,
          bottom: AcSizes.lg,
          left: AcSizes.lg - StepNumber.defaultDiameter / 4),
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.only(
                top: StepNumber.defaultDiameter / 2,
                left: StepNumber.defaultDiameter / 4),
            child: ReactiveValueListenableBuilder<String?>(
                formControlName: "content",
                builder: (context, control, child) {
                  return _StepEditor(
                      index: index,
                      value: control.value,
                      error: ReactiveFormConfig.of(context)
                          ?.translateAny(control.errors),
                      onDelete: onDelete,
                      onChanged: (value) {
                        control.value = value;
                      });
                }),
          ),
          Positioned(top: 0, left: 0, child: StepNumber(number: index + 1)),
        ],
      ),
    );
  }
}
