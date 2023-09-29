import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';

/// Provides a way to easily access the formArray from deep in the form.
/// The callback received by ``mutate`` will return a boolean which indicates whether any mutation occurred or not. If not, the provider should consider not rerendering.
/// ```
/// FormArrayController.of(context).mutate((formArray) {
///   // Do stuff here
/// })
/// ```
class FormArrayController extends InheritedWidget {
  final void Function(bool Function(FormArray formArray)) mutate;
  const FormArrayController(
      {super.key, required super.child, required this.mutate});

  /// DO NOT MODIFY FORM ARRAY FROM HERE. THERE WILL BE NO RERENDERING PERFORMED.
  FormArray get formArray {
    // Very questionable code, but it works.
    FormArray? formArray;
    mutate((value) {
      formArray = value;
      return false;
    });
    return formArray!;
  }

  @override
  bool updateShouldNotify(covariant FormArrayController oldWidget) {
    return oldWidget.mutate != mutate;
  }

  static FormArrayController of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<FormArrayController>()!;
  }
}

/// Is the input enabled or not, and what's the value?
class InputToggle<T> {
  T? value;
  late bool toggle;
  InputToggle(this.toggle, this.value);
  InputToggle.on(this.value) {
    toggle = true;
  }
  InputToggle.off() {
    toggle = false;
  }
  InputToggle<T> toggled() {
    return InputToggle(!toggle, value);
  }

  InputToggle<T> withValue(T? value) {
    return InputToggle(toggle, value);
  }
}
