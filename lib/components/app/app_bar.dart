import 'package:flutter/material.dart';
import 'package:localization/localization.dart';
import 'package:pambe_ac_ifa/common/constants.dart';

class OnlyReturnAppBar extends StatelessWidget implements PreferredSizeWidget {
  final List<Widget>? actions;
  const OnlyReturnAppBar({super.key, this.actions});
  @override
  Size get preferredSize {
    return const Size.fromHeight(kToolbarHeight * 2);
  }

  static Widget buildBackButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AcSizes.space),
      child: Row(
        children: [
          ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.tertiary,
                foregroundColor: Colors.black,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.chevron_left),
              label: Text("common/back".i18n()))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> appBarChildren = [
      buildBackButton(context),
    ];
    if (actions != null) {
      appBarChildren.add(const Spacer());
      appBarChildren.addAll(actions!);
    }
    return Padding(
      padding: const EdgeInsets.only(
          left: AcSizes.lg,
          right: AcSizes.lg,
          top: AcSizes.xl + AcSizes.md,
          bottom: AcSizes.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: appBarChildren,
      ),
    );
  }
}
