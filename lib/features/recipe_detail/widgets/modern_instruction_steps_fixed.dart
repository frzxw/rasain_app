import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../models/recipe.dart';
import 'cooking_mode_view.dart';

class ModernInstructionSteps extends StatefulWidget {
  final List<Map<String, dynamic>> instructions;
  final Recipe? recipe;

  const ModernInstructionSteps({
    super.key,
    required this.instructions,
    this.recipe,
  });

  @override
  State<ModernInstructionSteps> createState() => _ModernInstructionStepsState();
}

class _ModernInstructionStepsState extends State<ModernInstructionSteps>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  int _currentStep = 0;
  bool _isCookingMode = false;
  Set<int> _completedSteps = {};

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.instructions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          'Belum ada instruksi untuk resep ini',
          style: TextStyle(color: Colors.grey[600], fontSize: 16),
          textAlign: TextAlign.center,
        ),
      );
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header - More compact and responsive
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.8),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  // Main header row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.restaurant_menu,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Langkah Memasak',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${widget.instructions.length} langkah',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Action buttons row - more compact
                  Row(
                    children: [
                      // Full Cooking Mode Button
                      if (widget.recipe != null)
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => CookingModeView(
                                        recipe: widget.recipe!,
                                        onExit: () {
                                          Navigator.pop(context);
                                        },
                                      ),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.kitchen,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  const Text(
                                    'Mode Masak',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                      if (widget.recipe != null) const SizedBox(width: 12),

                      // Cooking mode toggle
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _isCookingMode = !_isCookingMode;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color:
                                  _isCookingMode
                                      ? Colors.white.withOpacity(0.3)
                                      : Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _isCookingMode
                                      ? Icons.pause
                                      : Icons.play_arrow,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _isCookingMode ? 'Stop' : 'Mulai',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Progress indicator
            if (_isCookingMode)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value:
                            _completedSteps.length / widget.instructions.length,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.success,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Langkah ${_currentStep + 1}/${widget.instructions.length}',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

            // Instructions content
            Padding(
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                top: 24,
                bottom: 20,
              ),
              child:
                  _isCookingMode
                      ? _buildCookingModeView()
                      : _buildNormalModeView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNormalModeView() {
    return Column(
      children:
          widget.instructions.asMap().entries.map((entry) {
            final index = entry.key;
            final instruction = entry.value;
            final stepNumber = index + 1;
            final isCompleted = _completedSteps.contains(index);
            final description =
                instruction['description'] ??
                instruction['text'] ??
                instruction['instruction_text'] ??
                '';
            final timerMinutes = instruction['timer_minutes'] as int?;

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Step number circle
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color:
                          isCompleted ? AppColors.success : AppColors.primary,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: (isCompleted
                                  ? AppColors.success
                                  : AppColors.primary)
                              .withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child:
                          isCompleted
                              ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 18,
                              )
                              : Text(
                                stepNumber.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Step content
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color:
                            isCompleted
                                ? AppColors.success.withOpacity(0.1)
                                : Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              isCompleted
                                  ? AppColors.success.withOpacity(0.3)
                                  : Colors.grey.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Timer info if available
                          if (timerMinutes != null && timerMinutes > 0)
                            Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.timer,
                                    size: 14,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _formatDuration(timerMinutes),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          Text(
                            description,
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              color:
                                  isCompleted
                                      ? AppColors.success
                                      : Colors.grey[800],
                              decoration:
                                  isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                            ),
                          ),

                          if (!isCompleted)
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _completedSteps.add(index);
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'Selesai',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }

  Widget _buildCookingModeView() {
    if (_currentStep >= widget.instructions.length) {
      return Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(Icons.celebration, size: 60, color: AppColors.success),
            const SizedBox(height: 16),
            Text(
              'Selamat! Resep telah selesai!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.success,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final instruction = widget.instructions[_currentStep];
    final description =
        instruction['description'] ??
        instruction['text'] ??
        instruction['instruction_text'] ??
        '';
    final timerMinutes = instruction['timer_minutes'] as int?;

    return Column(
      children: [
        // Current step indicator
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withOpacity(0.1),
                AppColors.primary.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        '${_currentStep + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Langkah ${_currentStep + 1}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        if (timerMinutes != null && timerMinutes > 0)
                          Text(
                            'Durasi: ${_formatDuration(timerMinutes)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Navigation buttons
        Row(
          children: [
            if (_currentStep > 0)
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _currentStep--;
                    });
                  },
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Sebelumnya'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.grey[700],
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),

            if (_currentStep > 0) const SizedBox(width: 12),

            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (_currentStep < widget.instructions.length - 1) {
                    setState(() {
                      _currentStep++;
                      _completedSteps.add(_currentStep - 1);
                    });
                  } else {
                    // Recipe completed
                    setState(() {
                      _completedSteps.add(_currentStep);
                      _currentStep++;
                    });
                  }
                },
                icon: Icon(
                  _currentStep == widget.instructions.length - 1
                      ? Icons.check
                      : Icons.arrow_forward,
                ),
                label: Text(
                  _currentStep == widget.instructions.length - 1
                      ? 'Selesai'
                      : 'Lanjut',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _currentStep == widget.instructions.length - 1
                          ? AppColors.success
                          : AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDuration(int? minutes) {
    if (minutes == null || minutes <= 0) return '';

    if (minutes < 60) {
      return '${minutes} menit';
    } else {
      int hours = minutes ~/ 60;
      int remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '${hours} jam';
      } else {
        return '${hours}j ${remainingMinutes}m';
      }
    }
  }
}
