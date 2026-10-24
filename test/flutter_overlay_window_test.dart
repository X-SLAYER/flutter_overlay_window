import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('x-slayer/overlay_channel');
  final calls = <MethodCall>[];
  var active = true;

  setUp(() {
    calls.clear();
    active = true;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      switch (call.method) {
        case 'closeOverlay':
          active = false;
          return true;
        case 'isOverlayActive':
          return active;
        case 'checkPermission':
        case 'requestPermission':
          return true;
        case 'updateOverlay':
        case 'setOverlayVisible':
          return active;
        default:
          throw MissingPluginException('Unexpected method: ${call.method}');
      }
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('FlutterOverlayWindow', () {
    test('closeOverlay should close the overlay', () async {
      await FlutterOverlayWindow.closeOverlay();
      expect(await FlutterOverlayWindow.isActive(), isFalse);
    });

    if (defaultTargetPlatform == TargetPlatform.android) {
      test('isPermissionGranted should return a boolean', () async {
        final result = await FlutterOverlayWindow.isPermissionGranted();
        expect(result, isA<bool>());
      });
    }
    test('hide and show use visibility API without closing the service',
        () async {
      expect(
          await FlutterOverlayWindow.setOverlayVisible(visible: false), isTrue);
      expect(await FlutterOverlayWindow.isActive(), isTrue);
      expect(
          await FlutterOverlayWindow.setOverlayVisible(visible: true), isTrue);
      expect(calls.map((call) => call.method), [
        'setOverlayVisible',
        'isOverlayActive',
        'setOverlayVisible',
      ]);
      expect(calls.first.arguments, {'visible': false});
      expect(calls.last.arguments, {'visible': true});
    });

    test('atomic update sends one call with position, size and drag state',
        () async {
      expect(
          await FlutterOverlayWindow.updateOverlay(
            x: 20,
            y: 40,
            width: 320,
            height: 180,
            enableDrag: false,
          ),
          isTrue);
      expect(calls, hasLength(1));
      expect(calls.single.method, 'updateOverlay');
      expect(calls.single.arguments, {
        'x': 20,
        'y': 40,
        'width': 320,
        'height': 180,
        'enableDrag': false,
      });
    });

    test('atomic update preserves full-size sentinels for the native handler',
        () async {
      await FlutterOverlayWindow.updateOverlay(
        x: 0,
        y: 0,
        width: WindowSize.matchParent,
        height: WindowSize.fullCover,
        enableDrag: true,
      );
      expect(calls.single.arguments['width'], WindowSize.matchParent);
      expect(calls.single.arguments['height'], WindowSize.fullCover);
    });

    test('atomic update returns false when no overlay is running', () async {
      active = false;
      expect(
          await FlutterOverlayWindow.updateOverlay(
            x: 0,
            y: 0,
            width: 100,
            height: 100,
            enableDrag: true,
          ),
          isFalse);
    });

    test('visibility reports failure when no overlay is running', () async {
      active = false;
      expect(
          await FlutterOverlayWindow.setOverlayVisible(visible: true), isFalse);
    });

    test('requestPermission should return a boolean', () async {
      final result = await FlutterOverlayWindow.requestPermission();
      expect(result, isA<bool>());
    });
  });
}
