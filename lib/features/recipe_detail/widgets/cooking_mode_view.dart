import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../models/recipe.dart';
import 'cooking_timer.dart';

class CookingModeView extends StatefulWidget {
  final Recipe recipe;
  final VoidCallback? onExit;

  const CookingModeView({
    Key? key,
    required this.recipe,
    this.onExit,
  }) : super(key: key);

  @override
  State<CookingModeView> createState() => _CookingModeViewState();
}

class _CookingModeViewState extends State<CookingModeView>
    with TickerProviderStateMixin {
  int _currentStep = 0;
  bool _isTimerActive = false;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  @override
  void initState() {
    super.initState();
    
    // Keep screen on during cooking
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    ));
    
    _slideController.forward();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _slideController.dispose();
    super.dispose();
  }
  void _nextStep() {
    if (_currentStep < (widget.recipe.instructions?.length ?? 0) - 1) {
      setState(() {
        _currentStep++;
        _isTimerActive = false;
      });
      
      _slideController.reset();
      _slideController.forward();
      
      // Haptic feedback
      HapticFeedback.lightImpact();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
        _isTimerActive = false;
      });
      
      _slideController.reset();
      _slideController.forward();
      
      HapticFeedback.lightImpact();
    }
  }

  void _startTimer() {
    setState(() {
      _isTimerActive = true;
    });
  }

  void _onTimerComplete() {
    HapticFeedback.heavyImpact();
    
    // Auto advance to next step after timer completion
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && _currentStep < (widget.recipe.instructions?.length ?? 0) - 1) {
        _nextStep();
      }
    });
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
  @override
  Widget build(BuildContext context) {
    final instructions = widget.recipe.instructions ?? [];
    if (instructions.isEmpty) {
      return Scaffold(
        body: Center(
          child: Text('Tidak ada instruksi untuk resep ini'),
        ),
      );
    }

    final instruction = instructions[_currentStep];
    final isLastStep = _currentStep == instructions.length - 1;
    final timerMinutes = instruction['timer_minutes'] as int?;
    final hasTimer = timerMinutes != null && timerMinutes > 0;
    final instructionText = instruction['description'] ?? instruction['text'] ?? instruction['instruction_text'] ?? '';
    final imageUrl = instruction['image_url'] as String?;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Header with progress and controls
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Top controls
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Keluar dari Mode Memasak?'),
                              content: const Text(
                                'Progress memasak akan hilang jika keluar sekarang.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Batal'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    widget.onExit?.call();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('Keluar'),
                                ),
                              ],
                            ),
                          );
                        },
                        icon: const Icon(Icons.close),
                      ),
                      Expanded(
                        child: Text(
                          widget.recipe.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          // Show ingredients quick reference
                          showModalBottomSheet(
                            context: context,
                            builder: (context) => Container(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Bahan-bahan',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),                                  ...(widget.recipe.ingredients ?? []).map(
                                    (ingredient) => Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.orange,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              '${ingredient['quantity'] ?? ''} ${ingredient['unit'] ?? ''} ${ingredient['name'] ?? ''}',
                                              style: const TextStyle(fontSize: 16),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.list_alt),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Progress bar
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Langkah ${_currentStep + 1} dari ${instructions.length}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '${((_currentStep + 1) / instructions.length * 100).round()}%',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: (_currentStep + 1) / instructions.length,
                        backgroundColor: Colors.grey[300],
                        valueColor: const AlwaysStoppedAnimation(Colors.orange),
                        minHeight: 6,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Main content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    children: [
                      // Step instruction
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
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
                                    color: Colors.orange,
                                    borderRadius: BorderRadius.circular(12),
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
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.orange,
                                        ),
                                      ),
                                      if (hasTimer)
                                        Text(
                                          'Durasi: ${_formatDuration(timerMinutes)}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Text(
                              instructionText,
                              style: const TextStyle(
                                fontSize: 18,
                                height: 1.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Timer section
                      if (hasTimer && !_isTimerActive)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.orange.withOpacity(0.1),
                                Colors.orange.withOpacity(0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.orange.withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.timer,
                                size: 48,
                                color: Colors.orange,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Waktu yang disarankan: ${_formatDuration(timerMinutes)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: _startTimer,
                                icon: const Icon(Icons.play_arrow),
                                label: const Text('Mulai Timer'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Active timer
                      if (hasTimer && _isTimerActive)
                        CookingTimer(                          durationMinutes: timerMinutes,
                          stepDescription: instructionText,
                          onTimerComplete: _onTimerComplete,
                          autoStart: true,
                        ),

                      const SizedBox(height: 20),                      // Image placeholder (if available)
                      if (imageUrl != null)
                        Container(
                          width: double.infinity,
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.grey[200],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[200],
                                  child: const Center(
                                    child: Icon(
                                      Icons.image_not_supported,
                                      size: 48,
                                      color: Colors.grey,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // Navigation buttons
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Previous button
                  if (_currentStep > 0)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _previousStep,
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Sebelumnya'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[100],
                          foregroundColor: Colors.grey[700],
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  
                  if (_currentStep > 0) const SizedBox(width: 16),
                  
                  // Next/Finish button
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: isLastStep
                          ? () {
                              // Show completion dialog
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('🎉 Selamat!'),
                                  content: Text(
                                    'Anda telah menyelesaikan resep ${widget.recipe.name}!',
                                  ),
                                  actions: [
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        widget.onExit?.call();
                                      },
                                      child: const Text('Selesai'),
                                    ),
                                  ],
                                ),
                              );
                            }
                          : _nextStep,
                      icon: Icon(
                        isLastStep ? Icons.check : Icons.arrow_forward,
                      ),
                      label: Text(
                        isLastStep ? 'Selesai' : 'Lanjut',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isLastStep ? Colors.green : Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
