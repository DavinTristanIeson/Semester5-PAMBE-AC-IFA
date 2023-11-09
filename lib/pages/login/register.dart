import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pambe_ac_ifa/common/constants.dart';
import 'package:pambe_ac_ifa/components/app/app_bar.dart';
import 'package:pambe_ac_ifa/components/app/snackbar.dart';
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
  final void Function(RegisterPayload payload) onSubmit;
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
      _RegisterFormKeys.name.name: FormControl<String>(
          validators: [Validators.minLength(5), AcValidators.acceptedChars]),
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
              placeholder: "Enter your email"),
          buildGenericTextInput(
              name: _RegisterFormKeys.password.name,
              label: "Password",
              required: true,
              obscureText: true,
              placeholder: "Enter password (min. 8 characters)"),
          buildGenericTextInput(
              name: _RegisterFormKeys.passwordConfirmation.name,
              label: "Confirm Password",
              required: true,
              obscureText: true,
              placeholder: "Enter your password again"),
          buildGenericTextInput(
              name: _RegisterFormKeys.name.name,
              label: "Name",
              required: true,
              placeholder: "Enter your name"),
          buildGenericTextInput(
              name: _RegisterFormKeys.bio.name,
              label: "About Me",
              multiline: true,
              placeholder: "Tell us about you!"),
          LoginSubmitButton(
              onPressed: () {
                widget.onSubmit((
                  email: form.value[_RegisterFormKeys.email.name] as String,
                  password:
                      form.value[_RegisterFormKeys.password.name] as String,
                  name: form.value[_RegisterFormKeys.name.name] as String,
                  bio: form.value[_RegisterFormKeys.bio.name] as String?,
                  image: form.value[_RegisterFormKeys.image.name] as XFile?,
                ));
              },
              label: "Register")
        ],
      ),
    );
  }
}

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  void _register(BuildContext context, RegisterPayload payload) async {
    final navigator = Navigator.of(context);
    final authProvider = context.read<AuthProvider>();
    final userController = context.read<UserController>();
    final messenger = AcSnackbarMessenger.of(context);
    try {
      final User(:uid) = await authProvider.register(payload);
      await userController.register(uid, payload);
      navigator.pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false);
    } catch (e) {
      messenger.sendError(e);
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
                _register(context, payload);
              },
            );
          }),
        ],
      ),
    ));
  }
}
