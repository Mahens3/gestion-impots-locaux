import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';

class FadeAnimation extends StatelessWidget {
  final double delay;
  final Widget child;
  const FadeAnimation(this.delay, this.child, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final tween = MovieTween()
      ..tween("opacity", Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 500), curve: Curves.easeIn)
      ..tween("translateY", Tween(begin: -100.0, end: 0.0),
          duration: const Duration(milliseconds: 500), curve: Curves.easeOut);
    return CustomAnimationBuilder(
        tween: tween,
        delay: Duration(milliseconds: (500 * delay).round()),
        duration: tween.duration,
        child: child,
        builder: (BuildContext context, Movie value, Widget? child) => Opacity(
            opacity: value.get("opacity"),
            child: Transform.translate(
              offset: Offset(0, value.get("translateY")),
              child: child,
            )));
  }
}

class SimpleTransition extends StatelessWidget {
  final double delay;
  final Widget child;
  const SimpleTransition(this.delay, this.child, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final tween = MovieTween()
      ..tween("opacity", Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 500), curve: Curves.easeIn);
    return CustomAnimationBuilder(
        tween: tween,
        delay: Duration(milliseconds: (500 * delay).round()),
        duration: tween.duration,
        child: child,
        builder: (BuildContext context, Movie value, Widget? child) => Opacity(
              opacity: value.get("opacity"),
              child: child,
            ));
  }
}

class Scaling extends StatelessWidget {
  final Widget child;
  const Scaling({Key? key, required this.child}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final tween = MovieTween()
      ..tween("opacity", Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 500), curve: Curves.easeIn)
      ..tween("scaleX", Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 500),
          curve: Curves.bounceInOut);
    return CustomAnimationBuilder(
        tween: tween,
        delay: const Duration(milliseconds: 500),
        duration: tween.duration,
        child: child,
        builder: (BuildContext context, Movie value, Widget? child) => Opacity(
            opacity: value.get("opacity"),
            child: Transform.scale(
              scaleX: value.get("scaleX"),
              child: child,
            )));
  }
}
