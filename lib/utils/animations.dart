import 'dart:async';
import 'package:flutter/material.dart';

class ShowUpAnimation extends StatefulWidget {
  final Widget child;
  final int? delay;

  const ShowUpAnimation({super.key, required this.child, this.delay});

  @override
  State<ShowUpAnimation> createState() => _ShowUpAnimationState();
}

class _ShowUpAnimationState extends State<ShowUpAnimation> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    final curve = CurvedAnimation(parent: _controller, curve: Curves.decelerate);
    _offsetAnimation = Tween<Offset>(begin: const Offset(0, 0.35), end: Offset.zero)
        .animate(curve);

    if (widget.delay == null) {
      _controller.forward();
    } else {
      _timer = Timer(Duration(milliseconds: widget.delay!), () {
        _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: SlideTransition(position: _offsetAnimation, child: widget.child),
    );
  }
}
