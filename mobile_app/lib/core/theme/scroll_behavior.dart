import 'package:flutter/material.dart';

class SmoothScrollBehavior extends ScrollBehavior {
  const SmoothScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    // Return null to use platform-native scroll physics (fastest possible)
    return const ScrollPhysics();
  }

  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    // No overscroll indicator for maximum performance
    return child;
  }
}
