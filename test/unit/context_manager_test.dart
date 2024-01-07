import 'dart:math';

import 'package:pambe_ac_ifa/common/context_manager.dart';
import 'package:test/test.dart';

void main() {
  test(
      "Context Manager should call onOpen and onClose when the context is started and ended.",
      () async {
    bool isInContext = false;
    final context = ContextManager(
        id: 'context',
        onOpen: () {
          isInContext = true;
        },
        onClose: (_) {
          isInContext = false;
        });
    await context.run((_) {
      expect(isInContext, true);
    });
    expect(isInContext, false);
  });

  test(
      "Context Manager should pass value from onOpen to onClose and run for controlling and cleaning up context",
      () async {
    final rng = Random();
    double randomNumber = rng.nextDouble();
    double randomNumberCopy = randomNumber;
    final context = ContextManager(
        id: "context",
        onOpen: () {
          double oldNumber = randomNumber;
          randomNumber = rng.nextDouble();
          return oldNumber;
        },
        onClose: (oldNumber) {
          expect(oldNumber, randomNumberCopy);
          randomNumber = oldNumber;
        });
    await context.run((_) {
      expect(randomNumber, isNot(equals(randomNumberCopy)));
    });
    expect(randomNumber, randomNumberCopy);
  });

  group("Merged context manager should work together", () {
    int onOpenCalled = 0;
    int onCloseCalled = 0;
    void onOpen() {
      onOpenCalled++;
    }

    void onClose(_) {
      onCloseCalled++;
    }

    final context1 = ContextManager(id: '1', onOpen: onOpen, onClose: onClose);
    final context2 = ContextManager(id: '2', onOpen: onOpen, onClose: onClose);
    final context3 = ContextManager(id: '3', onOpen: onOpen, onClose: onClose);

    setUp(() {
      onOpenCalled = 0;
      onCloseCalled = 0;
    });
    test("Merged context Manager should call all onOpen and onClose callbacks",
        () async {
      await context1.merge([context2, context3]).run((initial) => null);
      expect(onOpenCalled, 3);
      expect(onCloseCalled, 3);
    });

    test(
        "Merged context manager should merge their initial values according to the key of the contexts",
        () async {
      final context = context1.merge([context2, context3]);
      await context.run((initial) {
        expect(initial.map.keys, containsAll({'1', '2', '3'}));
      });
    });
  });
}
