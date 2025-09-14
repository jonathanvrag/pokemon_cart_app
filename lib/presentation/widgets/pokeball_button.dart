import 'package:flutter/material.dart';

class PokeballButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final double size;

  const PokeballButton({
    super.key,
    required this.onPressed,
    required this.isLoading,
    this.size = 40,
  });

  @override
  State<PokeballButton> createState() => _PokeballButtonState();
}

class _PokeballButtonState extends State<PokeballButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    if (widget.isLoading) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant PokeballButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isLoading && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.isLoading && _controller.isAnimating) {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isLoading ? null : widget.onPressed,
      child: RotationTransition(
        turns: _controller,
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFE53E3E), 
                Color(0xffffffff), 
              ],
              stops: [0.5, 0.5],
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: widget.size,
                height: 3,
                color: Colors.black,
              ),
              Container(
                width: widget.size * 0.3,
                height: widget.size * 0.3,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: Colors.black, width: 2),
                ),
              ),
              Container(
                width: widget.size * 0.15,
                height: widget.size * 0.15,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              ),
              if (widget.isLoading)
                Container(
                  width: widget.size * 0.8,
                  height: widget.size * 0.8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.6),
                      width: 2,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
