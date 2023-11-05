import 'package:flutter/material.dart';
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

  Widget buildLocation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.pin_drop,
          color: Color.fromARGB(255, 255, 159, 42),
        ),
        const SizedBox(
          width: 5,
        ),
        Text(
          widget.user.country!,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color.fromARGB(255, 255, 159, 42),
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
            label: const Text("Edit Profile")),
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
            label: const Text("Edit Credentials")),
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
          Text(
            widget.user.name,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: context.colors.primary,
            ),
          ),
          Text(
            widget.user.email,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: context.colors.primary,
            ),
          ),
          if (widget.user.country != null) buildLocation(),
          if (widget.user.birthdate != null)
            TextItem(
                firstText: "Date of Birth",
                secondText: widget.user.birthdate!.toLocaleString()),
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
                  : const UserRecipesSection()),
        ],
      ),
    );
  }
}
