import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:localization/localization.dart';
import 'package:pambe_ac_ifa/common/constants.dart';
import 'package:pambe_ac_ifa/components/app/app_bar.dart';
import 'package:pambe_ac_ifa/components/app/confirmation.dart';
import 'package:pambe_ac_ifa/controllers/auth.dart';
import 'package:pambe_ac_ifa/common/validation.dart';
import 'package:pambe_ac_ifa/controllers/user.dart';
import 'package:pambe_ac_ifa/database/interfaces/user.dart';
import 'package:pambe_ac_ifa/pages/home/main.dart';
import 'package:pambe_ac_ifa/pages/login/components/actions.dart';
import 'package:pambe_ac_ifa/pages/startup/components.dart';
import 'package:provider/provider.dart';
import 'package:reactive_forms/reactive_forms.dart';

enum _RegisterFormKeys {
  image,
  email,
  password,
  passwordConfirmation,
  name,
  bio,
}

class _RegisterScreenForm extends StatefulWidget {
  final Future<void> Function(RegisterPayload payload) onSubmit;
  const _RegisterScreenForm({required this.onSubmit});

  @override
  State<_RegisterScreenForm> createState() => _RegisterScreenFormState();
}

class _RegisterScreenFormState extends State<_RegisterScreenForm> {
  late final FormGroup form;

  @override
  void initState() {
    super.initState();
    final passwordControl = FormControl<String>(validators: [
      Validators.required,
      Validators.minLength(8),
    ]);
    form = FormGroup({
      _RegisterFormKeys.image.name: FormControl<XFile?>(),
      _RegisterFormKeys.email.name: FormControl<String>(
          validators: [Validators.required, Validators.email]),
      _RegisterFormKeys.password.name: passwordControl,
      _RegisterFormKeys.passwordConfirmation.name:
          FormControl<String>(validators: [
        Validators.required,
        Validators.delegate((control) {
          final passwordValue = passwordControl.value;
          return (passwordValue != control.value)
              ? {
                  AcValidationMessage.passwordConfirmationMismatch: true,
                }
              : null;
        })
      ]),
      _RegisterFormKeys.name.name: FormControl<String>(validators: [
        Validators.required,
        Validators.minLength(5),
        AcValidators.acceptedChars
      ]),
      _RegisterFormKeys.bio.name: FormControl<String>(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return ReactiveForm(
      formGroup: form,
      child: Column(
        children: [
          buildGenericTextInput(
              name: _RegisterFormKeys.email.name,
              label: "Email",
              required: true,
              placeholder: "common/enter_extra".i18n(["common/email".i18n()])),
          buildGenericTextInput(
              name: _RegisterFormKeys.password.name,
              label: "Password",
              required: true,
              obscureText: true,
              placeholder:
                  "common/enter_extra".i18n(["common/password".i18n()])),
          buildGenericTextInput(
              name: _RegisterFormKeys.passwordConfirmation.name,
              label: "screen/login/register/confirm_password".i18n(),
              required: true,
              obscureText: true,
              placeholder: "screen/login/register/enter_password_extra".i18n()),
          buildGenericTextInput(
              name: _RegisterFormKeys.name.name,
              label: "Name",
              required: true,
              placeholder: "common/enter_extra".i18n(["common/name".i18n()])),
          buildGenericTextInput(
              name: _RegisterFormKeys.bio.name,
              label: "screen/login/register/about_me".i18n(),
              multiline: true,
              placeholder: "screen/login/register/about_you".i18n()),
          LoginSubmitButton(
              onPressed: () {
                return widget.onSubmit((
                  email: form.value[_RegisterFormKeys.email.name] as String,
                  password:
                      form.value[_RegisterFormKeys.password.name] as String,
                  name: form.value[_RegisterFormKeys.name.name] as String,
                  bio: form.value[_RegisterFormKeys.bio.name] as String?,
                ));
              },
              label: "screen/home/guest/register".i18n())
        ],
      ),
    );
  }
}

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  Future<void> _register(BuildContext context, RegisterPayload payload) async {
    final navigator = Navigator.of(context);
    final authProvider = context.read<AuthProvider>();
    final userController = context.read<UserController>();

    final result = await showBlockingDialog(context, () async {
      final User(:uid) = await authProvider.register(payload);
      await userController.register(uid, payload);
    });
    if (result.hasValue) {
      navigator.pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      decoration:
          const BoxDecoration(gradient: AcDecoration.recipeLibRadialGradient),
      child: ListView(
        children: [
          OnlyReturnAppBar.buildBackButton(context),
          const RecipeLibLogoTitle(),
          Builder(builder: (context) {
            return _RegisterScreenForm(
              onSubmit: (payload) {
                return _register(context, payload);
              },
            );
          }),
        ],
      ),
    ));
  }
}
