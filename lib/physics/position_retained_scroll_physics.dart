import 'package:flutter/material.dart';

///
/// https://github.com/SimonWang9610/indexed_scroll_observer
///

class PositionRetainedScrollPhysics extends ScrollPhysics {
  final bool shouldRetain;
  final double offset;
  const PositionRetainedScrollPhysics({super.parent, this.shouldRetain = true, required this.offset});

  @override
  PositionRetainedScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return PositionRetainedScrollPhysics(
      parent: buildParent(ancestor),
      shouldRetain: shouldRetain,
      offset: offset,
    );
  }

  @override
  double adjustPositionForNewDimensions({
    required ScrollMetrics oldPosition,
    required ScrollMetrics newPosition,
    required bool isScrolling,
    required double velocity,
  }) {
    final position = super.adjustPositionForNewDimensions(
      oldPosition: oldPosition,
      newPosition: newPosition,
      isScrolling: isScrolling,
      velocity: velocity,
    );

    final diff = newPosition.maxScrollExtent - oldPosition.maxScrollExtent;

    if (!isScrolling) {
      return position;
    }

    if (oldPosition.pixels <= 0) {
      if (newPosition.maxScrollExtent > oldPosition.maxScrollExtent && diff > 0 && shouldRetain) {
        return diff - offset;
      } else {
        return position;
      }
    } else {
      return position;
    }
  }
}
