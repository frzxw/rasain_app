import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/sizes.dart';
import '../../../core/theme/colors.dart';

class ModernFloatingActionButton extends StatefulWidget {
  const ModernFloatingActionButton({super.key});

  @override
  State<ModernFloatingActionButton> createState() =>
      _ModernFloatingActionButtonState();
}

class _ModernFloatingActionButtonState extends State<ModernFloatingActionButton>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;

  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.125, // 45 degrees
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
    });

    if (_isExpanded) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        // Background overlay when expanded
        if (_isExpanded)
          Positioned.fill(
            child: GestureDetector(
              onTap: _toggleExpansion,
              child: Container(color: Colors.black.withOpacity(0.3)),
            ),
          ),

        // Action buttons
        ..._buildActionButtons(),

        // Main FAB
        _buildMainFAB(),
      ],
    );
  }

  List<Widget> _buildActionButtons() {
    final actions = [
      {
        'icon': Icons.camera_alt,
        'color': const Color(0xFF10B981),
        'label': 'Scan Recipe',
        'action': () {
          _toggleExpansion();
          // TODO: Implement camera scan
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Camera scan coming soon! 📷')),
          );
        },
      },
      {
        'icon': Icons.upload_file,
        'color': const Color(0xFF8B5CF6),
        'label': 'Upload Recipe',
        'action': () {
          _toggleExpansion();
          context.push('/upload-recipe');
        },
      },
      {
        'icon': Icons.auto_awesome,
        'color': const Color(0xFFFF6B35),
        'label': 'AI Generator',
        'action': () {
          _toggleExpansion();
          // TODO: Implement AI generator
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('AI Generator coming soon! 🤖')),
          );
        },
      },
    ];

    return actions.asMap().entries.map((entry) {
      int index = entry.key;
      Map<String, dynamic> action = entry.value;

      return AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final offset = 70.0 * (index + 1) * _scaleAnimation.value;

          return Positioned(
            right: 16,
            bottom: 80 + offset,
            child: FadeTransition(
              opacity: _scaleAnimation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: _controller,
                    curve: Interval(
                      index * 0.1,
                      0.6 + (index * 0.1),
                      curve: Curves.elasticOut,
                    ),
                  ),
                ),
                child: _buildActionButton(
                  icon: action['icon'],
                  color: action['color'],
                  label: action['label'],
                  onTap: action['action'],
                ),
              ),
            ),
          );
        },
      );
    }).toList();
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingM,
            vertical: AppSizes.paddingS,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),

        const SizedBox(width: AppSizes.marginS),

        // Button
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [color, color.withOpacity(0.8)]),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
        ),
      ],
    );
  }

  Widget _buildMainFAB() {
    return Positioned(
      right: 16,
      bottom: 16,
      child: AnimatedBuilder(
        animation: Listenable.merge([_rotationAnimation, _pulseAnimation]),
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: Transform.rotate(
              angle: _rotationAnimation.value * 2 * 3.14159,
              child: GestureDetector(
                onTap: _toggleExpansion,
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary,
                        const Color(0xFF8B5CF6),
                        const Color(0xFFEC4899),
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                      BoxShadow(
                        color: Colors.white.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Icon(
                    _isExpanded ? Icons.close : Icons.add,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
