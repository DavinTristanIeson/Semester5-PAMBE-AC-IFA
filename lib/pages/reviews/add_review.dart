import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/common/constants.dart';
import 'package:pambe_ac_ifa/components/app/snackbar.dart';
import 'package:pambe_ac_ifa/components/display/future.dart';
import 'package:pambe_ac_ifa/components/field/text_input.dart';
import 'package:pambe_ac_ifa/controllers/auth.dart';
import 'package:pambe_ac_ifa/controllers/review.dart';
import 'package:pambe_ac_ifa/pages/reviews/components/stars_input.dart';
import 'package:provider/provider.dart';
import 'package:reactive_forms/reactive_forms.dart';

enum _AddReviewFormKeys {
  rating,
  content,
}

class AddReviewSection extends StatefulWidget {
  const AddReviewSection({super.key});

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
          .sendError("Please resolve all errors before posting this review");
      return;
    }
    final reviewController = context.read<ReviewController>();
    final authProvider = context.read<AuthProvider>();
    final value = form.value;
    await reviewController.put(
        userId: authProvider.user!.uid,
        rating: value[_AddReviewFormKeys.rating.name] as int,
        content: value[_AddReviewFormKeys.content.name] as String?);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ReactiveValueListenableBuilder<int>(
            formControlName: _AddReviewFormKeys.rating.name,
            builder: (context, control, child) {
              return ReviewStarsInput(
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
                value: control.value,
                onChanged: (value) {
                  control.value = value;
                },
                label: "Review",
                placeholder: "What are your thoughts on this recipe?",
              );
            }),
        const SizedBox(height: AcSizes.space),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FutureButton(
                onPressed: postReview, child: const Text("Post Review"))
          ],
        ),
      ],
    );
  }
}
