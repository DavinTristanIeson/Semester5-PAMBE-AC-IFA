import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pambe_ac_ifa/common/extensions.dart';
import 'package:pambe_ac_ifa/components/app/app_bar.dart';
import 'package:pambe_ac_ifa/components/app/confirmation.dart';
import 'package:pambe_ac_ifa/components/app/snackbar.dart';
import 'package:pambe_ac_ifa/controllers/auth.dart';
import 'package:pambe_ac_ifa/controllers/recipe.dart';
import 'package:pambe_ac_ifa/database/interfaces/errors.dart';
import 'package:pambe_ac_ifa/models/container.dart';
import 'package:pambe_ac_ifa/models/recipe.dart';
import 'package:pambe_ac_ifa/pages/editor/body.dart';
import 'package:pambe_ac_ifa/pages/editor/components/models.dart';
import 'package:pambe_ac_ifa/controllers/local_recipe.dart';
import 'package:provider/provider.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:pambe_ac_ifa/common/validation.dart';

class RecipeEditorScreenForm extends StatefulWidget {
  final LocalRecipeModel? recipe;
  final void Function(LocalRecipeModel recipe) onChanged;
  const RecipeEditorScreenForm(
      {super.key, this.recipe, required this.onChanged});

  @override
  State<RecipeEditorScreenForm> createState() => _RecipeEditorScreenFormState();
}

class _RecipeEditorScreenFormState extends State<RecipeEditorScreenForm>
    with SnackbarMessenger {
  late FormGroup form;

  @override
  void initState() {
    super.initState();
    form = defaultValue(widget.recipe);
  }

  @override
  void dispose() {
    form.dispose();
    super.dispose();
  }

  FormGroup defaultValue(LocalRecipeModel? recipe) {
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
  didUpdateWidget(covariant RecipeEditorScreenForm oldWidget) {
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
          id: widget.recipe?.id);
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
                RecipeController remoteController =
                    context.read<RecipeController>();
                LocalRecipeController localController =
                    context.read<LocalRecipeController>();
                final userId = context.read<AuthProvider>().user!.id;
                try {
                  final recipe = await remoteController.put(widget.recipe!,
                      userId: userId);
                  await localController.setRemoteId(
                      widget.recipe!.id, recipe.id);
                  widget.onChanged(widget.recipe!.withRemoteId(null));
                  // ignore: use_build_context_synchronously
                  sendSuccess(context,
                      "Changes to ${widget.recipe!.title} has been published");
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

  void unpublish() {
    if (widget.recipe == null) return;
    showDialog(
        context: context,
        builder: (context) {
          return SimpleConfirmationDialog.delete(
              onConfirm: () async {
                final remoteController = context.read<RecipeController>();
                final localController = context.read<LocalRecipeController>();
                try {
                  if (widget.recipe!.remoteId != null) {
                    await remoteController.remove(widget.recipe!.remoteId!);
                  }
                  await localController.setRemoteId(widget.recipe!.id, null);
                  // ignore: use_build_context_synchronously
                  sendSuccess(context,
                      "${widget.recipe!.title} is no longer available to the public");
                  widget.onChanged(widget.recipe!.withRemoteId(null));
                } catch (e) {
                  // ignore: use_build_context_synchronously
                  sendError(context, e.toString());
                }
              },
              positiveText: Either.right("Unpublish"),
              message: Either.right(
                  "Are you sure you want to make this recipe private? Your recipe will no longer be available to the public."),
              context: context);
        });
  }

  void delete() async {
    if (widget.recipe == null) return;
    bool close = false;
    final navigator = Navigator.of(context);
    await showDialog(
        context: context,
        builder: (context) {
          return SimpleConfirmationDialog.delete(
              onConfirm: () async {
                try {
                  await context
                      .read<LocalRecipeController>()
                      .remove(widget.recipe!.id);
                  close = true;
                } catch (e) {
                  // ignore: use_build_context_synchronously
                  sendError(context, e.toString());
                }
              },
              positiveText: Either.right("Delete"),
              message:
                  Either.right("Are you sure you want to delete this recipe?"),
              context: context);
        });
    if (close) {
      navigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: OnlyReturnAppBar(
          actions: widget.recipe == null
              ? null
              : [
                  Tooltip(
                    message: "Publish Recipe",
                    child: IconButton(
                        onPressed: publish,
                        color: Theme.of(context).colorScheme.tertiary,
                        icon: const Icon(Icons.upload)),
                  ),
                  if (widget.recipe!.remoteId != null)
                    Tooltip(
                      message: "Make Recipe Private",
                      child: IconButton(
                        onPressed: unpublish,
                        color: context.colors.error,
                        icon: const Icon(Icons.file_upload_off),
                      ),
                    ),
                  Tooltip(
                    message: "Delete Recipe",
                    child: IconButton(
                        onPressed: delete,
                        color: context.colors.error,
                        icon: const Icon(Icons.delete)),
                  )
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
          child: const RecipeEditorScreenBody(),
        ));
  }
}
