import 'package:flutter/material.dart';

class BouncingMascot extends StatefulWidget {
  final double width;
  final double height;
  final String imagePath;

  const BouncingMascot({
    super.key,
    this.width = 80,
    this.height = 80,
    this.imagePath = 'assets/imgs/m1.png',
  });

  @override
  State<BouncingMascot> createState() => _BouncingMascotState();
}

class _BouncingMascotState extends State<BouncingMascot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0, end: -8.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutQuad,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _animation.value),
          child: child,
        );
      },
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: AssetImage(widget.imagePath),
            fit: BoxFit.cover,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }
}
