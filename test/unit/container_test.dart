import 'package:pambe_ac_ifa/models/container.dart';
import 'package:test/test.dart';

void main() {
  group("Either should contain either A or B, but not both at the same time",
      () {
    final either = Either<double, bool>.left(3.14);
    final opposite = Either<double, bool>.right(false);
    test("Unavailable value should trigger an error when accessed", () {
      expect(either.left, 3.14);
      expect(() => either.right, throwsA(isA<TypeError>()));
      expect(() => opposite.left, throwsA(isA<TypeError>()));
      expect(opposite.right, false);
    });

    test(
        "Value availability can be checked with hasLeft or hasRight. Both should always be opposites of each other",
        () {
      expect(either.hasLeft, true);
      expect(either.hasRight, false);
      expect(opposite.hasLeft, false);
      expect(opposite.hasRight, true);
    });

    test(
        "You can get whichever value for convenience's sake, but there's no type guarantee.",
        () {
      expect(either.whichever, isA<double>());
      expect(opposite.whichever, isA<bool>());
    });

    test(
        "The .<>Or methods can be used to get value of a particular type, or transform the other one into a value of said type",
        () {
      expect(either.leftOr((right) => 0.0), 3.14);
      expect(either.rightOr((left) => left >= 3.0), true);
      expect(opposite.leftOr((right) => 0.0), 0.0);
      expect(opposite.rightOr((left) => left >= 3.0), false);
    });
  });

  group("Optional refers a value that might not exist, but also might be null.",
      () {
    int transform(value) {
      return value * 2;
    }

    int fallback() {
      return 3;
    }

    test(
        "Optional.none doesn't have value, but Optional.some with null value has a value",
        () {
      final optional = Optional.some(null);
      expect(optional.hasValue, true);
      expect(optional.value, null);
      final none = Optional.none();
      expect(none.hasValue, false);
      expect(none.value, null);
    });

    test(
        "Optional value can be accessed with a fallback if the value doesn't exist",
        () {
      final opt1 = Optional<int>.none(),
          opt2 = Optional<int>.some(2),
          opt3 = Optional<int?>.some(null);

      expect(opt1.or(fallback), 3);
      expect(opt2.or(fallback), 2);
      expect(opt3.or(fallback), null);
      expect(Optional.valueOf(opt1, otherwise: fallback), 3);
      expect(Optional.valueOf(opt2, otherwise: fallback), 2);
      expect(Optional.valueOf(opt3, otherwise: fallback), null);
      expect(Optional.runIfExist(opt1, then: transform), null);
      expect(Optional.runIfExist(opt2, then: transform), 4);
    });

    test(
        "Optional value can be repackaged/transformed into another optional value if the value exists, otherwise it stays as a None",
        () {
      expect(Optional.some(2).encase(transform).value, 4);
      expect(Optional.none().encase(transform).hasValue, false);
    });

    test("Many optional values can be collected into only available values",
        () {
      final optionals = List.generate(
          5,
          (index) => (index + 1) % 2 == 0
              ? Optional.none()
              : Optional.some(index + 1));
      expect(Optional.allWithValue(optionals, then: transform),
          containsAllInOrder([2, 6, 10]));
      expect(
          Optional.allWithValue(optionals,
              then: transform, otherwise: fallback),
          containsAllInOrder([2, 3, 6, 3, 10]));
    });
  });
}
