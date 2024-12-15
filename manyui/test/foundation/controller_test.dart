import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manyui/manyui.dart';

void main() {
  group('MController', () {
    test('initial value is what was passed to the constructor', () {
      final MController<int> c = MController<int>(7);
      expect(c.value, 7);
      c.dispose();
    });

    test('setting a new value notifies listeners', () {
      final MController<bool> c = MController<bool>(false);
      int calls = 0;
      c.addListener(() => calls++);

      c.value = true;
      expect(c.value, true);
      expect(calls, 1);

      c.value = false;
      expect(calls, 2);

      c.dispose();
    });

    test('setting an equal value does not notify', () {
      final MController<int> c = MController<int>(3);
      int calls = 0;
      c.addListener(() => calls++);

      c.value = 3;
      expect(calls, 0);

      c.dispose();
    });

    test('dispose disables further listener calls', () {
      final MController<int> c = MController<int>(0);
      c.dispose();
      // Calling notifyListeners on a disposed ChangeNotifier throws; we
      // just check the dispose itself completes without error and that the
      // controller refuses subsequent addListener calls.
      expect(
        () => c.addListener(() {}),
        throwsFlutterError,
      );
    });

    test(
        'fromValueListenable mirrors the source value and notifies on changes',
        () {
      final ValueNotifier<String> source = ValueNotifier<String>('a');
      final MController<String> wrapper =
          MController.fromValueListenable(source);

      expect(wrapper.value, 'a');

      int calls = 0;
      wrapper.addListener(() => calls++);

      source.value = 'b';
      expect(wrapper.value, 'b');
      expect(calls, 1);

      // No-op on equal value.
      source.value = 'b';
      expect(calls, 1);

      wrapper.dispose();
      source.dispose();
    });

    test('fromValueListenable wrapper is read-only', () {
      final ValueNotifier<int> source = ValueNotifier<int>(10);
      final MController<int> wrapper =
          MController.fromValueListenable(source);

      int wrapperCalls = 0;
      wrapper.addListener(() => wrapperCalls++);

      wrapper.value = 999;
      expect(source.value, 10, reason: 'wrapper.value=... must not write back');
      expect(wrapper.value, 10);
      expect(wrapperCalls, 0);

      wrapper.dispose();
      source.dispose();
    });

    test(
        'fromValueListenable wrapper dispose detaches the listener but does '
        'not dispose the source', () {
      final ValueNotifier<int> source = ValueNotifier<int>(0);
      final MController<int> wrapper =
          MController.fromValueListenable(source);

      wrapper.dispose();

      // The source must still be usable.
      source.value = 5;
      expect(source.value, 5);

      source.dispose();
    });
  });
}
