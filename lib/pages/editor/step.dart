import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pambe_ac_ifa/common/constants.dart';
import 'package:pambe_ac_ifa/components/field/form_array.dart';
import 'package:pambe_ac_ifa/components/field/text_input.dart';
import 'package:pambe_ac_ifa/pages/editor/components/step_number.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:pambe_ac_ifa/common/validation.dart';

enum RecipeStepEditorVariant {
  regular,
  tip,
  warning,
}

enum _RecipeStepEditorAction {
  addImage,
  addTimer,
  toTip,
  toWarning,
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
  final String? error;
  const _StepEditor(
      {required this.index,
      required this.value,
      required this.onChanged,
      this.error});

  Widget iconWithText(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AcColors.black),
        const SizedBox(
          width: AcSizes.space,
        ),
        Text(text),
      ],
    );
  }

  Widget buildTopActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        PopupMenuButton<_RecipeStepEditorAction>(
          icon: const Icon(Icons.more_horiz, color: AcColors.black),
          color: AcColors.white,
          onSelected: (_RecipeStepEditorAction action) {
            switch (action) {
              case _RecipeStepEditorAction.addImage:
              // TODO: Handle this case.
              case _RecipeStepEditorAction.addTimer:
              // TODO: Handle this case.
              case _RecipeStepEditorAction.toTip:
              // TODO: Handle this case.
              case _RecipeStepEditorAction.toWarning:
              // TODO: Handle this case.
            }
          },
          itemBuilder: (BuildContext context) {
            return <PopupMenuEntry<_RecipeStepEditorAction>>[
              PopupMenuItem(
                  value: _RecipeStepEditorAction.addImage,
                  child: iconWithText(Icons.add_photo_alternate, "Add Image")),
              PopupMenuItem(
                  value: _RecipeStepEditorAction.addTimer,
                  child: iconWithText(Icons.timer, "Add Timer")),
              const PopupMenuDivider(),
              PopupMenuItem(
                  value: _RecipeStepEditorAction.toTip,
                  child: iconWithText(Icons.error_outline, "Change to Tip")),
              PopupMenuItem(
                  value: _RecipeStepEditorAction.toWarning,
                  child:
                      iconWithText(Icons.warning_amber, "Change to Warning")),
            ];
          },
        ),
      ],
    );
  }

  void shiftFormItemUp(FormArrayController controller) {
    controller.mutate((formArray) {
      if (index == 0) return false;
      dynamic control = formArray.controls[index];
      formArray.removeAt(index);
      formArray.insert(index - 1, control);
      return true;
    });
  }

  void shiftFormItemDown(FormArrayController controller) {
    controller.mutate((formArray) {
      if (index == formArray.controls.length - 1) return false;
      dynamic control = formArray.controls[index];
      formArray.removeAt(index);
      formArray.insert(index + 1, control);
      return true;
    });
  }

  void removeFormItem(FormArrayController controller) {
    controller.mutate((formArray) {
      formArray.removeAt(index);
      return true;
    });
  }

  Widget buildBottomActions(BuildContext context) {
    final controller = FormArrayController.of(context);
    final formArray = controller.formArray;
    return Row(
      children: [
        IconButton(
            onPressed: index == 0 ? null : () => shiftFormItemUp(controller),
            icon: const Icon(Icons.keyboard_arrow_up)),
        IconButton(
            onPressed: index == formArray.controls.length - 1
                ? null
                : () => shiftFormItemDown(controller),
            icon: const Icon(Icons.keyboard_arrow_down)),
        const Spacer(),
        IconButton(
            onPressed: () => removeFormItem(controller),
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
              Padding(
                padding:
                    const EdgeInsets.only(left: AcSizes.lg, top: AcSizes.sm),
                child: Text(error!,
                    style: const TextStyle(
                        color: AcColors.danger, fontWeight: FontWeight.bold)),
              ),
            buildBottomActions(context),
          ],
        ));
  }
}

class RecipeStepEditor extends StatelessWidget {
  final int index;
  const RecipeStepEditor({super.key, required this.index});

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
