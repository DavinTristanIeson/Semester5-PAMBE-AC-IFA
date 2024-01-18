import 'package:flutter/material.dart';
import 'package:localization/localization.dart';
import 'package:pambe_ac_ifa/common/constants.dart';
import 'package:pambe_ac_ifa/common/extensions.dart';
import 'package:pambe_ac_ifa/components/app/snackbar.dart';
import 'package:pambe_ac_ifa/components/display/future.dart';
import 'package:pambe_ac_ifa/components/field/text_input.dart';
import 'package:pambe_ac_ifa/controllers/notification.dart';
import 'package:pambe_ac_ifa/controllers/review.dart';
import 'package:pambe_ac_ifa/models/notification.dart';
import 'package:pambe_ac_ifa/models/recipe.dart';
import 'package:pambe_ac_ifa/models/review.dart';
import 'package:pambe_ac_ifa/pages/reviews/components/stars_input.dart';
import 'package:provider/provider.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:pambe_ac_ifa/common/validation.dart';

enum _AddReviewFormKeys {
  rating,
  content,
}

class AddReviewSection extends StatefulWidget {
  final RecipeLiteModel recipe;
  final void Function() onReviewed;
  const AddReviewSection(
      {super.key, required this.recipe, required this.onReviewed});

  @override
  State<AddReviewSection> createState() => _AddReviewSectionState();
}

class _AddReviewSectionState extends State<AddReviewSection> {
  late final FormGroup form;
  @override
  void initState() {
    form = FormGroup({
      _AddReviewFormKeys.rating.name: FormControl<int>(
        validators: [
          Validators.required,
          Validators.min(0),
          Validators.max(5),
        ],
      ),
      _AddReviewFormKeys.content.name: FormControl<String?>(),
    });
    super.initState();
  }

  @override
  void dispose() {
    form.dispose();
    super.dispose();
  }

  Future<void> postReview() async {
    final messenger = AcSnackbarMessenger.of(context);
    if (form.invalid) {
      messenger
          .sendError("screen/reviews/add_review/resolve_error_posting".i18n());
      return;
    }
    final reviewController = context.read<ReviewController>();
    final notificationController = context.read<NotificationController>();
    final value = form.value;
    ReviewModel review;
    try {
      review = await reviewController.put(
          recipeId: widget.recipe.id,
          rating: value[_AddReviewFormKeys.rating.name] as int,
          content: value[_AddReviewFormKeys.content.name] as String?);
      messenger.sendSuccess("screen/reviews/add_review/review_posted".i18n());
      form.reset();
    } catch (e) {
      messenger.sendError(e);
      return;
    }
    if (widget.recipe.user == null) {
      widget.onReviewed();
      return;
    }
    try {
      await notificationController.notify(
          targetUserId: widget.recipe.user!.id,
          notification: NotificationPayload.review(
              // Notification message should not be translated by sender, but no time to fix. Just make it all English.
              title:
                  "${review.user?.name ?? 'A user'} reviewed your recipe, ${widget.recipe.title}",
              // "screen/reviews/add_review/reviewed_recipe".i18n([review.user?.name ?? 'A user', widget.recipe.title]),
              reviewId: review.id,
              recipeId: widget.recipe.id,
              content: review.content,
              rating: review.rating));
      widget.onReviewed();
    } catch (e) {
      messenger.sendError(e);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ReactiveForm(
      formGroup: form,
      child: Container(
        decoration: BoxDecoration(color: context.colors.background),
        padding: const EdgeInsets.symmetric(horizontal: AcSizes.space),
        child: Column(
          children: [
            ReactiveValueListenableBuilder<int>(
                formControlName: _AddReviewFormKeys.rating.name,
                builder: (context, control, child) {
                  return ReviewStarsInput(
                      iconSize: 36,
                      value: control.value ?? 0,
                      onChanged: (value) {
                        control.value = value;
                      });
                }),
            const SizedBox(
              height: AcSizes.space,
            ),
            ReactiveValueListenableBuilder<String?>(
                formControlName: _AddReviewFormKeys.content.name,
                builder: (context, control, child) {
                  return AcTextInput(
                    error: ReactiveFormConfig.of(context)
                        ?.translateAny(control.errors),
                    value: control.value,
                    onChanged: (value) {
                      control.value = value;
                    },
                    label: "screen/reviews/add_review/review".i18n(),
                    placeholder:
                        "screen/reviews/add_review/your_thoughts_recipe".i18n(),
                  );
                }),
            const SizedBox(height: AcSizes.space),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ReactiveFormConsumer(builder: (context, control, child) {
                  final button = FutureButton(
                      onPressed: control.invalid ? null : postReview,
                      child:
                          Text("screen/reviews/add_review/post_review".i18n()));
                  if (control.hasErrors) {
                    return Tooltip(
                        message: "screen/reviews/add_review/rating".i18n(),
                        child: button);
                  } else {
                    return button;
                  }
                })
              ],
            ),
          ],
        ),
      ),
    );
  }
}
