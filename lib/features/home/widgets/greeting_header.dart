import 'package:flutter/material.dart';
import '../../../core/constants/sizes.dart';
import '../../../core/theme/colors.dart';

class GreetingHeader extends StatefulWidget {
  final String? userName;

  const GreetingHeader({super.key, this.userName});

  @override
  State<GreetingHeader> createState() => _GreetingHeaderState();
}

class _GreetingHeaderState extends State<GreetingHeader>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late AnimationController _panController;
  late Animation<double> _panAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(-0.3, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
      ),
    );

    _controller.forward();

    _panController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _panAnimation = Tween<double>(
      begin: -0.05,
      end: 0.05,
    ).animate(CurvedAnimation(parent: _panController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    _panController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final greeting = _getGreeting();

    return AnimatedBuilder(
      animation: _controller,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingL,
          vertical: AppSizes.paddingM, // Reduced vertical padding
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          border: Border.all(
            color: (greeting['borderColor'] as Color).withOpacity(0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: (greeting['borderColor'] as Color).withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center, // Center align
          children: [
            // Greeting Text
            Expanded(
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min, // Prevent overflow
                  children: [
                    Text(
                      greeting['message']!,
                      style: Theme.of(
                        context,
                      ).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: greeting['color'] as Color,
                        letterSpacing: -0.5,
                        fontSize: 24, // Slightly smaller
                      ),
                    ),
                    const SizedBox(
                      height: AppSizes.marginXS,
                    ), // Reduced spacing
                    Text(
                      widget.userName != null
                          ? 'Hi, ${widget.userName}!'
                          : greeting['subtitle']!,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                        fontSize: 14, // Smaller subtitle
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: AppSizes.marginM), // Add spacing
            // Animated Greeting Icon
            _buildAnimatedIcon(),
          ],
        ),
      ),
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(scale: _scaleAnimation, child: child!),
        );
      },
    );
  }

  Widget _buildAnimatedIcon() {
    return AnimatedBuilder(
      animation: _panAnimation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _panAnimation.value * 0.1, // Lebih halus
          child: Container(
            width: 100,
            height: 100,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Teflon dengan emoji
                Container(
                  width: 80,
                  height: 80,
                  child: Center(
                    child: Text(
                      '🍳',
                      style: TextStyle(
                        fontSize: 60,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 3,
                            offset: const Offset(2, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Telur ceplok dengan emoji
                Positioned(
                  top: 15,
                  left: 20,
                  child: Transform.scale(
                    scale: 0.8 + (_panAnimation.value.abs() * 0.1),
                    child: Text(
                      '🍳',
                      style: TextStyle(
                        fontSize: 25,
                        shadows: [
                          Shadow(
                            color: Colors.orange.withOpacity(0.3),
                            blurRadius: 2,
                            offset: const Offset(1, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Efek steam/uap
                Positioned(
                  top: -5,
                  child: Transform.translate(
                    offset: Offset(0, _panAnimation.value * 2),
                    child: Text(
                      '💨',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Map<String, dynamic> _getGreeting() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 11) {
      return {
        'message': 'Selamat Pagi!',
        'subtitle': 'Sarapan sehat untuk memulai hari yang indah!',
        'color': const Color(0xFFE53E3E), // Merah untuk pagi
        'borderColor': const Color(0xFFE53E3E),
      };
    } else if (hour >= 11 && hour < 15) {
      return {
        'message': 'Selamat Siang!',
        'subtitle': 'Waktunya makan siang yang lezat dan bergizi!',
        'color': const Color(0xFFED8936), // Orange untuk siang
        'borderColor': const Color(0xFFED8936),
      };
    } else if (hour >= 15 && hour < 18) {
      return {
        'message': 'Selamat Sore!',
        'subtitle': 'Momen santai dengan cemilan favorit!',
        'color': const Color(0xFFD69E2E), // Kuning untuk sore
        'borderColor': const Color(0xFFD69E2E),
      };
    } else {
      return {
        'message': 'Selamat Malam!',
        'subtitle': 'Makan malam romantis menanti!',
        'color': const Color(0xFF805AD5), // Ungu untuk malam
        'borderColor': const Color(0xFF805AD5),
      };
    }
  }
}
