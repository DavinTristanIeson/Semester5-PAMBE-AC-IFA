import 'package:flutter/widgets.dart';
import 'package:localization/localization.dart';
import 'package:reactive_forms/reactive_forms.dart';

class AcReactiveFormConfig extends StatelessWidget {
  final Widget child;
  const AcReactiveFormConfig({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ReactiveFormConfig(
      validationMessages: {
        ValidationMessage.required: (error) => "validation/required".i18n(),
        ValidationMessage.equals: (error) =>
            "validation/equals_extra".i18n([error.toString()]),
        ValidationMessage.maxLength: (error) => "validation/max_length".i18n(
            [(error as Map<String, Object>)["requiredLength"].toString()]),
        ValidationMessage.minLength: (error) => "validation/min_length".i18n(
            [(error as Map<String, Object>)["requiredLength"].toString()]),
        AcValidationMessage.acceptedChars: (error) =>
            "validation/accepted_chars".i18n(),
        AcValidationMessage.passwordConfirmationMismatch: (error) =>
            "validation/password_confirmation_mismatch".i18n(),
        ValidationMessage.email: (error) => "validation/email".i18n(),
        AcValidationMessage.imageRequired: (error) =>
            "validation/image_required".i18n(),
      },
      child: child,
    );
  }
}

extension ReactiveFormTranslateError on ReactiveFormConfig {
  String translate(String type, Object payload) {
    if (validationMessages.containsKey(type)) {
      return validationMessages[type]!(payload);
    } else {
      return "${'Error'.i18n()}: $type";
    }
  }

  Map<String, String> translateAll(Map<String, Object> errors) {
    return Map.fromEntries(errors.entries.map(
        (entry) => MapEntry(entry.key, translate(entry.key, entry.value))));
  }

  String? translateAny(Map<String, Object> errors) {
    var entry = errors.entries.firstOrNull;
    return entry == null ? null : translate(entry.key, entry.value);
  }
}

extension AcValidators on Validators {
  static Validator<dynamic> get acceptedChars {
    return Validators.pattern(RegExp(r'^[a-zA-Z0-9 ]+$'),
        validationMessage: AcValidationMessage.acceptedChars);
  }
}

extension AcValidationMessage on ValidationMessage {
  static const acceptedChars = "acceptedChars";
  static const passwordConfirmationMismatch = "passwordConfirmationMismatch";
  static const imageRequired = "imageRequired";
}
