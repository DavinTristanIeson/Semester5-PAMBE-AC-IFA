import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/common/constants.dart';
import 'package:pambe_ac_ifa/common/extensions.dart';
import 'package:pambe_ac_ifa/common/validation.dart';
import 'package:pambe_ac_ifa/components/display/future.dart';
import 'package:pambe_ac_ifa/components/field/text_input.dart';
import 'package:pambe_ac_ifa/components/function/wrapper.dart';
import 'package:reactive_forms/reactive_forms.dart';

class LoginSubmitButton extends StatelessWidget {
  final Future<void> Function() onPressed;
  final String label;
  const LoginSubmitButton(
      {super.key, required this.onPressed, required this.label});

  @override
  Widget build(BuildContext context) {
    final form = ReactiveForm.of(context, listen: true)!;
    return Padding(
      padding: const EdgeInsets.only(top: AcSizes.md, bottom: AcSizes.space),
      child: Wrapper(
        wrapper: (context, child) {
          return Tooltip(
            message: "There are errors in the form",
            textStyle: context.texts.labelMedium,
            decoration: BoxDecoration(color: context.colors.errorContainer),
            child: child,
          );
        },
        shouldWrap: form.hasErrors,
        child: FutureButton(
            onPressed: form.hasErrors ? null : onPressed, child: Text(label)),
      ),
    );
  }
}

Widget buildGenericTextInput(
    {required String name,
    required String label,
    bool? required,
    bool? obscureText,
    bool? multiline,
    String? placeholder,
    EdgeInsets? padding}) {
  return Padding(
    padding: padding ??
        const EdgeInsets.symmetric(
            vertical: AcSizes.md, horizontal: AcSizes.space),
    child: ReactiveValueListenableBuilder<String?>(
        formControlName: name,
        builder: (context, control, child) {
          return AcTextInput(
              value: control.value,
              onChanged: (value) {
                control.value = value;
                control.markAsDirty();
              },
              error:
                  ReactiveFormConfig.of(context)?.translateAny(control.errors),
              placeholder: placeholder,
              multiline: multiline ?? false,
              required: required ?? false,
              obscureText: obscureText ?? false,
              label: label);
        }),
  );
}
