import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/common/constants.dart';
import 'package:pambe_ac_ifa/common/extensions.dart';
import 'package:pambe_ac_ifa/components/field/field_wrapper.dart';
import 'package:pambe_ac_ifa/components/field/text_input.dart';

class TagWidget extends StatelessWidget {
  final void Function(String tag)? onDismiss;
  final String tag;
  const TagWidget({super.key, this.onDismiss, required this.tag});

  static const tagRadius = Radius.circular(AcSizes.sm + AcSizes.xs);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(tagRadius),
        color: context.colors.tertiary,
      ),
      child: Padding(
        padding: onDismiss != null
            ? const EdgeInsets.only(left: AcSizes.md)
            : const EdgeInsets.symmetric(
                vertical: AcSizes.xs, horizontal: AcSizes.md),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(tag),
            if (onDismiss != null)
              IconButton(
                  iconSize: AcSizes.lg,
                  onPressed: () => onDismiss!(tag),
                  icon: const Icon(Icons.close))
          ],
        ),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: AcSizes.md),
      child: Wrap(
        children: value
            .map((e) => Padding(
                  padding: const EdgeInsets.all(AcSizes.xs),
                  child: TagWidget(
                    tag: e,
                    onDismiss: onDismiss,
                  ),
                ))
            .toList(),
      ),
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
        onFocusChange: (controller, focus) {
          if (!focus.hasFocus) {
            controller.clear();
          }
        },
        onSubmitted: (controller, textValue) {
          final tag = processTag(textValue);
          controller.clear();
          if (value.contains(tag) || textValue.isEmpty) {
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
