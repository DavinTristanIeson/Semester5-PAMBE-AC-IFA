import 'package:flutter/widgets.dart';
import 'package:reactive_forms/reactive_forms.dart';

class AcReactiveFormConfig extends StatelessWidget {
  final Widget child;
  const AcReactiveFormConfig({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ReactiveFormConfig(
      validationMessages: {
        ValidationMessage.required: (error) => "Field must not be empty",
        ValidationMessage.equals: (error) => "Field should be equal to $error",
        ValidationMessage.maxLength: (error) =>
            "Field has a maximum length of ${(error as Map<String, Object>)["requiredLength"]} characters",
        ValidationMessage.minLength: (error) =>
            "Field has a minimum length of ${(error as Map<String, Object>)["requiredLength"]} characters",
        AcValidationMessage.acceptedChars: (error) =>
            "Field only accepts spaces, numbers, and alphabetic characters",
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
      return "Error: $type";
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
}
