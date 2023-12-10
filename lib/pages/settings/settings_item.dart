import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/common/constants.dart';
import 'package:pambe_ac_ifa/common/extensions.dart';
import 'package:pambe_ac_ifa/components/function/future.dart';
import 'package:pambe_ac_ifa/models/container.dart';

class SettingsItemToggle extends StatelessWidget {
  final Either<Widget, String> title;
  final Either<Widget, String>? subtitle;
  final bool value;
  final Future<void> Function(bool value) onChanged;
  const SettingsItemToggle(
      {super.key,
      required this.title,
      required this.onChanged,
      required this.subtitle,
      required this.value});

  @override
  Widget build(BuildContext context) {
    return FutureButtonCompute<bool>(
        onPressedWithArgs: onChanged,
        builder: (context, remote) {
          return SwitchListTile(
            value: value,
            onChanged: remote.callArgs,
            title: title.leftOr((right) => Text(
                  right,
                  style: context.texts.titleLarge,
                )),
            subtitle: subtitle?.leftOr((right) => Text(
                  right,
                  style: context.texts.titleMedium,
                )),
          );
        });
  }
}

class SettingsItemSelect extends StatelessWidget {
  final Either<Widget, String> title;
  final Either<Widget, String>? subtitle;
  final String? value;
  final Future<void> Function(String? value) onChanged;
  final List<({String label, String value})> options;
  const SettingsItemSelect(
      {super.key,
      required this.title,
      required this.onChanged,
      required this.subtitle,
      required this.value,
      required this.options});
  @override
  Widget build(BuildContext context) {
    return FutureButtonCompute<String?>(
        onPressedWithArgs: onChanged,
        builder: (context, remote) {
          return Padding(
            padding: const EdgeInsets.symmetric(
                vertical: AcSizes.sm, horizontal: AcSizes.space),
            child: ListTile(
              tileColor: context.colors.surface,
              title: title.leftOr((right) => Text(
                    right,
                    style: context.texts.titleMedium,
                  )),
              subtitle: subtitle?.leftOr((right) => Text(
                    right,
                    style: context.texts.bodyMedium,
                  )),
              trailing: remote.isLoading
                  ? remote.icon
                  : DropdownButton(
                      value: value,
                      dropdownColor: context.colors.surface,
                      items: options
                          .map((e) => DropdownMenuItem(
                                value: e.value,
                                child: Text(e.label),
                              ))
                          .toList(),
                      onChanged: remote.callArgs),
            ),
          );
        });
  }
}
