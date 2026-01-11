import 'package:flutter/material.dart';

class SmoothScrollBehavior extends ScrollBehavior {
  const SmoothScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    // Use ClampingScrollPhysics for native Android performance
    // This is the default on Android and provides the fastest, smoothest scroll
    return const ClampingScrollPhysics(parent: AlwaysScrollableScrollPhysics());
  }

  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}
