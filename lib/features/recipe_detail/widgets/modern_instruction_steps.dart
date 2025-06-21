import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../models/recipe.dart';
import 'cooking_mode_view.dart';

class ModernInstructionSteps extends StatefulWidget {
  final List<Map<String, dynamic>> instructions;
  final Recipe? recipe;  const ModernInstructionSteps({
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
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
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
      return _buildEmptyState(context);
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
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
              child: Row(
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
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Langkah Memasak',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${widget.instructions.length} langkah',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],                  ),
                  const Spacer(),
                  // Buttons row - make more compact
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Full Cooking Mode Button
                      if (widget.recipe != null)
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CookingModeView(
                                  recipe: widget.recipe!,
                                  onExit: () {
                                    Navigator.pop(context);
                                  },
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.kitchen,
                                  color: Colors.white,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  'Mode',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (widget.recipe != null) const SizedBox(width: 8),
                      // Cooking mode toggle - more compact
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isCookingMode = !_isCookingMode;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: _isCookingMode
                                ? Colors.white.withOpacity(0.3)
                                : Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _isCookingMode ? Icons.pause : Icons.play_arrow,
                                color: Colors.white,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _isCookingMode ? 'Stop' : 'Cook',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
            ),

            // Progress indicator
            if (_isCookingMode)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: _completedSteps.length / widget.instructions.length,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.success),
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
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
              child: _isCookingMode
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
      children: List.generate(
        widget.instructions.length,
        (index) => _buildInstructionStep(index),
      ),
    );
  }

  Widget _buildCookingModeView() {
    final currentInstruction = widget.instructions[_currentStep];
    
    return Column(
      children: [
        // Current step card
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary.withOpacity(0.1),
                AppColors.primary.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Step image
              if (currentInstruction['image_url'] != null)
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      currentInstruction['image_url'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: Icon(
                            Icons.image_not_supported,
                            color: Colors.grey[400],
                            size: 48,
                          ),
                        );
                      },
                    ),
                  ),
                ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${_currentStep + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Langkah ${_currentStep + 1}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),                        const Spacer(),
                        if (currentInstruction['duration'] != null || currentInstruction['timer_minutes'] != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.highlight.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.timer,
                                  size: 16,
                                  color: AppColors.highlight,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _formatDuration(currentInstruction),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.highlight,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      currentInstruction['description'] ?? currentInstruction['text'] ?? 'No description',
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Navigation buttons
        Row(
          children: [
            if (_currentStep > 0) ...[
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
                    backgroundColor: Colors.grey[100],
                    foregroundColor: Colors.grey[700],
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
            
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _completedSteps.add(_currentStep);
                    if (_currentStep < widget.instructions.length - 1) {
                      _currentStep++;
                    } else {
                      // Completed all steps
                      _showCompletionDialog();
                    }
                  });
                },
                icon: Icon(_currentStep < widget.instructions.length - 1 
                    ? Icons.arrow_forward 
                    : Icons.check),
                label: Text(_currentStep < widget.instructions.length - 1 
                    ? 'Selanjutnya' 
                    : 'Selesai'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Step indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.instructions.length,
            (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: index == _currentStep
                    ? AppColors.primary
                    : _completedSteps.contains(index)
                        ? AppColors.success
                        : Colors.grey[300],
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInstructionStep(int index) {
    final instruction = widget.instructions[index];
    final isCompleted = _completedSteps.contains(index);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isCompleted ? AppColors.success.withOpacity(0.1) : Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCompleted ? AppColors.success : Colors.grey[300]!,
          width: isCompleted ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step image
          if (instruction['image_url'] != null)
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  instruction['image_url'],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: Icon(
                        Icons.image_not_supported,
                        color: Colors.grey[400],
                        size: 48,
                      ),
                    );
                  },
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Step number
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isCompleted ? AppColors.success : AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 18,
                          )
                        : Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                  ),
                ),

                const SizedBox(width: 16),

                // Step content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [                      Row(
                        children: [
                          Text(
                            'Langkah ${index + 1}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isCompleted ? Colors.grey[600] : Colors.black87,
                            ),
                          ),
                          const Spacer(),
                          if (instruction['duration'] != null || instruction['timer_minutes'] != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.highlight.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.timer,
                                    size: 14,
                                    color: AppColors.highlight,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _formatDuration(instruction),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.highlight,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        instruction['description'] ?? instruction['text'] ?? 'No description',
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: isCompleted ? Colors.grey[600] : Colors.black87,
                          decoration: isCompleted ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ],
                  ),
                ),

                // Complete button
                GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isCompleted) {
                        _completedSteps.remove(index);
                      } else {
                        _completedSteps.add(index);
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isCompleted 
                          ? AppColors.success.withOpacity(0.2)
                          : AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                      color: isCompleted ? AppColors.success : AppColors.primary,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.celebration,
                  color: AppColors.success,
                  size: 48,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Selamat! 🎉',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Anda telah menyelesaikan semua langkah memasak!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _isCookingMode = false;
                  _currentStep = 0;
                });
              },
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.restaurant_menu_outlined,
              size: 40,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada langkah',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Resep ini belum memiliki langkah memasak',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),        ],
      ),
    );
  }

  String _formatDuration(Map<String, dynamic> instruction) {
    // Prioritaskan timer_minutes dari database
    if (instruction['timer_minutes'] != null) {
      final minutes = instruction['timer_minutes'] as int;
      return _formatMinutes(minutes);
    }
    
    // Fallback ke duration jika timer_minutes tidak ada
    if (instruction['duration'] != null) {
      final duration = instruction['duration'] as String;
      
      // Jika duration sudah dalam format yang baik, gunakan langsung
      if (duration.contains('menit') || duration.contains('jam') || duration.contains('detik')) {
        return duration;
      }
      
      // Coba parse angka dari duration string
      final numbers = RegExp(r'\d+').allMatches(duration);
      if (numbers.isNotEmpty) {
        final firstNumber = int.tryParse(numbers.first.group(0) ?? '0');
        if (firstNumber != null) {
          return _formatMinutes(firstNumber);
        }
      }
      
      // Jika tidak bisa di-parse, return duration asli
      return duration;
    }
    
    // Default jika tidak ada data waktu
    return '5 menit';
  }

  String _formatMinutes(int minutes) {
    if (minutes == 0) {
      return '< 1 menit';
    } else if (minutes < 60) {
      return '$minutes menit';
    } else if (minutes == 60) {
      return '1 jam';
    } else if (minutes < 120) {
      final remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '1 jam';
      } else {
        return '1 jam $remainingMinutes menit';
      }
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '$hours jam';
      } else {
        return '$hours jam $remainingMinutes menit';
      }
    }
  }
}
