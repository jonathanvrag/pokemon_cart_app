import 'package:flutter/material.dart';

class PokeballButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final double size;

  const PokeballButton({
    super.key,
    required this.onPressed,
    required this.isLoading,
    this.size = 32,
  });

  @override
  State<PokeballButton> createState() => _PokeballButtonState();
}

class _PokeballButtonState extends State<PokeballButton>
    with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _rotationController;
  late AnimationController _scaleController;

  late Animation<double> _floatAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: 0, end: 2).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    if (widget.isLoading) {
      _rotationController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant PokeballButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isLoading && !_rotationController.isAnimating) {
      _rotationController.repeat();
    } else if (!widget.isLoading && _rotationController.isAnimating) {
      _rotationController.stop();
      _rotationController.reset();
    }
  }

  @override
  void dispose() {
    _floatController.dispose();
    _rotationController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _onTapDown() {
    _scaleController.forward();
  }

  void _onTapUp() {
    _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_floatAnimation, _scaleAnimation]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -_floatAnimation.value),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: GestureDetector(
              onTapDown: (_) => _onTapDown(),
              onTapUp: (_) => _onTapUp(),
              onTapCancel: () => _onTapUp(),
              onTap: widget.isLoading ? null : widget.onPressed,
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: Offset(0, 4 + _floatAnimation.value * 0.3),
                    ),
                  ],
                ),
                child: AnimatedBuilder(
                  animation: _rotationController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: widget.isLoading
                          ? _rotationController.value * 2 * 3.14159
                          : 0,
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xFFE53E3E), Color(0xFFFFFFFF)],
                            stops: [0.5, 0.5],
                          ),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: widget.size,
                              height: 2,
                              color: Colors.black,
                            ),
                            Container(
                              width: widget.size * 0.3,
                              height: widget.size * 0.3,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                border: Border.all(
                                  color: Colors.black,
                                  width: 1.5,
                                ),
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
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
