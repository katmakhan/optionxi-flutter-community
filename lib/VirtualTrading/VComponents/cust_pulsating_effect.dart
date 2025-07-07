import 'package:flutter/material.dart';

/// A widget that provides a subtle color pulse animation when a value changes.
///
/// The pulse color is green for an increase in value and red for a decrease.
class PulsatingEffect extends StatefulWidget {
  final Widget child;
  final double value; // The value that triggers the pulse on change

  const PulsatingEffect({
    Key? key,
    required this.child,
    required this.value,
  }) : super(key: key);

  @override
  _PulsatingEffectState createState() => _PulsatingEffectState();
}

class _PulsatingEffectState extends State<PulsatingEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Animation<Color?>? _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      // A short duration for a quick, subtle pulse
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(PulsatingEffect oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Trigger the pulse if the value has changed
    if (widget.value != oldWidget.value) {
      if (!mounted) return;

      bool isUp = widget.value > oldWidget.value;

      // Create a tween that animates from transparent to the pulse color
      _colorAnimation = ColorTween(
        begin: Colors.transparent,
        end: (isUp ? Colors.green : Colors.red).withOpacity(0.25),
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut))
        ..addStatusListener((status) {
          // When the pulse-in animation is complete, reverse it to fade out
          if (status == AnimationStatus.completed) {
            _controller.reverse();
          }
        });

      // Start the animation from the beginning
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        // The DecoratedBox applies the animated background color
        return DecoratedBox(
          decoration: BoxDecoration(
            color: _colorAnimation?.value ?? Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            // Padding ensures the pulse effect is visible around the child widget
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            child: widget.child,
          ),
        );
      },
    );
  }
}
