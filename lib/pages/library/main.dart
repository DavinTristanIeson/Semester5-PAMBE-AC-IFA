import 'package:flutter/material.dart';
import 'package:localization/localization.dart';
import 'package:pambe_ac_ifa/common/constants.dart';
import 'package:pambe_ac_ifa/common/extensions.dart';
import 'package:pambe_ac_ifa/pages/editor/main.dart';
import 'package:pambe_ac_ifa/pages/library/components/sections.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const EdgeInsets edgeInsets = EdgeInsets.only(
        left: AcSizes.space, right: AcSizes.space, bottom: AcSizes.lg);
    return Stack(
      children: [
        ListView(
          children: const [
            Padding(
              padding: edgeInsets,
              child: LibraryBookmarkedRecipesSection(),
            ),
            Padding(
              padding: edgeInsets,
              child: LibraryLocalRecipesSection(),
            ),
            SizedBox(
              height: AcSizes.xxl,
            ),
          ],
        ),
        Positioned(
          right: AcSizes.space,
          bottom: AcSizes.space,
          child: FloatingActionButton.extended(
            onPressed: () {
              context.navigator.push(MaterialPageRoute(
                  builder: (context) => const RecipeEditorScreen()));
            },
            icon: const Icon(Icons.add),
            label:  Text("screen/library/main/create_recipe".i18n()),
          ),
        )
      ],
    );
  }
}
