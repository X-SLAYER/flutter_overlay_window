import 'dart:async';
import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:flutter_overlay_window/src/models/overlay_position.dart';
import 'package:flutter_overlay_window/src/overlay_config.dart';

class FlutterOverlayWindow {
  FlutterOverlayWindow._();

  static final _controller = StreamController<dynamic>.broadcast();
  static final _controllerOverlayStatus = StreamController<bool>.broadcast();

  static const _channel = MethodChannel("x-slayer/overlay_channel");
  static const _overlayChannel = MethodChannel("x-slayer/overlay");
  static const _overlayMessageChannel =
      MethodChannel("x-slayer/overlay_messenger", JSONMethodCodec());

  /// Open overLay content
  ///
  /// - Optional arguments:
  ///
  /// `height` the overlay height and default is [WindowSize.fullCover]
  ///
  /// `width` the overlay width and default is [WindowSize.matchParent]
  ///
  /// `alignment` the alignment postion on screen and default is [OverlayAlignment.center]
  ///
  /// `visibilitySecret` the detail displayed in notifications on the lock screen and default is [NotificationVisibility.visibilitySecret]
  ///
  /// `OverlayFlag` the overlay flag and default is [OverlayFlag.defaultFlag]
  ///
  /// `overlayTitle` the notification message and default is "overlay activated"
  ///
  /// `overlayContent` the notification message
  ///
  /// `enableDrag` to enable/disable dragging the overlay over the screen and default is "false"
  ///
  /// `positionGravity` the overlay postion after drag and default is [PositionGravity.none]
  ///
  /// `startPosition` the overlay start position and default is null
  static Future<void> showOverlay({
    int height = WindowSize.fullCover,
    int width = WindowSize.matchParent,
    OverlayAlignment alignment = OverlayAlignment.center,
    NotificationVisibility visibility = NotificationVisibility.visibilitySecret,
    OverlayFlag flag = OverlayFlag.defaultFlag,
    String overlayTitle = "overlay activated",
    String? overlayContent,
    bool enableDrag = false,
    PositionGravity positionGravity = PositionGravity.none,
    OverlayPosition? startPosition,
  }) async {
    await _channel.invokeMethod(
      'showOverlay',
      {
        "height": height,
        "width": width,
        "alignment": alignment.name,
        "flag": flag.name,
        "overlayTitle": overlayTitle,
        "overlayContent": overlayContent,
        "enableDrag": enableDrag,
        "notificationVisibility": visibility.name,
        "positionGravity": positionGravity.name,
        "startPosition": startPosition?.toMap(),
      },
    );
  }

  /// Check if overlay permission is granted
  static Future<bool> isPermissionGranted() async {
    try {
      return await _channel.invokeMethod<bool>('checkPermission') ?? false;
    } on PlatformException catch (error) {
      log("$error");
      return Future.value(false);
    }
  }

  /// Request overlay permission
  /// it will open the overlay settings page and return `true` once the permission granted.
  static Future<bool?> requestPermission() async {
    try {
      return await _channel.invokeMethod<bool?>('requestPermission');
    } on PlatformException catch (error) {
      log("Error requestPermession: $error");
      rethrow;
    }
  }

  /// Closes overlay if open
  static Future<bool?> closeOverlay() async {
    final bool? _res = await _channel.invokeMethod('closeOverlay');
    return _res;
  }

  /// Broadcast [data] to and from overlay app.
  ///
  /// If `true` is returned, it indicates that the [data] was sent. However, this doesn't mean
  /// that the [data] has already reached the listeners of the [overlayListener] stream.
  ///
  /// If `false` is returned, it indicates that the [data] was not sent.
  ///
  /// This method may return `false` when invoked from the overlay while the application is closed.
  ///
  /// Returns `true` if the [data] was sent successfully, otherwise `false`.
  static Future<bool> shareData(dynamic data) async {
    final isSent = await _overlayMessageChannel.invokeMethod('', data);
    return isSent as bool;
  }

  /// Streams message shared between overlay and main app
  static Stream<dynamic> get overlayListener {
    _registerOverlayMessageHandler();
    return _controller.stream;
  }

  /// Overlay status stream.
  ///
  /// Emit `true` when overlay is showing, and `false` when overlay is closed.
  ///
  /// Emit value only once for every state change.
  ///
  /// Doesn't emit a change when the overlay is already showing and [showOverlay] is called,
  /// as in this case the overlay will almost immediately reopen.
  static Stream<bool> get overlayStatusListener {
    _registerOverlayMessageHandler();
    return _controllerOverlayStatus.stream;
  }

  /// Update the overlay flag while the overlay in action
  static Future<bool?> updateFlag(OverlayFlag flag) async {
    final bool? _res = await _overlayChannel
        .invokeMethod<bool?>('updateFlag', {'flag': flag.name});
    return _res;
  }

  /// Update the overlay size in the screen
  static Future<bool?> resizeOverlay(
    int width,
    int height,
    bool enableDrag,
  ) async {
    final bool? _res = await _overlayChannel.invokeMethod<bool?>(
      'resizeOverlay',
      {
        'width': width,
        'height': height,
        'enableDrag': enableDrag,
      },
    );
    return _res;
  }

  /// Update the overlay position in the screen
  ///
  /// `position` the new position of the overlay
  ///
  /// `return` true if the position updated successfully
  static Future<bool?> moveOverlay(OverlayPosition position) async {
    final bool? _res = await _channel.invokeMethod<bool?>(
      'moveOverlay',
      position.toMap(),
    );
    return _res;
  }

  /// Get the current overlay position
  ///
  /// `return` the current overlay position
  static Future<OverlayPosition> getOverlayPosition() async {
    final Map<Object?, Object?>? _res = await _channel.invokeMethod(
      'getOverlayPosition',
    );
    return OverlayPosition.fromMap(_res);
  }

  /// Check if the current overlay is active
  static Future<bool> isActive() async {
    final bool? _res = await _channel.invokeMethod<bool?>('isOverlayActive');
    return _res ?? false;
  }

  static void _registerOverlayMessageHandler() {
    _overlayMessageChannel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'isShowingOverlay':
          _controllerOverlayStatus.add(call.arguments as bool);
          break;
        case 'message':
          _controller.add(call.arguments);
          break;
      }
    });
  }

  /// Dispose overlay stream.
  ///
  /// Once disposed, only a complete restart of the application will re-initialize the listener.
  static Future<dynamic> disposeOverlayListener() {
    return _controller.close();
  }
}
