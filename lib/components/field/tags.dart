import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/common/constants.dart';
import 'package:pambe_ac_ifa/common/extensions.dart';
import 'package:pambe_ac_ifa/components/field/field_wrapper.dart';
import 'package:pambe_ac_ifa/components/field/text_input.dart';

class _Tag extends StatelessWidget {
  final void Function(String tag)? onDismiss;
  final String tag;
  const _Tag({this.onDismiss, required this.tag});

  static const tagRadius = Radius.circular(AcSizes.sm);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(tagRadius),
        color: context.colors.tertiary,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(tag),
          if (onDismiss != null)
            IconButton(
                onPressed: () => onDismiss!(tag), icon: const Icon(Icons.close))
        ],
      ),
    );
  }
}

class AcTagsInput extends StatelessWidget {
  final Set<String> value;
  final String label;
  final void Function(Set<String> tags) onChanged;
  final String? placeholder;
  final String? error;
  final bool required;
  final bool canMutate;
  const AcTagsInput(
      {super.key,
      required this.label,
      required this.onChanged,
      this.placeholder,
      this.error,
      this.required = false,
      this.canMutate = false,
      required this.value});

  void onDismiss(String tag) {
    if (canMutate) {
      value.remove(tag);
      onChanged(value);
    } else {
      onChanged(Set.from(value)..remove(tag));
    }
  }

  Widget buildTags(BuildContext context) {
    return Wrap(
      children: value
          .map((e) => Padding(
                padding: const EdgeInsets.all(AcSizes.xs),
                child: _Tag(
                  tag: e,
                  onDismiss: onDismiss,
                ),
              ))
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AcFieldWrapper(
      label: label,
      required: required,
      error: error,
      underLabel: buildTags(context),
      child: BoxTextInput(
        placeholder: placeholder,
        value: '',
        onChanged: null,
        onSubmitted: (controller, textValue) {
          final tag = processTag(textValue);
          controller.clear();
          if (value.contains(tag)) {
            return;
          }
          if (canMutate) {
            value.add(tag);
            onChanged(value);
          } else {
            onChanged({...value, tag});
          }
        },
      ),
    );
  }
}

String processTag(String value) {
  return value.trim().splitMapJoin(RegExp("\\s"),
      onMatch: (match) => '-', onNonMatch: (part) => part.toLowerCase());
}
