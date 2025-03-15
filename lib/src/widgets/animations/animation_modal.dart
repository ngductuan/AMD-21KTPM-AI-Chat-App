import 'package:flutter/material.dart';

class AnimationModal {
  // Fade in modal
  static Route fadeInModal(Widget child) {
    return PageRouteBuilder(
      opaque: false, // Allows the background to be visible
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }
}
