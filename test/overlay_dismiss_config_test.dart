import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('OverlayDismissConfig.toMap', () {
    test('serializes defaults', () {
      expect(const OverlayDismissConfig().toMap(), {
        'icon': null,
        'size': 56.0,
        'bottomMargin': 40.0,
        'shape': 'circle',
        'borderRadius': 12.0,
        'backgroundColor': 0xCC333333.toSigned(32),
        'iconColor': -1, // 0xFFFFFFFF
        'iconSize': 22.0,
        'iconStrokeWidth': 4.0,
        'borderWidth': 0.0,
        'borderColor': 0,
        'activeBackgroundColor': 0xCC333333.toSigned(32),
        'activeIconColor': -1,
        'activeBorderColor': 0,
        'activeScale': 1.2,
        'hapticFeedback': true,
      });
    });

    test('converts colors to signed 32-bit ARGB ints', () {
      final map = const OverlayDismissConfig(
        backgroundColor: Color(0xFFE53935),
        iconColor: Color(0x80123456),
        borderColor: Color(0x00FFFFFF),
      ).toMap();

      for (final key in ['backgroundColor', 'iconColor', 'borderColor']) {
        final value = map[key] as int;
        expect(value, inInclusiveRange(-0x80000000, 0x7FFFFFFF), reason: key);
      }
      expect(map['backgroundColor'], 0xFFE53935.toSigned(32));
      expect(map['backgroundColor'], isNegative);
      expect(map['iconColor'], 0x80123456.toSigned(32));
      expect(map['borderColor'], 0x00FFFFFF);
    });

    test('accepts Material colors', () {
      final map = const OverlayDismissConfig(
        backgroundColor: Colors.red,
        iconColor: Colors.white,
      ).toMap();

      // ignore: deprecated_member_use
      expect(map['backgroundColor'], Colors.red.value.toSigned(32));
      expect(map['iconColor'], -1);
    });

    test('active colors fall back to the normal colors', () {
      final map = const OverlayDismissConfig(
        backgroundColor: Colors.blue,
        iconColor: Colors.black,
        borderColor: Colors.green,
      ).toMap();

      expect(map['activeBackgroundColor'], map['backgroundColor']);
      expect(map['activeIconColor'], map['iconColor']);
      expect(map['activeBorderColor'], map['borderColor']);
    });

    test('active colors override when set', () {
      final map = const OverlayDismissConfig(
        backgroundColor: Colors.blue,
        activeBackgroundColor: Colors.red,
        iconColor: Colors.black,
        activeIconColor: Colors.white,
        borderColor: Colors.green,
        activeBorderColor: Colors.yellow,
      ).toMap();

      // ignore: deprecated_member_use
      expect(map['activeBackgroundColor'], Colors.red.value.toSigned(32));
      expect(map['activeIconColor'], -1);
      // ignore: deprecated_member_use
      expect(map['activeBorderColor'], Colors.yellow.value.toSigned(32));
    });

    test('serializes custom values', () {
      final map = const OverlayDismissConfig(
        icon: 'ic_dismiss',
        size: 64,
        bottomMargin: 48,
        shape: OverlayDismissShape.rectangle,
        borderRadius: 16,
        iconSize: 24,
        iconStrokeWidth: 3,
        borderWidth: 2,
        activeScale: 1.5,
        hapticFeedback: false,
      ).toMap();

      expect(map['icon'], 'ic_dismiss');
      expect(map['size'], 64.0);
      expect(map['bottomMargin'], 48.0);
      expect(map['shape'], 'rectangle');
      expect(map['borderRadius'], 16.0);
      expect(map['iconSize'], 24.0);
      expect(map['iconStrokeWidth'], 3.0);
      expect(map['borderWidth'], 2.0);
      expect(map['activeScale'], 1.5);
      expect(map['hapticFeedback'], isFalse);
    });

    test('asserts on invalid values', () {
      expect(() => OverlayDismissConfig(size: 0), throwsAssertionError);
      expect(() => OverlayDismissConfig(bottomMargin: -1),
          throwsAssertionError);
      expect(() => OverlayDismissConfig(borderWidth: -1),
          throwsAssertionError);
      expect(() => OverlayDismissConfig(activeScale: 0.5),
          throwsAssertionError);
    });
  });

  group('FlutterOverlayWindow.showOverlay', () {
    const channel = MethodChannel('x-slayer/overlay_channel');
    final calls = <MethodCall>[];

    setUp(() {
      calls.clear();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
        calls.add(call);
        return null;
      });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test('sends a null dismissConfig when dismiss is disabled', () async {
      await FlutterOverlayWindow.showOverlay(enableDrag: true);

      final args = calls.single.arguments as Map;
      expect(calls.single.method, 'showOverlay');
      expect(args.containsKey('dismissConfig'), isTrue);
      expect(args['dismissConfig'], isNull);
    });

    test('sends the serialized dismissConfig', () async {
      const config = OverlayDismissConfig(
        shape: OverlayDismissShape.rectangle,
        backgroundColor: Colors.red,
      );
      await FlutterOverlayWindow.showOverlay(
        enableDrag: true,
        dismissConfig: config,
      );

      final args = calls.single.arguments as Map;
      expect(args['dismissConfig'], config.toMap());
    });

    test('dismissConfig survives the standard codec as 32-bit ints', () {
      const codec = StandardMethodCodec();
      final map = const OverlayDismissConfig(
        backgroundColor: Color(0xFFFFFFFF),
      ).toMap();
      final decoded = codec.decodeMethodCall(
        codec.encodeMethodCall(MethodCall('showOverlay', map)),
      );

      expect((decoded.arguments as Map)['backgroundColor'], -1);
    });
  });
}
