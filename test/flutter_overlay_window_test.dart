import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

void main() {
  const MethodChannel channel = MethodChannel('flutter_overlay_window');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await FlutterOverlayWindow.isPermissionGranted(), '42');
  });
}
