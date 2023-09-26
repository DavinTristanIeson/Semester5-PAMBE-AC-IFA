import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/components/field/text_input.dart';
import 'package:reactive_forms/reactive_forms.dart';

class RecipeEditorPage extends StatefulWidget {
  const RecipeEditorPage({super.key});

  @override
  State<RecipeEditorPage> createState() => _RecipeEditorPageState();
}

class _RecipeEditorPageState extends State<RecipeEditorPage> {
  late final FormGroup form;

  @override
  void initState() {
    super.initState();
    form = FormGroup({
      'name': FormControl<String>(value: "Davin", validators: [
        Validators.maxLength(8),
      ]),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ReactiveForm(
        formGroup: form,
        child: ReactiveValueListenableBuilder<String>(
            formControlName: "name",
            builder: (context, control, child) {
              return AcTextInput(
                  value: control.value ?? '',
                  onChanged: (String? value) {
                    control.value = value ?? '';
                    print(value);
                  },
                  label: "Name",
                  required: true);
            }),
      ),
    );
  }
}
