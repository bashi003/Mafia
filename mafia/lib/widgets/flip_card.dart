import 'package:flutter/material.dart';

class FlipCard extends StatefulWidget {
  final String name;
  final String role;
  final Duration duration;

  const FlipCard({
    super.key,
    required this.name,
    required this.role,
    this.duration = const Duration(milliseconds: 600),
  });

  @override
  State<FlipCard> createState() => _FlipCardState();
}

class _FlipCardState extends State<FlipCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _flipped = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  void _flip() {
    if (!_flipped) {
      _controller.forward();
      _flipped = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _flip,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final isFront = _animation.value < 0.5;
          final transformValue =
              isFront
                  ? _animation.value * 3.1416
                  : (1 - _animation.value) * 3.1416;

          return Transform(
            transform: Matrix4.rotationY(transformValue),
            alignment: Alignment.center,
            child:
                isFront
                    ? Card(
                      color: Colors.grey[800],
                      child: Center(child: Text(widget.name)),
                    )
                    : Card(
                      color: Colors.deepPurple,
                      child: Center(
                        child: Text(
                          '${widget.name}\n(${widget.role})',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
