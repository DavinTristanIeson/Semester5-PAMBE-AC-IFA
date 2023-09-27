import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pambe_ac_ifa/components/app/app_bar.dart';
import 'package:pambe_ac_ifa/pages/editor/title.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:pambe_ac_ifa/common/validation.dart';

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
      'title': FormControl<String>(validators: [
        Validators.minLength(5),
        AcValidators.acceptedChars,
      ]),
      'description': FormControl<String>(validators: [
        Validators.required,
      ]),
      'thumbnail': FormControl<XFile?>(validators: [
        Validators.required,
      ]),
    });
  }

  void save() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: OnlyReturnAppBar(
        actions: [
          IconButton(
              onPressed: () {},
              color: Theme.of(context).colorScheme.tertiary,
              icon: const Icon(Icons.more_vert)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: save,
        child: const Icon(Icons.save),
      ),
      body: ReactiveForm(
        formGroup: form,
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            RecipeDetailsEditor(),
          ],
        ),
      ),
    );
  }
}
