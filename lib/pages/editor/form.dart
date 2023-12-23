import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pambe_ac_ifa/common/extensions.dart';
import 'package:pambe_ac_ifa/components/app/app_bar.dart';
import 'package:pambe_ac_ifa/components/app/confirmation.dart';
import 'package:pambe_ac_ifa/components/app/snackbar.dart';
import 'package:pambe_ac_ifa/components/display/future.dart';
import 'package:pambe_ac_ifa/components/function/future.dart';
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
import 'package:localization/localization.dart';

class RecipeEditorScreenForm extends StatefulWidget {
  final LocalRecipeModel? recipe;
  final void Function(LocalRecipeModel recipe) onChanged;
  const RecipeEditorScreenForm(
      {super.key, this.recipe, required this.onChanged});

  @override
  State<RecipeEditorScreenForm> createState() => _RecipeEditorScreenFormState();
}

class _RecipeEditorScreenFormState extends State<RecipeEditorScreenForm> {
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

  Future<void> save() async {
    final controller = context.read<LocalRecipeController>();
    final messenger = AcSnackbarMessenger.of(context);
    if (form.invalid) {
      messenger.sendError("screen/editor/form/resolve_all_erorrs".i18n());
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
          image: image,
          id: widget.recipe?.id);
      form.markAsPristine();
      widget.onChanged(recipe);
      messenger.sendSuccess("$title (screen/editor/form/saved_locally)".i18n());
    } catch (e) {
      messenger.sendError(e);
    }
  }

  Future<void> publish() async {
    final messenger = AcSnackbarMessenger.of(context);

    if (form.invalid || form.dirty || widget.recipe == null) {
      messenger.sendError("screen/editor/form/changes_to_recipe".i18n());
      return;
    }

    await showDialog(
        context: context,
        builder: (context) {
          return SimpleConfirmationDialog(
              onConfirm: () async {
                RecipeController remoteController =
                    context.read<RecipeController>();
                LocalRecipeController localController =
                    context.read<LocalRecipeController>();
                try {
                  final recipe = await remoteController.put(
                    widget.recipe!,
                  );
                  await localController.setRemoteId(
                      widget.recipe!.id, recipe.id);
                  messenger.sendSuccess(
                      "screen/editor/form/published_changes_to_extra"
                          .i18n([widget.recipe!.title]));
                  // "Changes to ${widget.recipe!.title} has been published");
                  widget.onChanged(widget.recipe!.withRemoteId(recipe.id));
                } on ApiError catch (e) {
                  messenger.sendError(e.message);
                }
              },
              context: context,
              positiveText: Either.right("screen/editor/form/publish".i18n()),
              title: Either.right(" screen/editor/form/publish_extra".i18n([widget.recipe!.title])),
              message: Either.right(
                  "screen/editor/form/want_publish_your_recipe".i18n()));
        });
  }

  Future<void> unpublish() async {
    if (widget.recipe == null) return Future.value();
    final messenger = AcSnackbarMessenger.of(context);
    await showDialog(
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
                  messenger.sendSuccess(
                      "screen/editor/form/available_to_the_public".i18n([widget.recipe!.title]));
                  widget.onChanged(widget.recipe!.withRemoteId(null));
                } catch (e) {
                  messenger.sendError(e);
                }
              },
              positiveText: Either.right("screen/editor/form/unpublish".i18n()),
              message: Either.right(
                  "screen/editor/form/make_this_recipe_private".i18n()),
              context: context);
        });
  }

  Future<void> delete() async {
    if (widget.recipe == null) return;
    bool close = false;
    final navigator = Navigator.of(context);
    final messenger = AcSnackbarMessenger.of(context);
    await showDialog(
        context: context,
        builder: (context) {
          final LocalRecipeController localRecipeController =
              context.read<LocalRecipeController>();
          final RecipeController recipeController =
              context.read<RecipeController>();
          return SimpleConfirmationDialog.delete(
              onConfirm: () async {
                try {
                  await localRecipeController.remove(widget.recipe!.id);
                  if (widget.recipe?.remoteId != null) {
                    await recipeController.remove(widget.recipe!.remoteId!);
                  }
                  close = true;
                  messenger.sendSuccess(
                      "screen/editor/form/success_delete".i18n([widget.recipe!.title]));
                } catch (e) {
                  messenger.sendError(e);
                }
              },
              positiveText: Either.right("components/app/confirmation/delete".i18n()),
              message: Either.right(
                  "screen/editor/form/want_delete_this_recipe".i18n()),
              context: context);
        });
    if (close) {
      navigator.pop();
    }
  }

  Future<void> sync() async {
    final localController = context.read<LocalRecipeController>();
    final remoteController = context.read<RecipeController>();
    final messenger = AcSnackbarMessenger.of(context);
    bool isAccept = false;
    await showDialog(
        context: context,
        builder: (context) {
          return SimpleConfirmationDialog(
            onConfirm: () {
              isAccept = true;
            },
            context: context,
            message: Either.right(
                "screen/editor/form/want_to_sync_changes".i18n()),
            positiveText: Either.right("screen/editor/form/sync".i18n()),
          );
        });
    if (!isAccept) return;
    // ignore: use_build_context_synchronously
    await showDialog(
        context: context,
        builder: (context) {
          final navigator = Navigator.of(context);
          Future(() async {
            try {
              final recipe =
                  await remoteController.get(widget.recipe!.remoteId!);
              if (recipe == null) {
                messenger.sendError(
                    "screen/editor/form/failed_recipe_with_that_id".i18n());
                return;
              }
              final result = await localController.syncLocal(
                recipe,
                id: widget.recipe!.id,
              );
              messenger.sendSuccess(
                  "screen/editor/form/success_sync_change".i18n());
              widget.onChanged(result);
            } catch (e) {
              messenger.sendError(e);
            }
            navigator.pop();
          });
          return const Center(
            child: CircularProgressIndicator(),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: OnlyReturnAppBar(
          actions: widget.recipe == null
              ? null
              : [
                  Tooltip(
                    message: "screen/editor/form/publish_recipe".i18n(),
                    child: FutureIconButton(
                        onPressed: publish,
                        icon:
                            Icon(Icons.upload, color: context.colors.tertiary)),
                  ),
                  if (widget.recipe!.remoteId != null)
                    Tooltip(
                      message: "screen/editor/form/recipe_private".i18n(),
                      child: FutureIconButton(
                        onPressed: unpublish,
                        icon: Icon(Icons.file_upload_off,
                            color: context.colors.error),
                      ),
                    ),
                  if (widget.recipe!.remoteId != null)
                    Tooltip(
                      message: "screen/editor/form/sync_extra".i18n(),
                      child: FutureIconButton(
                        onPressed: sync,
                        icon: Icon(Icons.sync, color: context.colors.tertiary),
                      ),
                    ),
                  Tooltip(
                    message: "screen/editor/form/delete_recipe".i18n(),
                    child: FutureIconButton(
                        onPressed: delete,
                        icon: Icon(Icons.delete, color: context.colors.error)),
                  )
                ],
        ),
        floatingActionButton: Tooltip(
          message: "screen/editor/form/save".i18n(),
          child: FutureButtonCompute(
              onPressed: save,
              icon: const Icon(Icons.save),
              builder: (context, remote) {
                return FloatingActionButton(
                  onPressed: remote.call,
                  child: remote.icon,
                );
              }),
        ),
        body: ReactiveForm(
          formGroup: form,
          child: const RecipeEditorScreenBody(),
        ));
  }
}
