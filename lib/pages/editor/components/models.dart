import 'package:image_picker/image_picker.dart';
import 'package:pambe_ac_ifa/common/validation.dart';
import 'package:pambe_ac_ifa/components/field/form_array.dart';
import 'package:pambe_ac_ifa/models/recipe.dart';
import 'package:reactive_forms/reactive_forms.dart';

enum RecipeFormKeys {
  title,
  description,
  image,
  steps,
}

enum RecipeStepFormKeys {
  id,
  type,
  content,
  image,
  timer,
}

class RecipeStepFormType {
  int? id;
  RecipeStepVariant type;
  String content;
  XFile? image;
  Duration? timer;
  RecipeStepFormType(
      {this.id,
      required this.type,
      required this.content,
      this.image,
      this.timer});
  static FormGroup toFormGroup({LocalRecipeStepModel? value}) {
    return FormGroup({
      RecipeStepFormKeys.id.name: FormControl<int>(value: value?.id),
      RecipeStepFormKeys.type.name: FormControl<RecipeStepVariant>(
          value: value?.type ?? RecipeStepVariant.regular),
      RecipeStepFormKeys.content.name:
          FormControl<String?>(value: value?.content, validators: [
        Validators.required,
      ]),
      RecipeStepFormKeys.image.name: FormControl<InputToggle<XFile>>(
          value: value?.imagePath == null
              ? InputToggle.off()
              : InputToggle.on(XFile(value!.imagePath!)),
          validators: [
            Validators.delegate((control) {
              final value = control.value as InputToggle<XFile>?;
              if (value == null) return null;
              if (value.toggle && value.value == null) {
                return {AcValidationMessage.imageRequired: true};
              }
              return null;
            })
          ]),
      RecipeStepFormKeys.timer.name: FormControl<InputToggle<Duration>>(
          value: value?.timer == null
              ? InputToggle.off()
              : InputToggle.on(value!.timer!)),
    });
  }

  static RecipeStepFormType fromFormGroup(Map<String, Object?> group) {
    final thumbnailToggle =
        group[RecipeStepFormKeys.image.name] as InputToggle<XFile>;
    final timerToggle =
        group[RecipeStepFormKeys.timer.name] as InputToggle<Duration>;
    return RecipeStepFormType(
      id: group[RecipeStepFormKeys.id.name] as int?,
      type: group[RecipeStepFormKeys.type.name] as RecipeStepVariant,
      content: (group[RecipeStepFormKeys.content.name] as String?) ?? '',
      image: thumbnailToggle.toggle ? thumbnailToggle.value : null,
      timer: timerToggle.toggle ? timerToggle.value : null,
    );
  }
}
