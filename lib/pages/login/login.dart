import 'package:flutter/material.dart';
import 'package:localization/localization.dart';
import 'package:pambe_ac_ifa/common/constants.dart';
import 'package:pambe_ac_ifa/components/app/app_bar.dart';
import 'package:pambe_ac_ifa/components/app/snackbar.dart';
import 'package:pambe_ac_ifa/controllers/auth.dart';
import 'package:pambe_ac_ifa/database/interfaces/user.dart';
import 'package:pambe_ac_ifa/pages/home/main.dart';
import 'package:pambe_ac_ifa/pages/login/components/actions.dart';
import 'package:pambe_ac_ifa/pages/startup/components.dart';
import 'package:provider/provider.dart';
import 'package:reactive_forms/reactive_forms.dart';

class _LoginScreenForm extends StatefulWidget {
  final Future<void> Function(LoginPayload payload) onSubmit;
  const _LoginScreenForm({required this.onSubmit});

  @override
  State<_LoginScreenForm> createState() => _LoginScreenFormState();
}

class _LoginScreenFormState extends State<_LoginScreenForm> {
  late final FormGroup form;

  @override
  void initState() {
    super.initState();
    form = FormGroup({
      "email": FormControl<String>(
          validators: [Validators.required, Validators.email]),
      "password": FormControl<String>(validators: [
        Validators.required,
        Validators.minLength(8),
      ]),
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
              placeholder: "screen/login/enter_email".i18n()),
          buildGenericTextInput(
              name: "password",
              label: "Password",
              required: true,
              obscureText: true,
              placeholder: "screen/login/enter_password".i18n()),
          LoginSubmitButton(
              onPressed: () {
                return widget.onSubmit((
                  email: form.value["email"] as String,
                  password: form.value["password"] as String,
                ));
              },
              label: "screen/home/guest/login".i18n())
        ],
      ),
    );
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  Future<void> _login(BuildContext context, LoginPayload payload) async {
    final navigator = Navigator.of(context);
    final auth = context.read<AuthProvider>();

    final messenger = AcSnackbarMessenger.of(context);
    try {
      await auth.login(payload);
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
            return _LoginScreenForm(
              onSubmit: (payload) {
                return _login(context, payload);
              },
            );
          }),
        ],
      ),
    ));
  }
}
