import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/common/constants.dart';
import 'package:pambe_ac_ifa/common/extensions.dart';
import 'package:pambe_ac_ifa/common/validation.dart';
import 'package:pambe_ac_ifa/components/app/app_bar.dart';
import 'package:pambe_ac_ifa/components/app/confirmation.dart';
import 'package:pambe_ac_ifa/components/app/snackbar.dart';
import 'package:pambe_ac_ifa/components/display/future.dart';
import 'package:pambe_ac_ifa/controllers/auth.dart';
import 'package:pambe_ac_ifa/controllers/delete_account.dart';
import 'package:pambe_ac_ifa/controllers/user.dart';
import 'package:pambe_ac_ifa/database/interfaces/user.dart';
import 'package:pambe_ac_ifa/pages/home/main.dart';
import 'package:pambe_ac_ifa/pages/login/components/actions.dart';
import 'package:provider/provider.dart';
import 'package:reactive_forms/reactive_forms.dart';

enum _ChangeAuthFormKeys {
  email,
  password,
  passwordConfirmation,
}

class ChangeAuthScreen extends StatefulWidget {
  const ChangeAuthScreen({super.key});

  @override
  State<ChangeAuthScreen> createState() => _ChangeAuthScreenState();
}

class _ChangeAuthScreenState extends State<ChangeAuthScreen> {
  late final FormGroup form;
  @override
  void initState() {
    super.initState();
    final passwordControl = FormControl<String>(validators: [
      Validators.delegate((control) {
        final value = control.value as String?;
        if (value == null || value.isEmpty) {
          return null;
        }
        final Map<String, dynamic> errors = {};
        if (value.length < 8) {
          errors[ValidationMessage.minLength] = {
            "requiredLength": 8,
          };
        }
        return errors;
      }),
    ]);
    form = FormGroup({
      _ChangeAuthFormKeys.email.name: FormControl<String>(validators: [
        Validators.delegate((control) {
          final value = control.value as String?;
          if (value == null || value.isEmpty) {
            return null;
          }
          return Validators.email.call(control);
        })
      ]),
      _ChangeAuthFormKeys.password.name: passwordControl,
      _ChangeAuthFormKeys.passwordConfirmation.name:
          FormControl<String>(validators: [
        Validators.delegate((control) {
          final passwordValue = passwordControl.value;
          return (passwordValue != control.value &&
                  passwordValue != null &&
                  passwordValue.isNotEmpty)
              ? {
                  AcValidationMessage.passwordConfirmationMismatch: true,
                }
              : null;
        })
      ]),
    });
  }

  @override
  void dispose() {
    super.dispose();
    form.dispose();
  }

  Future<void> save() async {
    final messenger = AcSnackbarMessenger.of(context);
    if (form.invalid) {
      messenger.sendError("Please resolve all errors before saving");
      return;
    }
    final email = form.value[_ChangeAuthFormKeys.email.name] as String?;
    final password = form.value[_ChangeAuthFormKeys.password.name] as String?;
    if ((email == null || email.isEmpty) &&
        (password == null || password.isEmpty)) {
      messenger.sendError("Email and password is unchanged.");
      return;
    }

    final authController = context.read<AuthProvider>();
    final userController = context.read<UserController>();
    final navigator = context.navigator;

    LoginPayload? credentials;
    await showDialog(
        context: context,
        builder: (context) {
          return ChangeAuthDialog(
              onConfirm: (LoginPayload payload) {
                credentials = payload;
                Navigator.pop(context);
              },
              reason: "Your email and/or password will be updated");
        });
    if (credentials == null) {
      return;
    }

    try {
      await authController.updateAuth(payload: (
        email: email,
        password: password,
      ), credentials: credentials!);
      if (email != null) {
        await userController.updateEmail(email);
        messenger.sendSuccess("Your email has been updated successfully");
      }
      if (password != null) {
        messenger.sendSuccess("Your password has been updated successfully");
      }
      navigator.pop();
    } catch (e) {
      messenger.sendError(e);
      return;
    }
  }

