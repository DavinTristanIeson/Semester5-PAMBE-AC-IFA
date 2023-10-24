import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pambe_ac_ifa/common/constants.dart';
import 'package:pambe_ac_ifa/components/app/app_bar.dart';
import 'package:pambe_ac_ifa/components/app/snackbar.dart';
import 'package:pambe_ac_ifa/controllers/auth.dart';
import 'package:pambe_ac_ifa/common/validation.dart';
import 'package:pambe_ac_ifa/database/interfaces/resource.dart';
import 'package:pambe_ac_ifa/pages/login/components/actions.dart';
import 'package:pambe_ac_ifa/pages/startup/components.dart';
import 'package:provider/provider.dart';
import 'package:reactive_forms/reactive_forms.dart';

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
      "image": FormControl<XFile?>(),
      "email": FormControl<String>(
          validators: [Validators.required, Validators.email]),
      "password": passwordControl,
      "passwordConfirmation": FormControl<String>(validators: [
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
      "name": FormControl<String>(
          validators: [Validators.minLength(5), AcValidators.acceptedChars]),
      "bio": FormControl<String>(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return ReactiveForm(
      formGroup: form,
      child: Column(
        children: [
          buildGenericTextInput(
              name: "email",
              label: "Email",
              required: true,
              placeholder: "Enter your email"),
          buildGenericTextInput(
              name: "password",
              label: "Password",
              required: true,
              obscureText: true,
              placeholder: "Enter password (min. 8 characters)"),
          buildGenericTextInput(
              name: "passwordConfirmation",
              label: "Confirm Password",
              required: true,
              obscureText: true,
              placeholder: "Enter your password again"),
          buildGenericTextInput(
              name: "name",
              label: "Name",
              required: true,
              placeholder: "Enter your name"),
          buildGenericTextInput(
              name: "bio",
              label: "About Me",
              multiline: true,
              placeholder: "Tell us about you!"),
          LoginSubmitButton(
              onPressed: () {
                widget.onSubmit((
                  email: form.value["email"] as String,
                  password: form.value["password"] as String,
                  name: form.value["name"] as String,
                  bio: form.value["bio"] as String?,
                  image: form.value["image"] as XFile?,
                ));
              },
              label: "Register")
        ],
      ),
    );
  }
}

class RegisterScreen extends StatelessWidget with SnackbarMessenger {
  const RegisterScreen({super.key});

  void _register(BuildContext context, RegisterPayload payload) async {
    final navigator = Navigator.of(context);
    try {
      await context.read<AuthProvider>().register(payload);
      navigator.pop();
    } catch (e) {
      // ignore: use_build_context_synchronously
      sendError(context, e.toString());
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
