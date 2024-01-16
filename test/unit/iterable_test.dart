import 'package:pambe_ac_ifa/common/extensions.dart';
import 'package:test/test.dart';

void main() {
  group("Set", () {
    test(
        ".containsAny should return true if the set contains any of the candidates",
        () {
      final set = {1, 2, 3, 4, 5};
      expect(set.containsAny({1, 2, 9}), true);
      expect(set.containsAny({1, 2, 3, 4, 5}), true);
      expect(set.containsAny({}), false);
      expect(set.containsAny({7, 8, 9}), false);
    });
    test(".containsAny should always return false if the set is empty", () {
      final Set set = {};
      expect(set.containsAny({}), false);
    });
  });

  group("Map", () {
    test(".addEntry should add a new entry to the map", () {
      final map = <int, int>{};
      map.addEntry(const MapEntry(1, 1));
      expect(map.containsKey(1), true);
      expect(map.containsKey(2), false);
    });
  });
  group("Iterable", () {
    final list = List.generate(5, (index) => (a: index + 1, b: 5 - index));
    final list2 = List.generate(5, (index) => index + 1);
    test(".find should find the first element that matches the condition", () {
      expect(list.find((element) => element.a == 3), (a: 3, b: 3));
      expect(list.find((element) => element.a == 6), null);
    });
    test(
        ".exists should check if any element that matches the condition exists in the iterable",
        () {
      expect(list.exists((element) => element.a == 7), false);
      expect(list.exists((element) => element.a == 4), true);
    });
    test(
        ".categorize should separate the iterable into several categories according to the condition",
        () {
      final [even, odd] = list.categorize((element) => element.a % 2, 2);
      expect(even.length, 2);
      expect(odd.length, 3);
    });
    test('.categorize when the categorize is empty ', () {
      final [a, b] = <int>[].categorize((element) => element % 2, 2);
      expect(a.length, 0);
      expect(b.length, 0);
      expect(
        () {
          [1, 2, 3].categorize((element) => element % 2, 0);
        },
        throwsA(isA<RangeError>()),
      );
    });
    test(".chunks check the chunks", () {
      expect(list2.chunks(2).length, 3);
      expect(list2.chunks(2).toList(), [
        [1, 2],
        [3, 4],
        [5]
      ]);
    });
    test(".notNull look for one that is not empty", () {
      expect([0, null, 1, null, 2].notNull().length, 3);
      expect([null, null].notNull().length, 0);
    });
  });
  group("String", () {
    test(".ellipsisIfExceed when the function is read it will become ...  ", () {
      expect("Hello".ellipsisIfExceed(3), "He...");
      expect("llo".ellipsisIfExceed(1), "llo");
      expect("ll".ellipsisIfExceed(1), "ll");
      expect("".ellipsisIfExceed(4), "");
      expect("Hello".ellipsisIfExceed(5), "Hello");
    });
  });
}
