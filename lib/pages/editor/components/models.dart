import 'package:image_picker/image_picker.dart';
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
  type,
  content,
  image,
  timer,
}

class RecipeStepFormType {
  RecipeStepVariant variant;
  String content;
  XFile? thumbnail;
  Duration? timer;
  RecipeStepFormType(this.variant,
      {required this.content, this.thumbnail, this.timer});
  static FormGroup toFormGroup({RecipeStep? value}) {
    return FormGroup({
      RecipeStepFormKeys.type.name: FormControl<RecipeStepVariant>(
          value: value?.type ?? RecipeStepVariant.regular),
      RecipeStepFormKeys.content.name:
          FormControl<String?>(value: value?.content, validators: [
        Validators.required,
      ]),
      RecipeStepFormKeys.image.name: FormControl<InputToggle<XFile>>(
          value: value?.imagePath == null
              ? InputToggle.off()
              : InputToggle.on(XFile(value!.imagePath!))),
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
      group[RecipeStepFormKeys.type.name] as RecipeStepVariant,
      content: (group[RecipeStepFormKeys.content.name] as String?) ?? '',
      thumbnail: thumbnailToggle.toggle ? thumbnailToggle.value : null,
      timer: timerToggle.toggle ? timerToggle.value : null,
    );
  }
}
