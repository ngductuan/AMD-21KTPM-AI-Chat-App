import 'package:flutter/material.dart';

class LineTabIndicator extends Decoration {
  final BoxPainter _painter;

  LineTabIndicator({required Color color, required double height})
      : _painter = _LinePainter(color, height);

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) => _painter;
}

class _LinePainter extends BoxPainter {
  final Paint _paint;
  final double height;

  _LinePainter(Color color, this.height)
      : _paint = Paint()
          ..color = color
          ..isAntiAlias = true;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration cfg) {
    final lineOffset = offset +
        Offset(0, cfg.size!.height - height); // Adjust the y-coordinate
    final lineSize = Size(cfg.size!.width, height);
    Rect lineRect = Rect.fromPoints(
        lineOffset, lineOffset + Offset(lineSize.width, lineSize.height));
    canvas.drawRect(lineRect, _paint);
  }
}
