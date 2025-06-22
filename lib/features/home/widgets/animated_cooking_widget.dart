import 'package:flutter/material.dart';
import '../../../core/constants/sizes.dart';

class AnimatedCookingWidget extends StatefulWidget {
  const AnimatedCookingWidget({super.key});

  @override
  State<AnimatedCookingWidget> createState() => _AnimatedCookingWidgetState();
}

class _AnimatedCookingWidgetState extends State<AnimatedCookingWidget>
    with TickerProviderStateMixin {
  late AnimationController _panController;
  late AnimationController _eggController;
  late AnimationController _steamController;
  late AnimationController _bubbleController;

  late Animation<double> _panRotation;
  late Animation<double> _eggBounce;
  late Animation<double> _steamOpacity;
  late Animation<double> _bubbleScale;

  @override
  void initState() {
    super.initState();

    // Pan animation
    _panController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _panRotation = Tween<double>(
      begin: -0.05,
      end: 0.05,
    ).animate(CurvedAnimation(parent: _panController, curve: Curves.easeInOut));

    // Egg animation
    _eggController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _eggBounce = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _eggController, curve: Curves.elasticOut),
    );

    // Steam animation
    _steamController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _steamOpacity = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _steamController, curve: Curves.easeInOut),
    );

    // Bubble animation
    _bubbleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _bubbleScale = Tween<double>(begin: 0.5, end: 1.2).animate(
      CurvedAnimation(parent: _bubbleController, curve: Curves.easeOut),
    );

    // Start animations
    _startAnimations();
  }

  void _startAnimations() {
    _panController.repeat(reverse: true);
    _steamController.repeat(reverse: true);

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _eggController.forward();
    });

    _bubbleController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _panController.dispose();
    _eggController.dispose();
    _steamController.dispose();
    _bubbleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.orange.shade50, Colors.yellow.shade50, Colors.white],
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background decoration
          _buildBackgroundDecoration(),

          // Main cooking scene
          _buildCookingScene(),

          // Floating bubbles
          _buildFloatingBubbles(),

          // Text overlay
          _buildTextOverlay(),
        ],
      ),
    );
  }

  Widget _buildBackgroundDecoration() {
    return Positioned.fill(
      child: CustomPaint(painter: KitchenBackgroundPainter()),
    );
  }

  Widget _buildCookingScene() {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _panController,
        _eggController,
        _steamController,
      ]),
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Pan
            Transform.rotate(
              angle: _panRotation.value,
              child: Container(
                width: 120,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey.shade800,
                  borderRadius: BorderRadius.circular(60),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Pan interior
                    Container(
                      width: 100,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade700,
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),

                    // Fried egg
                    Transform.scale(
                      scale: _eggBounce.value,
                      child: _buildFriedEgg(),
                    ),
                  ],
                ),
              ),
            ),

            // Steam
            Positioned(
              top: 20,
              child: AnimatedOpacity(
                opacity: _steamOpacity.value,
                duration: const Duration(milliseconds: 300),
                child: _buildSteam(),
              ),
            ),

            // Pan handle
            Positioned(
              right: 10,
              child: Transform.rotate(
                angle: _panRotation.value,
                child: Container(
                  width: 40,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.brown.shade600,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFriedEgg() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Egg white
        Container(
          width: 50,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),

        // Egg yolk
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.orange.shade400,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withOpacity(0.4),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSteam() {
    return Column(
      children: List.generate(3, (index) {
        return AnimatedContainer(
          duration: Duration(milliseconds: 1000 + (index * 200)),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.only(bottom: 4),
          child: Text(
            '💨',
            style: TextStyle(
              fontSize: 16 - (index * 2),
              color: Colors.grey.withOpacity(0.7 - (index * 0.2)),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildFloatingBubbles() {
    return AnimatedBuilder(
      animation: _bubbleController,
      builder: (context, child) {
        return Stack(
          children: List.generate(5, (index) {
            final offset = Offset((index * 30.0) - 60, (index * 15.0) - 30);

            return Positioned(
              left: 50 + offset.dx,
              top: 50 + offset.dy,
              child: Transform.scale(
                scale: _bubbleScale.value * (0.5 + (index * 0.1)),
                child: Container(
                  width: 8 + (index * 2),
                  height: 8 + (index * 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.6),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.blue.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildTextOverlay() {
    return Positioned(
      bottom: 20,
      child: Column(
        children: [
          Text(
            '🍳 Masak dengan Cinta',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.orange.shade700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Resep lezat menanti untuk dicoba!',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

class KitchenBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.orange.withOpacity(0.05)
          ..style = PaintingStyle.fill;

    // Draw subtle kitchen utensils in background
    final path = Path();

    // Spoon
    path.addOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.2, size.height * 0.3),
        width: 8,
        height: 20,
      ),
    );

    // Fork
    path.addRect(
      Rect.fromCenter(
        center: Offset(size.width * 0.8, size.height * 0.7),
        width: 3,
        height: 15,
      ),
    );

    // Knife
    path.addRect(
      Rect.fromCenter(
        center: Offset(size.width * 0.1, size.height * 0.8),
        width: 2,
        height: 18,
      ),
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
