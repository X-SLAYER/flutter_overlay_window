import 'package:flutter/foundation.dart';

@immutable
class OverlayPosition {
  final double x;
  final double y;

  const OverlayPosition(this.x, this.y);

  factory OverlayPosition.fromMap(Map<Object?, Object?>? map) =>
      OverlayPosition(map?['x'] as double? ?? 0, map?['y'] as double? ?? 0);

  Map<String, dynamic> toMap() =>
      <String, dynamic>{'x': x.toInt(), 'y': y.toInt()};

  @override
  String toString() {
    return 'OverlayPosition{x=$x, y=$y}';
  }
}
