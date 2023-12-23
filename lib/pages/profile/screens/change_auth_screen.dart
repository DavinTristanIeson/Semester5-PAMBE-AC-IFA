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
import 'package:localization/localization.dart';

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
      messenger.sendError("errors/resolve_all_errors".i18n());
      return;
    }
    final email = form.value[_ChangeAuthFormKeys.email.name] as String?;
    final password = form.value[_ChangeAuthFormKeys.password.name] as String?;
    if ((email == null || email.isEmpty) &&
        (password == null || password.isEmpty)) {
      messenger.sendError(
          "screen/profile/screens/change_auth_screen/email_password_unchanged"
              .i18n());
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
              reason:
                  "screen/profile/screens/change_auth_screen/email_password_will_be_updated"
                      .i18n());
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
        messenger.sendSuccess(
            "screen/profile/screens/change_auth_screen/your_extra_updated"
                .i18n(["common/email".i18n()]));
      }
      if (password != null) {
        messenger.sendSuccess(
            "screen/profile/screens/change_auth_screen/your_extra_updated"
                .i18n(["common/password".i18n()]).i18n());
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
                  "screen/profile/screens/change_auth_screen/your_account_will_be_deleted"
                      .i18n());
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
              child: Text(
                  "screen/profile/screens/change_auth_screen/delete_account"
                      .i18n()))
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
          Text(
              "screen/profile/screens/change_auth_screen/email_password_required_authenticate"
                  .i18n()),
          Text(
            widget.reason,
            style: AcTypography.importantDescription
                .copyWith(color: context.colors.error),
          ),
          buildGenericTextInput(
            name: _ChangeAuthFormKeys.email.name,
            label: "common/email".i18n(),
            required: true,
            padding: const EdgeInsets.symmetric(vertical: AcSizes.md),
            placeholder: "common/enter_your_extra".i18n([
              "screen/profile/screens/change_auth_screen/current_extra"
                  .i18n(["common/email".i18n().toLowerCase()]),
            ]),
          ),
          buildGenericTextInput(
              name: _ChangeAuthFormKeys.password.name,
              label: "common/password".i18n(),
              required: true,
              placeholder: "common/enter_your_extra".i18n([
                "screen/profile/screens/change_auth_screen/current_extra"
                    .i18n(["common/password".i18n().toLowerCase()]),
              ]),
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
        title: Text(
            "screen/profile/screens/change_auth_screen/authentication_required"
                .i18n(),
            style: context.texts.titleLarge),
        content: ReactiveForm(formGroup: form, child: buildBody(context)),
        backgroundColor: AcColors.white,
        actions: [
          TextButton(
              onPressed: () {
                context.navigator.pop();
              },
              child: Text("components/app/confirmation/cancel".i18n(),
                  style: TextStyle(color: context.colors.secondary))),
          ReactiveValueListenableBuilder(
              formControl: form,
              builder: (context, control, child) {
                return TextButton(
                    onPressed: control.invalid ? null : confirm,
                    child: Text("components/app/confirmation/confirm".i18n(),
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
            label:
                "screen/profile/screens/change_auth_screen/new_password".i18n(),
            placeholder:
                "screen/profile/screens/change_auth_screen/leave_empty_password"
                    .i18n()),
        ReactiveValueListenableBuilder(
          formControlName: _ChangeAuthFormKeys.password.name,
          child: buildGenericTextInput(
              name: _ChangeAuthFormKeys.passwordConfirmation.name,
              label: "screen/login/register/enter_password_extra".i18n()),
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
              child: Text(
                "screen/profile/screens/change_auth_screen/save_change".i18n(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