  Future<void> confirmDeleteAccount() async {
    final authProvider = context.read<AuthProvider>();
    final deleteAccountService = context.read<DeleteAccountService>();
    final navigator = Navigator.of(context);
    LoginPayload? credentials;
    await showDialog(
        context: context,
        builder: (context) {
          return ChangeAuthDialog(
              onConfirm: (creds) {
                credentials = creds;
                Navigator.pop(context);
              },
              reason:
                  "Your account will be deleted and all of your recipes will no longer be accessible");
        });
    if (credentials == null) {
      return;
    }
    // ignore: use_build_context_synchronously
    final result = await showBlockingDialog(context, () {
      return deleteAccountService
          .run((credentials: credentials!, uid: authProvider.user!.uid));
    });
    if (result.hasValue) {
      await authProvider.logout();
      navigator.pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: OnlyReturnAppBar(
        actions: [
          FutureOutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: context.colors.error,
                side: BorderSide(color: context.colors.error),
              ),
              onPressed: confirmDeleteAccount,
              progressIndicatorColor: context.colors.error,
              child: const Text("Delete Account"))
        ],
      ),
      body: ReactiveForm(
        formGroup: form,
        child: ChangeAuthScreenBody(onSave: save),
      ),
    );
  }
}

class ChangeAuthDialog extends StatefulWidget {
  final void Function(LoginPayload credentials) onConfirm;
  final String reason;
  const ChangeAuthDialog(
      {super.key, required this.onConfirm, required this.reason});

  @override
  State<ChangeAuthDialog> createState() => _ChangeAuthDialogState();
}

class _ChangeAuthDialogState extends State<ChangeAuthDialog> {
  late final FormGroup form;

  @override
  void initState() {
    super.initState();
    form = FormGroup({
      _ChangeAuthFormKeys.email.name:
          FormControl<String>(validators: [Validators.required]),
      _ChangeAuthFormKeys.password.name:
          FormControl<String>(validators: [Validators.required]),
    });
  }

  @override
  void dispose() {
    super.dispose();
    form.dispose();
  }

  void confirm() {
    if (form.invalid) {
      return;
    }
    widget.onConfirm((
      email: form.value[_ChangeAuthFormKeys.email.name] as String,
      password: form.value[_ChangeAuthFormKeys.password.name] as String,
    ));
  }

  Widget buildBody(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
              "Your current email and password is required to authenticate these changes."),
          Text(
            widget.reason,
            style: AcTypography.importantDescription
                .copyWith(color: context.colors.error),
          ),
          buildGenericTextInput(
              name: _ChangeAuthFormKeys.email.name,
              label: "Email",
              required: true,
              padding: const EdgeInsets.symmetric(vertical: AcSizes.md),
              placeholder: "Enter your current email"),
          buildGenericTextInput(
              name: _ChangeAuthFormKeys.password.name,
              label: "Password",
              required: true,
              placeholder: "Enter your current password",
              padding: const EdgeInsets.symmetric(vertical: AcSizes.md),
              obscureText: true),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ReactiveForm(
      formGroup: form,
      child: AlertDialog(
        title: Text("Authentication Required", style: context.texts.titleLarge),
        content: ReactiveForm(formGroup: form, child: buildBody(context)),
        backgroundColor: AcColors.white,
        actions: [
          TextButton(
              onPressed: () {
                context.navigator.pop();
              },
              child: Text("Cancel",
                  style: TextStyle(color: context.colors.secondary))),
          ReactiveValueListenableBuilder(
              formControl: form,
              builder: (context, control, child) {
                return TextButton(
                    onPressed: control.invalid ? null : confirm,
                    child: Text("Confirm",
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: control.invalid
                                ? context.colors.tertiary
                                : context.colors.primary)));
              }),
        ],
      ),
    );
  }
}

class ChangeAuthScreenBody extends StatelessWidget {
  final Future<void> Function() onSave;
  const ChangeAuthScreenBody({super.key, required this.onSave});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        // buildGenericTextInput(
        //     name: _ChangeAuthFormKeys.email.name,
        //     label: "New Email",
        //     placeholder: "Leave empty if email won't be changed"),
        buildGenericTextInput(
            name: _ChangeAuthFormKeys.password.name,
            label: "New Password",
            placeholder: "Leave empty if password won't be changed"),
        ReactiveValueListenableBuilder(
          formControlName: _ChangeAuthFormKeys.password.name,
          child: buildGenericTextInput(
              name: _ChangeAuthFormKeys.passwordConfirmation.name,
              label: "Enter your password again"),
          builder: (context, control, child) {
            final value = control.value as String?;
            if (value == null || value.isEmpty) {
              return const SizedBox();
            }
            return child!;
          },
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.only(top: AcSizes.lg, bottom: AcSizes.lg),
            child: FutureButton(
              icon: const Icon(Icons.save),
              onPressed: onSave,
              child: const Text(
                "Save Changes",
              ),
            ),
          ),
        ),
      ],
    );
  }
}
