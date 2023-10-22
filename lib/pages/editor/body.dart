import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pambe_ac_ifa/common/constants.dart';
import 'package:pambe_ac_ifa/components/app/app_bar.dart';
import 'package:pambe_ac_ifa/components/app/confirmation.dart';
import 'package:pambe_ac_ifa/components/app/snackbar.dart';
import 'package:pambe_ac_ifa/components/field/form_array.dart';
import 'package:pambe_ac_ifa/controllers/auth.dart';
import 'package:pambe_ac_ifa/controllers/recipe.dart';
import 'package:pambe_ac_ifa/database/interfaces/errors.dart';
import 'package:pambe_ac_ifa/models/container.dart';
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
  final void Function(RecipeModel recipe) onChanged;
  const RecipeEditorScreenBody(
      {super.key, this.recipe, required this.onChanged});

  @override
  State<RecipeEditorScreenBody> createState() => _RecipeEditorScreenBodyState();
}

class _RecipeEditorScreenBodyState extends State<RecipeEditorScreenBody>
    with SnackbarMessenger {
  late FormGroup form;
  late final ScrollController _scroll;

  @override
  void initState() {
    super.initState();
    _scroll = ScrollController();
    form = defaultValue(widget.recipe);
  }

  FormGroup defaultValue(RecipeModel? recipe) {
    return FormGroup({
      RecipeFormKeys.title.name:
          FormControl<String>(value: recipe?.title, validators: [
        Validators.minLength(5),
        AcValidators.acceptedChars,
      ]),
      RecipeFormKeys.description.name:
          FormControl<String>(value: recipe?.description, validators: [
        Validators.required,
      ]),
      RecipeFormKeys.image.name: FormControl<XFile?>(
          value: recipe?.imagePath == null ? null : XFile(recipe!.imagePath!)),
      RecipeFormKeys.steps.name: FormArray(
          recipe?.steps == null
              ? [
                  RecipeStepFormType.toFormGroup(),
                ]
              : recipe!.steps
                  .map((step) => RecipeStepFormType.toFormGroup(value: step))
                  .toList(),
          validators: [
            Validators.minLength(1),
          ]),
    });
  }

  @override
  didUpdateWidget(covariant RecipeEditorScreenBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.recipe != widget.recipe) {
      form = defaultValue(widget.recipe);
    }
  }

  void save() async {
    final controller = context.read<LocalRecipeController>();
    final user = context.read<AuthProvider>().user!;
    if (form.invalid) {
      sendError(context, "Please resolve all errors before saving!");
      return;
    }

    final steps = (form.value[RecipeFormKeys.steps.name] as List)
        .cast<Map<String, Object?>?>()
        .map((step) => RecipeStepFormType.fromFormGroup(step!))
        .toList();
    try {
      final title = form.value[RecipeFormKeys.title.name] as String;
      final description =
          form.value[RecipeFormKeys.description.name] as String?;
      final image = form.value[RecipeFormKeys.image.name] as XFile?;
      final recipe = await controller.put(
          title: title,
          description: description,
          steps: steps,
          user: user,
          image: image,
          former: widget.recipe);
      form.markAsPristine();
      widget.onChanged(recipe);
      // ignore: use_build_context_synchronously
      sendSuccess(context, "$title has been saved locally.");
    } catch (e) {
      // ignore: use_build_context_synchronously
      sendError(context, e.toString());
    }
  }

  void publish() async {
    if (form.dirty || widget.recipe == null) {
      sendError(context,
          "Changes to the recipe should be saved first before publishing!");
      return;
    }

    showDialog(
        context: context,
        builder: (context) {
          return SimpleConfirmationDialog(
              onConfirm: () async {
                try {
                  await context.read<RecipeController>().put(widget.recipe!);
                } on ApiError catch (e) {
                  // ignore: use_build_context_synchronously
                  sendError(context, e.message);
                }
              },
              context: context,
              positiveText: Either.right("Publish"),
              title: Either.right("Publish ${widget.recipe!.title}"),
              message: Either.right(
                  "Do you want to publish your recipe (or the local changes to your recipe) online?"));
        });
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
