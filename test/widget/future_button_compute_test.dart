import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pambe_ac_ifa/components/function/future.dart';

void main() {
  testWidgets("Test finder", (tester) async {
    const key = ValueKey("future-button-indicator");
    const indicator = CircularProgressIndicator(key: key);
    await tester.pumpWidget(MaterialApp(
        home: FutureButtonCompute(
            onPressed: () {
              // print("Pressed");
              return Future.delayed(const Duration(seconds: 1));
            },
            progressIndicator: indicator,
            builder: (context, remote) {
              // print("Loading: ${remote.isLoading}");
              return ElevatedButton.icon(
                  key: const ValueKey("button"),
                  onPressed: remote.call,
                  icon: remote.icon ?? const Icon(Icons.abc),
                  label: const Text("Press Button"));
            })));

    await tester.tap(find.byKey(const ValueKey("button")));

    await tester.pump();
    expect(find.byKey(key), findsOneWidget);
    await tester.pumpAndSettle();
  });
}
