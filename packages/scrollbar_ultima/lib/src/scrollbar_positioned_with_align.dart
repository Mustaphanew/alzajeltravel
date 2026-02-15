import 'package:flutter/material.dart';
import 'package:scrollbar_ultima/src/scrollbar_position.dart';

class ScrollbarPositionedWithAlign extends StatelessWidget {
  final bool _isFill;
  final ScrollbarPosition position;
  final double offset;
  final Widget child;

  const ScrollbarPositionedWithAlign({
    super.key,
    required this.position,
    required this.offset,
    required this.child,
  }) : _isFill = false;

  const ScrollbarPositionedWithAlign.fill({
    super.key,
    required this.position,
    required this.child,
  })  : _isFill = true,
        offset = 0;

  bool get _isHorizontal =>
      position == ScrollbarPosition.top || position == ScrollbarPosition.bottom;

  @override
  Widget build(BuildContext context) {
    final alignment = _getAlignment();

    if (_isFill) {
      return Positioned.fill(
        right: position == ScrollbarPosition.left ? null : 0,
        top: position == ScrollbarPosition.bottom ? null : 0,
        bottom: position == ScrollbarPosition.top ? null : 0,
        left: position == ScrollbarPosition.right ? null : 0,
        child: Align(alignment: alignment, child: child),
      );
    }

    // IMPORTANT: horizontal scrollbar must be directional in RTL
    if (_isHorizontal) {
      return PositionedDirectional(
        start: offset,
        top: _getTop(),
        bottom: _getBottom(),
        child: Align(alignment: alignment, child: child),
      );
    }

    // Vertical scrollbar stays physical left/right
    return Positioned(
      right: _getRight(),
      left: _getLeft(),
      bottom: _getBottom(),
      top: _getTop(),
      child: Align(alignment: alignment, child: child),
    );
  }

  double? _getRight() {
    if (position == ScrollbarPosition.right) return 0;
    return null;
  }

  double? _getLeft() {
    if (position == ScrollbarPosition.left) return 0;
    return null;
  }

  double? _getBottom() {
    if (position == ScrollbarPosition.bottom) return 0;
    return null;
  }

  double? _getTop() {
    if (position == ScrollbarPosition.bottom) return null;
    if (position == ScrollbarPosition.top) return 0;
    // vertical thumb/label movement
    return offset;
  }

  AlignmentGeometry _getAlignment() {
    switch (position) {
      case ScrollbarPosition.top:
        return AlignmentDirectional.topStart;
      case ScrollbarPosition.bottom:
        return AlignmentDirectional.bottomStart;
      case ScrollbarPosition.right:
        return Alignment.topRight; // physical right
      case ScrollbarPosition.left:
        return Alignment.topLeft; // physical left
    }
  }
}
