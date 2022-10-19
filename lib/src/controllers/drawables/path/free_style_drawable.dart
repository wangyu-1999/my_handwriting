
import 'package:flutter/material.dart';
import 'package:my_handwriting/flutter_painter.dart';

/// Free-style Drawable (hand scribble).
class FreeStyleDrawable extends ObjectDrawable implements PathDrawable {
  /// The color the path will be drawn with.
  final Color color;

  @override
  final List<Offset> path;

  @override
  final double strokeWidth;

  final int? originPositionPathLength;

  /// Creates a [FreeStyleDrawable] to draw [path].
  ///
  /// The path will be drawn with the passed [color] and [strokeWidth] if provided.
  FreeStyleDrawable({
    required this.path,
    this.strokeWidth = 1,
    this.color = Colors.black,
    bool hidden = false,
    Size? size,
    Offset? position,
    double? rotation,
    double scale = 1,
    double rotationAngle = 0,
    Set<ObjectDrawableAssist> assists = const <ObjectDrawableAssist>{},
    Map<ObjectDrawableAssist, Paint> assistPaints =
        const <ObjectDrawableAssist, Paint>{},
    bool locked = false,
    this.originPositionPathLength,
  })  :
        // An empty path cannot be drawn, so it is an invalid argument.
        assert(path.isNotEmpty, 'The path cannot be an empty list'),
        // The line cannot have a non-positive stroke width.
        assert(strokeWidth > 0,
            'The stroke width cannot be less than or equal to 0'),
        super(
          position: originPositionPathLength == path.length
              ? (position ?? getOriginPostion(path))
              : getOriginPostion(path),
          rotationAngle: rotationAngle,
          scale: scale,
          locked: locked,
          assists: assists,
          assistPaints: assistPaints,
        );

  /// Creates a copy of this but with the given fields replaced with the new values.
  @override
  FreeStyleDrawable copyWith({
    bool? hidden,
    List<Offset>? path,
    Color? color,
    double? strokeWidth,
    Set<ObjectDrawableAssist>? assists,
    Offset? position,
    double? rotation,
    double? scale,
    Size? size,
    bool? locked,
  }) {
    return FreeStyleDrawable(
      path: path ?? this.path,
      color: color ?? this.color,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      hidden: hidden ?? this.hidden,
      size: size ?? getOriginSize(this.path),
      position: position ?? this.position,
      rotationAngle: rotation ?? rotationAngle,
      scale: scale ?? this.scale,
      locked: locked ?? this.locked,
      assists: assists ?? this.assists,
      originPositionPathLength: this.path.length,
    );
  }

  @protected
  @override
  Paint get paint => Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..color = color
    ..strokeWidth = strokeWidth / scale;

  // 获得绘制图形的中心点位置
  static Offset getOriginPostion(List<Offset> path) {
    double left = path[0].dx;
    double right = path[0].dx;
    double top = path[0].dy;
    double down = path[0].dy;
    for (int i = 0; i < path.length; i++) {
      left = left > path[i].dx ? path[i].dx : left;
      right = right < path[i].dx ? path[i].dx : right;
      top = top > path[i].dy ? path[i].dy : top;
      down = down < path[i].dy ? path[i].dy : down;
    }
    return Offset((left + right) / 2, (top + down) / 2);
  }

  // 获得绘制路径图案的尺寸，包含长和宽
  static Size getOriginSize(List<Offset> path) {
    double left = path[0].dx;
    double right = path[0].dx;
    double top = path[0].dy;
    double down = path[0].dy;
    for (int i = 0; i < path.length; i++) {
      left = left > path[i].dx ? path[i].dx : left;
      right = right < path[i].dx ? path[i].dx : right;
      top = top > path[i].dy ? path[i].dy : top;
      down = down < path[i].dy ? path[i].dy : down;
    }
    return Size(right - left, down - top);
  }

  @override
  void drawObject(Canvas canvas, Size size) {
    // Create a UI path to draw
    final path = Path();
    final Offset offset;
    offset = Offset(
        position.dx - originPosition.dx, position.dy - originPosition.dy);
    // Start path from the first point
    var offsetPoint = getPoint(this.path[0], offset, scale, originPosition);
    path.moveTo(offsetPoint.dx, offsetPoint.dy);
    path.lineTo(offsetPoint.dx, offsetPoint.dy);
    // Draw a line between each point on the free path
    this.path.sublist(1).forEach((point) {
      offsetPoint = getPoint(point, offset, scale, originPosition);
      path.lineTo(offsetPoint.dx, offsetPoint.dy);
    });
    canvas.scale(scale);
    // Draw the path on the canvas
    canvas.drawPath(path, paint);
  }

  static getPoint(
      Offset point, Offset offset, double scale, Offset originPosition) {
    return point + offset / scale + originPosition / scale - originPosition;
  }

  Offset get originPosition => getOriginPostion(path);

  @override
  Size getSize({double minWidth = 0.0, double maxWidth = double.infinity}) {
    var size = getOriginSize(path);
    return Size(
      size.width * scale,
      size.height * scale,
    );
  }
}
