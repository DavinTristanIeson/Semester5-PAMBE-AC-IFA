import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/common/constants.dart';

class OnlyReturnAppBar extends StatelessWidget implements PreferredSizeWidget {
  final List<Widget>? actions;
  const OnlyReturnAppBar({super.key, this.actions});
  @override
  Size get preferredSize {
    return const Size.fromHeight(kToolbarHeight * 2);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> appBarChildren = [
      ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.tertiary,
            foregroundColor: Colors.black,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.chevron_left),
          label: const Text("Back")),
    ];
    if (actions != null) {
      appBarChildren.add(const Spacer());
      appBarChildren.addAll(actions!);
    }
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AcSizes.lg, vertical: AcSizes.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: appBarChildren,
      ),
    );
  }
}
