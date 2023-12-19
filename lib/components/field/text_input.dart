import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/common/constants.dart';
import 'package:pambe_ac_ifa/components/field/field_wrapper.dart';

class TextFieldValueProvider extends StatefulWidget {
  final String? value;
  final Widget Function(BuildContext context, TextEditingController controller)
      builder;
  const TextFieldValueProvider(
      {super.key, required this.builder, required this.value});

  @override
  State<TextFieldValueProvider> createState() => _TextFieldValueProviderState();
}

class _TextFieldValueProviderState extends State<TextFieldValueProvider> {
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

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _controller);
  }
}

class BoxTextInput extends StatelessWidget {
  final String? placeholder;
  final String? value;
  final void Function(TextEditingController controller, String? value)?
      onChanged;
  final void Function(TextEditingController controller, String value)?
      onSubmitted;
  final bool multiline;
  final bool obscureText;
  const BoxTextInput({
    super.key,
    required this.placeholder,
    required this.value,
    required this.onChanged,
    this.multiline = false,
    this.obscureText = false,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextFieldValueProvider(
      value: value,
      builder: (context, controller) => TextField(
        decoration: AcInputBorderFactory(context, AcInputBorderType.outline)
            .decorate(InputDecoration(
                fillColor: AcColors.white,
                filled: true,
                hintText: placeholder,
                hintStyle: AcTypography.placeholder)),
        controller: controller,
        obscureText: obscureText,
        maxLines: multiline ? null : 1,
        minLines: multiline ? 4 : null,
        onChanged: (value) => onChanged?.call(controller, value),
        onSubmitted: (value) => onSubmitted?.call(controller, value),
      ),
    );
  }
}

class AcTextInput extends StatelessWidget {
  final String label;
  final String? error;
  final bool required;
  final String? placeholder;
  final String? value;
  final bool multiline;
  final bool obscureText;
  final void Function(String?) onChanged;
  const AcTextInput(
      {super.key,
      required this.value,
      required this.onChanged,
      required this.label,
      this.error,
      this.placeholder,
      this.multiline = true,
      this.required = false,
      this.obscureText = false});

  @override
  Widget build(BuildContext context) {
    return AcFieldWrapper(
        label: label,
        error: error,
        required: required,
        child: BoxTextInput(
          value: value,
          placeholder: placeholder,
          onChanged: (controller, value) => onChanged(value),
          multiline: multiline,
          obscureText: obscureText,
        ));
  }
}
