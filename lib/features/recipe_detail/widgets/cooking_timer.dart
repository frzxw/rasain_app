import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

class CookingTimer extends StatefulWidget {
  final int durationMinutes;
  final String stepDescription;
  final VoidCallback? onTimerComplete;
  final bool autoStart;

  const CookingTimer({
    Key? key,
    required this.durationMinutes,
    required this.stepDescription,
    this.onTimerComplete,
    this.autoStart = false,
  }) : super(key: key);

  @override
  State<CookingTimer> createState() => _CookingTimerState();
}

class _CookingTimerState extends State<CookingTimer>
    with TickerProviderStateMixin {
  Timer? _timer;
  int _remainingSeconds = 0;
  int _totalSeconds = 0;
  bool _isRunning = false;
  bool _isCompleted = false;

  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late AnimationController _scaleController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _totalSeconds = widget.durationMinutes * 60;
    _remainingSeconds = _totalSeconds;

    // Animation controllers
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _rotationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    // Animations
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));

    if (widget.autoStart) {
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _rotationController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _startTimer() {
    if (_isRunning || _isCompleted) return;

    setState(() {
      _isRunning = true;
    });

    _pulseController.repeat(reverse: true);
    _rotationController.repeat();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _completeTimer();
        }
      });
    });
  }

  void _pauseTimer() {
    if (!_isRunning) return;

    setState(() {
      _isRunning = false;
    });

    _timer?.cancel();
    _pulseController.stop();
    _rotationController.stop();
  }

  void _resetTimer() {
    _timer?.cancel();
    _pulseController.reset();
    _rotationController.reset();
    _scaleController.reset();

    setState(() {
      _remainingSeconds = _totalSeconds;
      _isRunning = false;
      _isCompleted = false;
    });
  }

  void _completeTimer() {
    _timer?.cancel();
    _pulseController.stop();
    _rotationController.stop();

    setState(() {
      _isRunning = false;
      _isCompleted = true;
      _remainingSeconds = 0;
    });

    // Completion animation
    _scaleController.forward().then((_) {
      _scaleController.reverse();
    });

    widget.onTimerComplete?.call();

    // Show completion notification
    _showCompletionDialog();
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(
              Icons.timer_off,
              color: Colors.green,
              size: 28,
            ),
            const SizedBox(width: 12),
            const Text(
              'Waktu Selesai!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                widget.stepDescription,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Lanjut ke langkah berikutnya?',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetTimer();
            },
            child: const Text('Ulangi'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Lanjut'),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  String _formatCurrentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  double get _progress {
    if (_totalSeconds == 0) return 0.0;
    return (_totalSeconds - _remainingSeconds) / _totalSeconds;
  }

  Color get _timerColor {
    if (_isCompleted) return Colors.green;
    if (_remainingSeconds <= 30) return Colors.red;
    if (_remainingSeconds <= 60) return Colors.orange;
    return Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _timerColor.withOpacity(0.1),
            _timerColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _timerColor.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: _timerColor.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Current Time Display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 8),
                StreamBuilder(
                  stream: Stream.periodic(const Duration(seconds: 1)),
                  builder: (context, snapshot) {
                    return Text(
                      'Sekarang: ${_formatCurrentTime()}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Main Timer Circle
          AnimatedBuilder(
            animation: Listenable.merge([
              _pulseAnimation,
              _rotationAnimation,
              _scaleAnimation,
            ]),
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Transform.scale(
                  scale: _isRunning ? _pulseAnimation.value : 1.0,
                  child: Container(
                    width: 200,
                    height: 200,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Background Circle
                        Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: _timerColor.withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                        ),

                        // Progress Circle
                        Transform.rotate(
                          angle: _isRunning ? _rotationAnimation.value : 0,
                          child: SizedBox(
                            width: 180,
                            height: 180,
                            child: CircularProgressIndicator(
                              value: _progress,
                              strokeWidth: 8,
                              backgroundColor: _timerColor.withOpacity(0.2),
                              valueColor: AlwaysStoppedAnimation(_timerColor),
                            ),
                          ),
                        ),

                        // Timer Text
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _formatTime(_remainingSeconds),
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: _timerColor,
                                fontFamily: 'monospace',
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _isCompleted
                                  ? 'Selesai!'
                                  : _isRunning
                                      ? 'Sedang berjalan'
                                      : 'Siap dimulai',
                              style: TextStyle(
                                fontSize: 12,
                                color: _timerColor.withOpacity(0.7),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),

                        // Cooking Icon Animation
                        if (_isRunning)
                          Positioned(
                            top: 20,
                            child: Transform.rotate(
                              angle: _rotationAnimation.value,
                              child: Icon(
                                Icons.local_fire_department,
                                color: Colors.orange,
                                size: 24,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // Step Description
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _timerColor.withOpacity(0.2),
              ),
            ),
            child: Text(
              widget.stepDescription,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 24),

          // Control Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Reset Button
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: FloatingActionButton(
                  onPressed: _resetTimer,
                  backgroundColor: Colors.grey[100],
                  foregroundColor: Colors.grey[700],
                  mini: true,
                  child: const Icon(Icons.refresh),
                ),
              ),

              // Play/Pause Button
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _timerColor.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: FloatingActionButton(
                  onPressed: _isRunning ? _pauseTimer : _startTimer,
                  backgroundColor: _timerColor,
                  foregroundColor: Colors.white,
                  child: Icon(
                    _isRunning ? Icons.pause : Icons.play_arrow,
                    size: 32,
                  ),
                ),
              ),

              // Skip Button
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: FloatingActionButton(
                  onPressed: _completeTimer,
                  backgroundColor: Colors.grey[100],
                  foregroundColor: Colors.grey[700],
                  mini: true,
                  child: const Icon(Icons.skip_next),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
