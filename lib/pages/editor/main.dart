import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pambe_ac_ifa/common/constants.dart';
import 'package:pambe_ac_ifa/components/app/app_bar.dart';
import 'package:pambe_ac_ifa/components/app/snackbar.dart';
import 'package:pambe_ac_ifa/components/field/form_array.dart';
import 'package:pambe_ac_ifa/pages/editor/step_editor.dart';
import 'package:pambe_ac_ifa/pages/editor/title.dart';
import 'package:pambe_ac_ifa/controllers/local_store.dart';
import 'package:provider/provider.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:pambe_ac_ifa/common/validation.dart';

class RecipeEditorPage extends StatefulWidget {
  const RecipeEditorPage({super.key});

  @override
  State<RecipeEditorPage> createState() => _RecipeEditorPageState();
}

class _RecipeEditorPageState extends State<RecipeEditorPage>
    with SnackbarMessenger {
  late final FormGroup form;
  late final ScrollController _scroll;

  @override
  void initState() {
    super.initState();
    _scroll = ScrollController();
    form = FormGroup({
      'title': FormControl<String>(value: '', validators: [
        Validators.minLength(5),
        AcValidators.acceptedChars,
      ]),
      'description': FormControl<String>(value: '', validators: [
        Validators.required,
      ]),
      'thumbnail': FormControl<XFile?>(),
      'steps': FormArray([
        RecipeStepFormType.toFormGroup(),
      ], validators: [
        Validators.minLength(1),
      ]),
    });
  }

  void save(BuildContext context) async {
    LocalRecipeController controller =
        Provider.of<LocalRecipeController>(context, listen: false);
    final steps = (form.value['steps'] as List<Map<String, Object?>?>)
        .map((step) => RecipeStepFormType.fromFormGroup(step!))
        .toList();
    try {
      await controller.create(
          title: form.value['title'].toString(),
          description: form.value['description']?.toString(),
          steps: steps);
    } catch (e) {
      // ignore: use_build_context_synchronously
      sendError(context, e.toString());
    }
  }

  void publish() {}

  Widget buildAddStepButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AcSizes.lg),
      child: Center(
        child: ElevatedButton.icon(
          onPressed: () {
            setState(() {
              final formArray = form.controls["steps"] as FormArray;
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
    final FormArray formArray = form.controls["steps"] as FormArray;
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
    bool shouldRerender = fn(form.controls["steps"] as FormArray);
    if (shouldRerender) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return AcReactiveFormConfig(
      child: Scaffold(
          appBar: OnlyReturnAppBar(
            actions: [
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
              onPressed: () {
                save(context);
              },
              child: const Icon(Icons.save),
            ),
          ),
          body: ReactiveForm(
            formGroup: form,
            child: FormArrayController(
                mutate: handleMutate, child: buildScroll(context)),
          )),
    );
  }
}
