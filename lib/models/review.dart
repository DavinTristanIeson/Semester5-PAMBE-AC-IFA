import 'package:pambe_ac_ifa/models/user.dart';

class Review {
  String? content;
  DateTime reviewedAt;
  double rating;
  User reviewer;
  Review(
      {this.content,
      required this.reviewedAt,
      required this.rating,
      required this.reviewer});
}
