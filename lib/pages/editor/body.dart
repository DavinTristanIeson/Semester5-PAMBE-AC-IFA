import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/common/constants.dart';
import 'package:pambe_ac_ifa/components/field/form_array.dart';
import 'package:pambe_ac_ifa/pages/editor/components/models.dart';
import 'package:pambe_ac_ifa/pages/editor/step_editor.dart';
import 'package:pambe_ac_ifa/pages/editor/title.dart';
import 'package:reactive_forms/reactive_forms.dart';

class RecipeEditorScreenBody extends StatefulWidget {
  const RecipeEditorScreenBody({super.key});

  @override
  State<RecipeEditorScreenBody> createState() => _RecipeEditorScreenBodyState();
}

class _RecipeEditorScreenBodyState extends State<RecipeEditorScreenBody> {
  late final ScrollController _scroll;
  @override
  void initState() {
    super.initState();
    _scroll = ScrollController();
  }

  @override
  void dispose() {
    super.dispose();
    _scroll.dispose();
  }

  void handleMutate(bool Function(FormArray formArray) fn) {
    final form = ReactiveForm.of(context) as FormGroup;
    bool shouldRerender =
        fn(form.controls[RecipeFormKeys.steps.name] as FormArray);
    if (shouldRerender) {
      setState(() {});
    }
  }

  Widget buildAddStepButton(BuildContext context) {
    final form = ReactiveForm.of(context) as FormGroup;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AcSizes.lg),
      child: Center(
        child: ElevatedButton.icon(
          onPressed: () {
            setState(() {
              final formArray =
                  form.controls[RecipeFormKeys.steps.name] as FormArray;
              formArray.add(RecipeStepFormType.toFormGroup());
            });
            Future.delayed(const Duration(milliseconds: 100), () {
              _scroll.animateTo(_scroll.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.decelerate);
            });
          },
          icon: const Icon(Icons.add),
          label: const Text("Add Step"),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final form = ReactiveForm.of(context) as FormGroup;
    final FormArray formArray =
        form.controls[RecipeFormKeys.steps.name] as FormArray;
    int length = formArray.controls.length + 2;
    return FormArrayController(
        mutate: handleMutate,
        child: ListView.builder(
            controller: _scroll,
            itemCount: length,
            itemBuilder: (context, i) {
              if (i == 0) {
                return const RecipeDetailsEditor();
              } else if (i == length - 1) {
                return buildAddStepButton(context);
              }
              return ReactiveForm(
                key: ValueKey(formArray.controls[i - 1].hashCode),
                formGroup: formArray.controls[i - 1] as FormGroup,
                child: RecipeStepEditor(
                  index: i - 1,
                ),
              );
            }));
  }
}
