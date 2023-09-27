import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/common/constants.dart';
import 'package:pambe_ac_ifa/components/field/field_wrapper.dart';

class AcTextInput extends StatefulWidget {
  final String value;
  final void Function(String?) onChanged;
  final String label;
  final String? error;
  final bool required;
  final String? placeholder;
  const AcTextInput(
      {super.key,
      required this.value,
      required this.onChanged,
      required this.label,
      this.error,
      this.placeholder,
      this.required = false});

  @override
  State<AcTextInput> createState() => _AcTextInputState();
}

class _AcTextInputState extends State<AcTextInput> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  OutlineInputBorder createInputBorder(Color color) {
    return OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(AcSizes.brInput)),
        borderSide: BorderSide(
          color: color,
          width: AcSizes.xs,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return AcFieldWrapper(
        label: widget.label,
        error: widget.error,
        required: widget.required,
        child: TextField(
          decoration: AcInputBorderFactory(context, AcInputBorderType.outline)
              .decorate(InputDecoration(
                  fillColor: AcColors.white,
                  filled: true,
                  hintText: widget.placeholder,
                  hintStyle: AcTypography.placeholder)),
          controller: _controller,
          onChanged: widget.onChanged,
        ));
  }
}

enum AcInputBorderType {
  outline,
  underline,
}

class AcInputBorderFactory {
  BuildContext context;
  AcInputBorderType type;
  AcInputBorderFactory(this.context, this.type);

  OutlineInputBorder createOutlineInputBorder(Color color) {
    return OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(AcSizes.brInput)),
        borderSide: BorderSide(
          color: color,
          width: AcSizes.xs,
        ));
  }

  UnderlineInputBorder createUnderlineInputBorder(Color color) {
    return UnderlineInputBorder(
        borderSide: BorderSide(
      color: color,
      width: AcSizes.xs,
    ));
  }

  InputDecoration decorate(InputDecoration? decoration) {
    if (decoration == null) {
      return InputDecoration(
        enabledBorder: enabledBorder,
        errorBorder: errorBorder,
        disabledBorder: disabledBorder,
        focusedBorder: focusedBorder,
      );
    }
    return decoration.copyWith(
      enabledBorder: enabledBorder,
      errorBorder: errorBorder,
      disabledBorder: disabledBorder,
      focusedBorder: focusedBorder,
    );
  }

  InputBorder createInputBorder(Color color) {
    return type == AcInputBorderType.outline
        ? createOutlineInputBorder(color)
        : createUnderlineInputBorder(color);
  }

  InputBorder get enabledBorder => createInputBorder(Colors.black);
  InputBorder get disabledBorder =>
      createInputBorder(Theme.of(context).colorScheme.tertiary);
  InputBorder get errorBorder =>
      createInputBorder(Theme.of(context).colorScheme.error);
  InputBorder get focusedBorder =>
      createInputBorder(Theme.of(context).colorScheme.primary);
}
