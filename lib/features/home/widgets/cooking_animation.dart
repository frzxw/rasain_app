import 'package:flutter/material.dart';
import 'dart:math' as math;

class CookingAnimation extends StatefulWidget {
  final double size;
  
  const CookingAnimation({
    super.key,
    this.size = 200,
  });

  @override
  State<CookingAnimation> createState() => _CookingAnimationState();
}

class _CookingAnimationState extends State<CookingAnimation>
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
    
    // Pan rotation animation
    _panController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _panRotation = Tween<double>(
      begin: -0.1,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _panController,
      curve: Curves.easeInOut,
    ));
    
    // Egg bounce animation
    _eggController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _eggBounce = Tween<double>(
      begin: 0,
      end: -8,
    ).animate(CurvedAnimation(
      parent: _eggController,
      curve: Curves.elasticOut,
    ));
    
    // Steam animation
    _steamController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _steamOpacity = Tween<double>(
      begin: 0.3,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _steamController,
      curve: Curves.easeInOut,
    ));
    
    // Bubble animation
    _bubbleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _bubbleScale = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _bubbleController,
      curve: Curves.easeInOut,
    ));
    
    // Start animations
    _startAnimations();
  }
  
  void _startAnimations() {
    _panController.repeat(reverse: true);
    _steamController.repeat(reverse: true);
    _bubbleController.repeat(reverse: true);
    
    // Egg bounce with random intervals
    _animateEgg();
  }
  
  void _animateEgg() {
    Future.delayed(Duration(milliseconds: 2000 + math.Random().nextInt(3000)), () {
      if (mounted) {
        _eggController.forward().then((_) {
          _eggController.reset();
          _animateEgg();
        });
      }
    });
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
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background heat effect
          AnimatedBuilder(
            animation: _bubbleController,
            builder: (context, child) {
              return Transform.scale(
                scale: _bubbleScale.value,
                child: Container(
                  width: widget.size * 0.8,
                  height: widget.size * 0.8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.orange.withOpacity(0.1),
                        Colors.red.withOpacity(0.05),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          
          // Pan
          AnimatedBuilder(
            animation: _panController,
            builder: (context, child) {
              return Transform.rotate(
                angle: _panRotation.value,
                child: Container(
                  width: widget.size * 0.7,
                  height: widget.size * 0.7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF2C2C2C),
                        Color(0xFF1A1A1A),
                        Color(0xFF2C2C2C),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ),
              );
            },
          ),
          
          // Fried Egg
          AnimatedBuilder(
            animation: _eggController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _eggBounce.value),
                child: SizedBox(
                  width: widget.size * 0.4,
                  height: widget.size * 0.4,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Egg white
                      Container(
                        width: widget.size * 0.35,
                        height: widget.size * 0.35,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.9),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                      // Egg yolk
                      Container(
                        width: widget.size * 0.15,
                        height: widget.size * 0.15,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const RadialGradient(
                            colors: [
                              Color(0xFFFFD700),
                              Color(0xFFFFA500),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.withOpacity(0.4),
                              blurRadius: 6,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          
          // Steam effect
          AnimatedBuilder(
            animation: _steamController,
            builder: (context, child) {
              return Positioned(
                top: widget.size * 0.1,
                child: Opacity(
                  opacity: _steamOpacity.value,
                  child: Column(
                    children: [
                      _buildSteamPuff(0),
                      const SizedBox(height: 4),
                      _buildSteamPuff(1),
                      const SizedBox(height: 4),
                      _buildSteamPuff(2),
                    ],
                  ),
                ),
              );
            },
          ),
          
          // Pan handle
          Positioned(
            right: 0,
            child: Container(
              width: widget.size * 0.3,
              height: 8,
              decoration: BoxDecoration(
                color: const Color(0xFF2C2C2C),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSteamPuff(int index) {
    final offset = (index * 0.3) + (_steamController.value * 2);
    return Transform.translate(
      offset: Offset(math.sin(offset) * 10, 0),
      child: Container(
        width: 12 + (index * 2),
        height: 8,
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.4),
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }
}
