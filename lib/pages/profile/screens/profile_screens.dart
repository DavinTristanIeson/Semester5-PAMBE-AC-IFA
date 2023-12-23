import 'package:flutter/material.dart';
import 'package:localization/localization.dart';
import 'package:pambe_ac_ifa/common/constants.dart';
import 'package:pambe_ac_ifa/common/extensions.dart';
import 'package:pambe_ac_ifa/components/display/image.dart';
import 'package:pambe_ac_ifa/models/user.dart';
import 'package:pambe_ac_ifa/pages/profile/components/text.dart';
import 'package:pambe_ac_ifa/pages/profile/screens/change_auth_screen.dart';
import 'package:pambe_ac_ifa/pages/profile/screens/edit_profile_screen.dart';
import 'package:pambe_ac_ifa/pages/profile/components/user_recipes_section.dart';

class ProfileScreenBody extends StatefulWidget {
  final UserModel user;
  final bool? editable;
  const ProfileScreenBody({super.key, required this.user, this.editable});

  @override
  State<ProfileScreenBody> createState() => _ProfileScreenBodyState();
}

class _ProfileScreenBodyState extends State<ProfileScreenBody> {
  Widget buildProfileOnboard() {
    final imagePath = widget.user.imagePath;
    return Padding(
      padding: const EdgeInsets.only(top: AcSizes.space, bottom: AcSizes.xl),
      child: Center(
        child: CircleAvatar(
          radius: context.relativeWidth(0.25, 60.0, 120.0),
          foregroundImage: (imagePath != null
                  ? NetworkImage(imagePath)
                  : const AssetImage(MaybeImage.userFallbackImagePath))
              as ImageProvider,
        ),
      ),
    );
  }

  Widget buildLocation(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.pin_drop,
          color: context.colors.primary,
        ),
        const SizedBox(
          width: AcSizes.sm,
        ),
        Text(
          widget.user.country!,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: context.colors.primary,
          ),
        ),
      ],
    );
  }

  Widget buildActions(BuildContext context) {
    final buttonStyle = OutlinedButton.styleFrom(
        foregroundColor: context.colors.primary,
        side: BorderSide(color: context.colors.primary));
    return Column(
      children: [
        OutlinedButton.icon(
            style: buttonStyle,
            onPressed: () {
              context.navigator.push(
                MaterialPageRoute(
                    builder: (context) => EditProfileScreen(
                          data: widget.user,
                        )),
              );
            },
            icon: const Icon(Icons.edit),
            label:  Text("screen/profile/screens/profile_screens/edit_profile".i18n())),
        const SizedBox(
          height: AcSizes.md,
        ),
        OutlinedButton.icon(
            style: buttonStyle,
            onPressed: () {
              context.navigator.push(
                MaterialPageRoute(
                    builder: (context) => const ChangeAuthScreen()),
              );
            },
            icon: const Icon(Icons.email_outlined),
            label:  Text("screen/profile/screens/profile_screens/edit_credentials".i18n())),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final editable = widget.editable != null && widget.editable!;
    return SingleChildScrollView(
      child: Column(
        children: [
          buildProfileOnboard(),
          TextItem(firstText: widget.user.name, secondText: widget.user.email),
          if (widget.user.country != null)
            Padding(
              padding:
                  const EdgeInsets.only(top: AcSizes.space, bottom: AcSizes.md),
              child: buildLocation(context),
            ),
          if (widget.user.birthdate != null)
            Padding(
              padding:
                  const EdgeInsets.only(top: AcSizes.space, bottom: AcSizes.md),
              child: TextItem(
                  firstText: "screen/profile/screens/edit_profile_screen/date_of_birth".i18n(),
                  secondText: widget.user.birthdate!.toLocaleDateString()),
            ),
          const SizedBox(
            height: AcSizes.space,
          ),
          if (editable) buildActions(context),
          const SizedBox(
            height: AcSizes.xl,
          ),
          Padding(
              padding: const EdgeInsets.all(AcSizes.space),
              child: editable
                  ? const LocalUserRecipesSection()
                  : UserRecipesSection(userId: widget.user.id)),
        ],
      ),
    );
  }
}
