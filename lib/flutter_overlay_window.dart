import 'dart:async';
import 'dart:developer';

import 'package:flutter/services.dart';

const int _defaultWidth = -1;
const int _defaultHeight = -1;

class FlutterOverlayWindow {
  FlutterOverlayWindow._();

  static final StreamController _controller = StreamController();
  static const MethodChannel _channel =
      MethodChannel("x-slayer/overlay_channel");
  static const MethodChannel _overlayChannel =
      MethodChannel("x-slayer/overlay");
  static const BasicMessageChannel _overlayMessageChannel =
      BasicMessageChannel("x-slayer/overlay_messenger", JSONMessageCodec());

  /// Open overLay content
  ///
  /// - Optional arguments:
  /// `height` the overlay height and default is [overlaySizeFill]
  /// `width` the overlay width and default is [overlaySizeFill]
  /// `OverlayAlignment` the alignment postion on screen and default is [OverlayAlignment.center]
  /// `OverlayFlag` the overlay flag and default is [OverlayFlag.flagNotFocusable]
  /// `overlayMessage the notification message and default is "overlay activated"
  /// `enableDrag` to enable/disable dragging the overlay over the screen and default is "false"
  static Future<void> showOverlay({
    int height = _defaultHeight,
    int width = _defaultWidth,
    OverlayAlignment alignment = OverlayAlignment.center,
    OverlayFlag flag = OverlayFlag.flagNotFocusable,
    String overlayMessage = "overlay activated",
    bool enableDrag = false,
  }) async {
    await _channel.invokeMethod('showOverlay', {
      "height": height,
      "width": width,
      "alignment": alignment.name,
      "flag": flag.name,
      "overlayMessage": overlayMessage,
      "enableDrag": enableDrag
    });
  }

  /// check if overlay permission is granted
  static Future<bool> isPermissionGranted() async {
    try {
      return await _channel.invokeMethod<bool>('checkPermission') ?? false;
    } on PlatformException catch (error) {
      log("$error");
      return Future.value(false);
    }
  }

  /// request overlay permission
  /// it will open the overlay settings page and return `true` once the permission granted.
  static Future<bool?> requestPermession() async {
    try {
      return await _channel.invokeMethod<bool?>('requestPermission');
    } on PlatformException catch (error) {
      log("Error requestPermession: $error");
      rethrow;
    }
  }

  /// closes overlay if open
  static Future<bool?> closeOverlay() async {
    final bool? _res = await _overlayChannel.invokeMethod('close');
    return _res;
  }

  /// broadcast data to and from overlay app
  static Future shareData(dynamic data) async {
    return await _overlayMessageChannel.send(data);
  }

  /// streams message shared between overlay and main app
  static Stream<dynamic> get overlayListener {
    _overlayMessageChannel.setMessageHandler((message) async {
      _controller.add(message);
      return message;
    });
    return _controller.stream;
  }

  /// dispose overlay stream
  static void disposeOverlayListener() {
    _controller.close();
  }
}

enum OverlayAlignment {
  topLeft,
  topCenter,
  topRight,
  centerLeft,
  center,
  centerRight,
  bottomLeft,
  bottomCenter,
  bottomRight
}

enum OverlayFlag {
  /// Window flag: this window can never receive touch events.
  /// usefull if you want to display click-through overlay
  /// wrap you overlay widget with [IgnorePointer] if you want to use this
  flagNotTouchable,

  /// Window flag: this window won't ever get key input focus, so the user can not send key or other button events to it
  flagNotFocusable
}
