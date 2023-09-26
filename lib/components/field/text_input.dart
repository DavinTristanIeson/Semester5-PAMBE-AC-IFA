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
          decoration: InputDecoration(
            enabledBorder: createInputBorder(Colors.black),
            disabledBorder:
                createInputBorder(Theme.of(context).colorScheme.tertiary),
            errorBorder: createInputBorder(Theme.of(context).colorScheme.error),
            focusedBorder:
                createInputBorder(Theme.of(context).colorScheme.primary),
            fillColor: AcColors.white,
            filled: true,
          ),
          controller: _controller,
          onChanged: widget.onChanged,
        ));
  }
}
