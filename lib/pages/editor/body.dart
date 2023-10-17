import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pambe_ac_ifa/common/constants.dart';
import 'package:pambe_ac_ifa/components/app/app_bar.dart';
import 'package:pambe_ac_ifa/components/app/snackbar.dart';
import 'package:pambe_ac_ifa/components/field/form_array.dart';
import 'package:pambe_ac_ifa/controllers/lib/errors.dart';
import 'package:pambe_ac_ifa/controllers/recipe.dart';
import 'package:pambe_ac_ifa/models/recipe.dart';
import 'package:pambe_ac_ifa/pages/editor/components/models.dart';
import 'package:pambe_ac_ifa/pages/editor/step_editor.dart';
import 'package:pambe_ac_ifa/pages/editor/title.dart';
import 'package:pambe_ac_ifa/controllers/local_recipe.dart';
import 'package:provider/provider.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:pambe_ac_ifa/common/validation.dart';

class RecipeEditorScreenBody extends StatefulWidget {
  final RecipeModel? recipe;
  const RecipeEditorScreenBody({super.key, this.recipe});

  @override
  State<RecipeEditorScreenBody> createState() => _RecipeEditorScreenBodyState();
}

class _RecipeEditorScreenBodyState extends State<RecipeEditorScreenBody>
    with SnackbarMessenger {
  late final FormGroup form;
  late final ScrollController _scroll;

  @override
  void initState() {
    super.initState();
    _scroll = ScrollController();
    form = FormGroup({
      RecipeFormKeys.title.name:
          FormControl<String>(value: widget.recipe?.title, validators: [
        Validators.minLength(5),
        AcValidators.acceptedChars,
      ]),
      RecipeFormKeys.description.name:
          FormControl<String>(value: widget.recipe?.description, validators: [
        Validators.required,
      ]),
      RecipeFormKeys.image.name: FormControl<XFile?>(
          value: widget.recipe?.imagePath == null
              ? null
              : XFile(widget.recipe!.imagePath!)),
      RecipeFormKeys.steps.name: FormArray(
          widget.recipe?.steps == null
              ? [
                  RecipeStepFormType.toFormGroup(),
                ]
              : widget.recipe!.steps
                  .map((step) => RecipeStepFormType.toFormGroup(value: step))
                  .toList(),
          validators: [
            Validators.minLength(1),
          ]),
    });
  }

  void save() async {
    LocalRecipeController controller =
        Provider.of<LocalRecipeController>(context, listen: false);

    if (form.invalid) {
      sendError(context, "Please resolve all errors before saving!");
      return;
    }

    final steps =
        (form.value[RecipeFormKeys.steps.name] as List<Map<String, Object?>?>)
            .map((step) => RecipeStepFormType.fromFormGroup(step!))
            .toList();
    try {
      final String title = form.value[RecipeFormKeys.title.name] as String;
      final String? description =
          form.value[RecipeFormKeys.description.name] as String?;
      await controller.put(
          title: title, description: description, steps: steps);
      form.markAsPristine();
    } catch (e) {
      // ignore: use_build_context_synchronously
      sendError(context, e.toString());
    }
  }

  void publish() async {
    if (form.dirty) {
      sendError(context,
          "Changes to the recipe should be saved first before publishing!");
      return;
    }

    try {
      context.read<RecipeController>().put(widget.recipe!);
    } on ApiError catch (e) {
      sendError(context, e.message);
    }
  }

  Widget buildAddStepButton() {
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

  Widget buildScroll(BuildContext context) {
    final FormArray formArray =
        form.controls[RecipeFormKeys.steps.name] as FormArray;
    int length = formArray.controls.length + 2;
    return ListView.builder(
        controller: _scroll,
        itemCount: length,
        itemBuilder: (context, i) {
          if (i == 0) {
            return const RecipeDetailsEditor();
          } else if (i == length - 1) {
            return buildAddStepButton();
          }
          return ReactiveForm(
            key: ValueKey(formArray.controls[i - 1].hashCode),
            formGroup: formArray.controls[i - 1] as FormGroup,
            child: RecipeStepEditor(
              index: i - 1,
            ),
          );
        });
  }

  void handleMutate(bool Function(FormArray formArray) fn) {
    bool shouldRerender =
        fn(form.controls[RecipeFormKeys.steps.name] as FormArray);
    if (shouldRerender) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: OnlyReturnAppBar(
          actions: [
            if (widget.recipe != null)
              Tooltip(
                message: "Publish Recipe",
                child: IconButton(
                    onPressed: publish,
                    color: Theme.of(context).colorScheme.tertiary,
                    icon: const Icon(Icons.upload)),
              ),
          ],
        ),
        floatingActionButton: Tooltip(
          message: "Save",
          child: FloatingActionButton(
            onPressed: save,
            child: const Icon(Icons.save),
          ),
        ),
        body: ReactiveForm(
          formGroup: form,
          child: FormArrayController(
              mutate: handleMutate, child: buildScroll(context)),
        ));
  }
}
