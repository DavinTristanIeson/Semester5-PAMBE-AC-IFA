import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:localization/localization.dart';
import 'package:pambe_ac_ifa/common/constants.dart';
import 'package:pambe_ac_ifa/common/extensions.dart';
import 'package:pambe_ac_ifa/common/validation.dart';
import 'package:pambe_ac_ifa/components/app/app_bar.dart';
import 'package:pambe_ac_ifa/components/app/confirmation.dart';
import 'package:pambe_ac_ifa/components/app/snackbar.dart';
import 'package:pambe_ac_ifa/components/display/image.dart';
import 'package:pambe_ac_ifa/components/field/field_wrapper.dart';
import 'package:pambe_ac_ifa/controllers/user.dart';
import 'package:pambe_ac_ifa/models/container.dart';
import 'package:pambe_ac_ifa/models/user.dart';
import 'package:pambe_ac_ifa/pages/login/components/actions.dart';
import 'package:pambe_ac_ifa/pages/profile/components/country_select.dart';
import 'package:provider/provider.dart';
import 'package:reactive_forms/reactive_forms.dart';

enum _EditProfileFormKeys {
  image,
  name,
  bio,
  country,
  birthdate,
}

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({
    super.key,
    required this.data,
  });
  final UserModel data;
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

typedef UserAvatarFormType = Either<String?, XFile?>;

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final FormGroup form;

  @override
  void initState() {
    super.initState();
    form = FormGroup({
      _EditProfileFormKeys.image.name: FormControl<UserAvatarFormType>(
        value: widget.data.imagePath == null
            ? Either.right(null)
            : Either.left(widget.data.imagePath!),
      ),
      _EditProfileFormKeys.name.name: FormControl<String>(
          value: widget.data.name,
          validators: [Validators.minLength(5), AcValidators.acceptedChars]),
      _EditProfileFormKeys.bio.name: FormControl<String?>(
        value: widget.data.bio,
      ),
      _EditProfileFormKeys.birthdate.name: FormControl<DateTime?>(
        value: widget.data.birthdate,
      ),
      _EditProfileFormKeys.country.name: FormControl<String?>(
        value: widget.data.country,
      ),
    });
  }

  @override
  void dispose() {
    form.dispose();
    super.dispose();
  }

  void save() async {
    final messenger = AcSnackbarMessenger.of(context);
    if (form.invalid) {
      messenger.sendError("screen/profile/screens/edit_profile_screen/resolve_all_error".i18n());
      return;
    }
    final userController = context.read<UserController>();
    try {
      final value = form.value;
      final image =
          (value[_EditProfileFormKeys.image.name] as UserAvatarFormType);
      await userController.updateProfile((
        name: value[_EditProfileFormKeys.name.name] as String,
        image: image.hasLeft ? Optional.none() : Optional.some(image.right),
        country: value[_EditProfileFormKeys.country.name] as String?,
        birthdate: value[_EditProfileFormKeys.birthdate.name] as DateTime?,
        bio: value[_EditProfileFormKeys.bio.name] as String?,
      ));
      messenger.sendSuccess("screen/profile/screens/edit_profile_screen/profile_updated".i18n());
    } catch (e) {
      messenger.sendError(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const OnlyReturnAppBar(),
        body: ReactiveForm(
          formGroup: form,
          child: EditProfileScreenBody(
            onSave: save,
          ),
        ));
  }
}

class EditProfileScreenBody extends StatelessWidget {
  final ImagePicker _picker = ImagePicker();
  final void Function() onSave;
  EditProfileScreenBody({super.key, required this.onSave});

  Widget buildBirthdateInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(
          vertical: AcSizes.md, horizontal: AcSizes.space),
      child: ReactiveValueListenableBuilder(
          formControlName: _EditProfileFormKeys.birthdate.name,
          builder: (context, control, child) {
            final value = control.value as DateTime?;
            return AcFieldWrapper(
                label: "screen/profile/screens/edit_profile_screen/date_of_birth".i18n(),
                error: ReactiveFormConfig.of(context)
                    ?.translateAny(control.errors),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                          onPressed: () async {
                            control.value = await showCalender(context, value);
                          },
                          icon: const Icon(Icons.calendar_month),
                          label: Text(
                            value == null
                                ? 'No birthdate'
                                : value.toLocaleDateString(),
                            style: TextStyle(
                              fontStyle:
                                  value == null ? null : FontStyle.italic,
                            ),
                          )),
                    ),
                  ],
                ));
          }),
    );
  }

  Widget buildCountrySelect() {
    return Padding(
      padding: const EdgeInsets.symmetric(
          vertical: AcSizes.md, horizontal: AcSizes.space),
      child: ReactiveValueListenableBuilder(
          formControlName: _EditProfileFormKeys.country.name,
          builder: (context, control, child) {
            return CountrySelect(
              error:
                  ReactiveFormConfig.of(context)?.translateAny(control.errors),
              label: "screen/profile/screens/edit_profile_screen/country_region".i18n(),
              value: control.value as String?,
              onChanged: (value) {
                control.value = value;
              },
            );
          }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ReactiveValueListenableBuilder<UserAvatarFormType>(
            formControlName: _EditProfileFormKeys.image.name,
            builder: (context, control, child) {
              return GestureDetector(
                onTap: () async {
                  control.value = Either.right(await _dialogBuilder(context));
                },
                child: Center(
                  child: CircleAvatar(
                    backgroundColor: context.colors.tertiary,
                    radius: context.relativeWidth(0.25, 60.0, 120.0),
                    foregroundImage: control.value!.right != null
                        ? FileImage(File(control.value!.right!.path))
                        : (control.value!.left != null
                            ? CachedNetworkImageProvider(control.value!.left!)
                            : const AssetImage(MaybeImage
                                .userFallbackImagePath)) as ImageProvider,
                    child: control.value == null
                        ? const Icon(Icons.camera_alt)
                        : null,
                  ),
                ),
              );
            }),
        const SizedBox(
          height: AcSizes.space,
        ),
        buildGenericTextInput(
            name: _EditProfileFormKeys.name.name,
            label: "screen/profile/screens/edit_profile_screen/name".i18n(),
            required: true,
            placeholder: "screen/login/register/enter_name".i18n()),
        buildGenericTextInput(
            name: _EditProfileFormKeys.bio.name,
            label: "screen/profile/screens/edit_profile_screen/about_yourself".i18n(),
            multiline: true),
        buildBirthdateInput(),
        buildCountrySelect(),
        Center(
          child: Padding(
            padding:
                const EdgeInsets.only(top: AcSizes.space, bottom: AcSizes.lg),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.save),
              onPressed: onSave,
              label:  Text(
                "screen/profile/screens/change_auth_screen/save_change".i18n(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<XFile?> _dialogBuilder(BuildContext context) async {
    XFile? image;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return ImagePickMethodDialog(
          context: context,
          onPickSource: (source) async {
            image = await _picker.pickImage(
              source: source,
              maxWidth: 800,
              maxHeight: 800,
            );
          },
        );
      },
    );
    return image;
  }

  Future<DateTime?> showCalender(BuildContext ctx, DateTime? date) async {
    final now = DateTime.now();
    return showDatePicker(
      context: ctx,
      initialDate: date ?? now,
      lastDate: now,
      firstDate: now.copyWith(year: now.year - 99),
    );
  }
}
