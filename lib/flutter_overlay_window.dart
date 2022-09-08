import 'dart:async';
import 'dart:developer';

import 'package:flutter/services.dart';

/// default size when the overlay match the parent size
/// basically it will take the full screen width and height
const int matchParent = -1;

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
  /// `height` the overlay height and default is [matchParent]
  /// `width` the overlay width and default is [matchParent]
  /// `alignment` the alignment postion on screen and default is [OverlayAlignment.center]
  /// `visibilitySecret` the detail displayed in notifications on the lock screen and default is [NotificationVisibility.visibilitySecret]
  /// `OverlayFlag` the overlay flag and default is [OverlayFlag.defaultFlag]
  /// `overlayTitle` the notification message and default is "overlay activated"
  /// `overlayContent` the notification message
  /// `enableDrag` to enable/disable dragging the overlay over the screen and default is "false"
  /// `positionGravity` the overlay postion after drag and default is [PositionGravity.none]
  static Future<void> showOverlay({
    int height = matchParent,
    int width = matchParent,
    OverlayAlignment alignment = OverlayAlignment.center,
    NotificationVisibility visibility = NotificationVisibility.visibilitySecret,
    OverlayFlag flag = OverlayFlag.defaultFlag,
    String overlayTitle = "overlay activated",
    String? overlayContent,
    bool enableDrag = false,
    PositionGravity positionGravity = PositionGravity.none,
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

  /// Broadcast data to and from overlay app
  static Future shareData(dynamic data) async {
    return await _overlayMessageChannel.send(data);
  }

  /// Streams message shared between overlay and main app
  static Stream<dynamic> get overlayListener {
    _overlayMessageChannel.setMessageHandler((message) async {
      _controller.add(message);
      return message;
    });
    return _controller.stream;
  }

  /// Update the overlay flag while the overlay in action
  static Future<bool?> updateFlag(OverlayFlag flag) async {
    final bool? _res = await _overlayChannel
        .invokeMethod<bool?>('updateFlag', {'flag': flag.name});
    return _res;
  }

  /// Update the overlay size in the screen
  static Future<bool?> resizeOverlay(int width, int height) async {
    final bool? _res = await _overlayChannel.invokeMethod<bool?>(
      'resizeOverlay',
      {
        'width': width,
        'height': height,
      },
    );
    return _res;
  }

  static Future<double?> getWidthDevice() async {
    final double? _res = await _channel.invokeMethod<double?>(
      'getWidth'
    );
    return _res;
  }

  static Future<bool?> setDragging(bool dragging) async {
    final bool? _res = await _channel.invokeMethod<bool?>(
      'setDragging',{
      'enableDrag': dragging,
    },
    );
    return _res;
  }
  static Future<double?> getHeightDevice() async {
    final double? _res = await _channel.invokeMethod<double?>(
      'getHeight'
    );
    return _res;
  }

  /// Check if the current overlay is active
  static Future<bool> isActive() async {
    final bool? _res = await _channel.invokeMethod<bool?>('isOverlayActive');
    return _res ?? false;
  }

  /// Dispose overlay stream
  static void disposeOverlayListener() {
    _controller.close();
  }
}

/// Placement of overlay within the screen.
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

/// Type of dragging behavior for the overlay.
enum PositionGravity {
  /// The `PositionGravity.none` will allow the overlay to postioned anywhere on the screen.
  none,

  /// The `PositionGravity.right` will allow the overlay to stick on the right side of the screen.
  right,

  /// The `PositionGravity.left` will allow the overlay to stick on the left side of the screen.
  left,

  /// The `PositionGravity.auto` will allow the overlay to stick either on the left or right side of the screen depending on the overlay position.
  auto,
}

enum OverlayFlag {
  /// Window flag: this window can never receive touch events.
  /// Usefull if you want to display click-through overlay
  @Deprecated('Use "clickThrough" instead.')
  flagNotTouchable,

  /// Window flag: this window won't ever get key input focus
  /// so the user can not send key or other button events to it.
  @Deprecated('Use "defaultFlag" instead.')
  flagNotFocusable,

  /// Window flag: allow any pointer events outside of the window to be sent to the windows behind it.
  /// Usefull when you want to use fields that show keyboards.
  @Deprecated('Use "focusPointer" instead.')
  flagNotTouchModal,

  /// Window flag: this window can never receive touch events.
  /// Usefull if you want to display click-through overlay
  clickThrough,

  /// Window flag: this window won't ever get key input focus
  /// so the user can not send key or other button events to it.
  defaultFlag,

  /// Window flag: allow any pointer events outside of the window to be sent to the windows behind it.
  /// Usefull when you want to use fields that show keyboards.
  focusPointer,
}

/// The level of detail displayed in notifications on the lock screen.
enum NotificationVisibility {
  /// Show this notification in its entirety on all lockscreens.
  visibilityPublic,

  /// Do not reveal any part of this notification on a secure lockscreen.
  visibilitySecret,

  /// Show this notification on all lockscreens, but conceal sensitive or private information on secure lockscreens.
  visibilityPrivate
}
