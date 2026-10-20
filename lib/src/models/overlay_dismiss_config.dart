import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// Shape of the built-in dismiss target.
enum OverlayDismissShape {
  /// A circle with diameter [OverlayDismissConfig.size].
  circle,

  /// A square of [OverlayDismissConfig.size], with corners rounded by
  /// [OverlayDismissConfig.borderRadius].
  rectangle,
}

/// Configuration for the drag-to-dismiss target shown at the bottom of the
/// screen while the overlay is being dragged. Dropping the overlay on it
/// closes the overlay.
///
/// All sizes are in logical pixels (dp).
@immutable
class OverlayDismissConfig {
  /// Name of a drawable or mipmap resource in your app used instead of the
  /// built-in X icon (e.g. `"ic_dismiss"` for `res/drawable/ic_dismiss.xml`).
  ///
  /// When set and found, the color, shape, border and icon options are
  /// ignored. [size], [bottomMargin], [activeScale] and [hapticFeedback]
  /// still apply.
  final String? icon;

  /// Width and height of the dismiss target.
  final double size;

  /// Distance between the bottom of the screen and the dismiss target.
  final double bottomMargin;

  /// Shape of the built-in target.
  final OverlayDismissShape shape;

  /// Corner radius used when [shape] is [OverlayDismissShape.rectangle].
  final double borderRadius;

  /// Fill color of the built-in target.
  final Color backgroundColor;

  /// Color of the X icon in the built-in target.
  final Color iconColor;

  /// Width and height of the X icon.
  final double iconSize;

  /// Stroke width of the X icon.
  final double iconStrokeWidth;

  /// Width of the border drawn around the built-in target. `0` disables it.
  final double borderWidth;

  /// Color of the border drawn around the built-in target.
  final Color borderColor;

  /// Fill color while the overlay is over the target. Defaults to
  /// [backgroundColor].
  final Color? activeBackgroundColor;

  /// Icon color while the overlay is over the target. Defaults to
  /// [iconColor].
  final Color? activeIconColor;

  /// Border color while the overlay is over the target. Defaults to
  /// [borderColor].
  final Color? activeBorderColor;

  /// Scale applied to the target while the overlay is over it. `1` disables
  /// the effect.
  final double activeScale;

  /// Whether to vibrate when the overlay enters the target.
  final bool hapticFeedback;

  const OverlayDismissConfig({
    this.icon,
    this.size = 56,
    this.bottomMargin = 40,
    this.shape = OverlayDismissShape.circle,
    this.borderRadius = 12,
    this.backgroundColor = const Color(0xCC333333),
    this.iconColor = const Color(0xFFFFFFFF),
    this.iconSize = 22,
    this.iconStrokeWidth = 4,
    this.borderWidth = 0,
    this.borderColor = const Color(0x00000000),
    this.activeBackgroundColor,
    this.activeIconColor,
    this.activeBorderColor,
    this.activeScale = 1.2,
    this.hapticFeedback = true,
  })  : assert(size > 0),
        assert(bottomMargin >= 0),
        assert(borderRadius >= 0),
        assert(iconSize >= 0),
        assert(iconStrokeWidth >= 0),
        assert(borderWidth >= 0),
        assert(activeScale >= 1);

  Map<String, dynamic> toMap() => <String, dynamic>{
        'icon': icon,
        'size': size,
        'bottomMargin': bottomMargin,
        'shape': shape.name,
        'borderRadius': borderRadius,
        'backgroundColor': _toArgbInt(backgroundColor),
        'iconColor': _toArgbInt(iconColor),
        'iconSize': iconSize,
        'iconStrokeWidth': iconStrokeWidth,
        'borderWidth': borderWidth,
        'borderColor': _toArgbInt(borderColor),
        'activeBackgroundColor':
            _toArgbInt(activeBackgroundColor ?? backgroundColor),
        'activeIconColor': _toArgbInt(activeIconColor ?? iconColor),
        'activeBorderColor': _toArgbInt(activeBorderColor ?? borderColor),
        'activeScale': activeScale,
        'hapticFeedback': hapticFeedback,
      };

  /// Converts a [Color] to a signed 32-bit ARGB int so it arrives on the
  /// Android side as a Java `int` (matching `android.graphics.Color`).
  static int _toArgbInt(Color color) {
    // ignore: deprecated_member_use
    return color.value.toSigned(32);
  }

  @override
  String toString() => 'OverlayDismissConfig${toMap()}';
}
