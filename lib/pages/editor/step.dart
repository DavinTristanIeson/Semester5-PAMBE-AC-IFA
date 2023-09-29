import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pambe_ac_ifa/common/constants.dart';
import 'package:pambe_ac_ifa/components/field/form_array.dart';
import 'package:pambe_ac_ifa/components/field/image_picker.dart';
import 'package:pambe_ac_ifa/components/field/text_input.dart';
import 'package:pambe_ac_ifa/models/recipe.dart';
import 'package:pambe_ac_ifa/pages/editor/components/step_number.dart';
import 'package:pambe_ac_ifa/pages/editor/components/timer.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:pambe_ac_ifa/common/validation.dart';

enum _RecipeStepEditorAction {
  toggleImage,
  toggleTimer,
  toTip,
  toWarning,
  toRegular,
}

class RecipeStepFormType {
  RecipeStepVariant variant;
  String? content;
  XFile? image;
  Duration? timer;
  RecipeStepFormType(this.variant, {this.content, this.image, this.timer});
  static FormGroup toFormGroup() {
    return FormGroup({
      "variant":
          FormControl<RecipeStepVariant>(value: RecipeStepVariant.regular),
      "content": FormControl<String?>(validators: [
        Validators.required,
      ]),
      "thumbnail": FormControl<InputToggle<XFile>>(value: InputToggle.off()),
      "timer": FormControl<InputToggle<Duration>>(value: InputToggle.off()),
    });
  }
}

class _RecipeStepEditorInternal extends StatelessWidget {
  const _RecipeStepEditorInternal();

  Widget buildContentInput() {
    return ReactiveValueListenableBuilder<String?>(
        formControlName: "content",
        builder: (context, control, child) {
          String? error =
              ReactiveFormConfig.of(context)!.translateAny(control.errors);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BoxTextInput(
                  placeholder: "What should the cook do?",
                  value: control.value,
                  multiline: true,
                  onChanged: (value) {
                    control.value = value;
                  }),
              if (error != null)
                Padding(
                  padding:
                      const EdgeInsets.only(left: AcSizes.lg, top: AcSizes.sm),
                  child: Text(error,
                      style: const TextStyle(
                          color: AcColors.danger, fontWeight: FontWeight.bold)),
                ),
            ],
          );
        });
  }

  Widget buildThumbnail() {
    return ReactiveValueListenableBuilder<InputToggle<XFile>>(
        formControlName: "thumbnail",
        builder: (context, control, child) {
          if (control.value == null || !control.value!.toggle) {
            return const SizedBox.shrink();
          }
          return Padding(
            padding: const EdgeInsets.only(bottom: AcSizes.md),
            child: ImagePickerField(
                value: control.value?.value,
                onChanged: (XFile? value) {
                  control.value = control.value?.withValue(value);
                }),
          );
        });
  }

  Widget buildTimer() {
    return ReactiveValueListenableBuilder<InputToggle<Duration>>(
        formControlName: "timer",
        builder: (context, control, child) {
          if (control.value == null || !control.value!.toggle) {
            return const SizedBox.shrink();
          }
          return Padding(
            padding: const EdgeInsets.only(bottom: AcSizes.md),
            child: TimerField(
                value: control.value?.value,
                onChanged: (value) {
                  control.value = control.value?.withValue(value);
                }),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        buildThumbnail(),
        buildTimer(),
        buildContentInput(),
      ],
    );
  }
}

class _RecipeStepEditorMenuButton extends StatelessWidget {
  const _RecipeStepEditorMenuButton();

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

  @override
  Widget build(BuildContext context) {
    final form = ReactiveForm.of(context, listen: true) as FormGroup;
    final thumbnailControl =
        form.controls["thumbnail"] as FormControl<InputToggle<XFile>>;
    final timerControl =
        form.controls["timer"] as FormControl<InputToggle<Duration>>;
    final variantControl =
        form.controls["variant"] as FormControl<RecipeStepVariant>;
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        PopupMenuButton<_RecipeStepEditorAction>(
          icon: const Icon(Icons.more_horiz, color: AcColors.black),
          color: AcColors.white,
          onSelected: (_RecipeStepEditorAction action) {
            switch (action) {
              case _RecipeStepEditorAction.toggleImage:
                thumbnailControl.value = thumbnailControl.value?.toggled();
              case _RecipeStepEditorAction.toggleTimer:
                timerControl.value = timerControl.value?.toggled();
              case _RecipeStepEditorAction.toTip:
                variantControl.value = RecipeStepVariant.tip;
              case _RecipeStepEditorAction.toWarning:
                variantControl.value = RecipeStepVariant.warning;
              case _RecipeStepEditorAction.toRegular:
                variantControl.value = RecipeStepVariant.regular;
            }
          },
          itemBuilder: (BuildContext context) {
            return <PopupMenuEntry<_RecipeStepEditorAction>>[
              PopupMenuItem(
                  value: _RecipeStepEditorAction.toggleImage,
                  child: iconWithText(
                      Icons.add_photo_alternate,
                      thumbnailControl.value!.toggle
                          ? "Remove Image"
                          : "Add Image")),
              PopupMenuItem(
                  value: _RecipeStepEditorAction.toggleTimer,
                  child: iconWithText(
                      Icons.timer,
                      timerControl.value!.toggle
                          ? "Remove Timer"
                          : "Add Timer")),
              const PopupMenuDivider(),
              if (variantControl.value != RecipeStepVariant.regular)
                PopupMenuItem(
                    value: _RecipeStepEditorAction.toRegular,
                    child:
                        iconWithText(Icons.chat_bubble, "Change to Regular")),
              if (variantControl.value != RecipeStepVariant.tip)
                PopupMenuItem(
                    value: _RecipeStepEditorAction.toTip,
                    child: iconWithText(Icons.error_outline, "Change to Tip")),
              if (variantControl.value != RecipeStepVariant.warning)
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
}

class _RecipeStepEditorFieldWrapper extends StatelessWidget {
  final int index;
  const _RecipeStepEditorFieldWrapper({required this.index});

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
    final form = ReactiveForm.of(context, listen: true) as FormGroup;
    final variantControl =
        form.controls["variant"] as FormControl<RecipeStepVariant>;
    return Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(AcSizes.brInput),
          color: variantControl.value?.backgroundColor ??
              RecipeStepVariant.regular.backgroundColor,
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
            const _RecipeStepEditorMenuButton(),
            const _RecipeStepEditorInternal(),
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
            child: _RecipeStepEditorFieldWrapper(index: index),
          ),
          Positioned(
              top: 0,
              left: 0,
              child: ReactiveValueListenableBuilder<RecipeStepVariant>(
                  formControlName: "variant",
                  builder: (context, control, child) {
                    return StepNumber(
                      number: index + 1,
                      variant: control.value ?? RecipeStepVariant.regular,
                    );
                  })),
        ],
      ),
    );
  }
}
