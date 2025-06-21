import 'dart:async';
import 'package:flutter/material.dart';

class CompactTimerDisplay extends StatefulWidget {
  final int? durationMinutes;
  final String stepDescription;
  final bool autoStart;
  final VoidCallback? onComplete;

  const CompactTimerDisplay({
    Key? key,
    this.durationMinutes,
    required this.stepDescription,
    this.autoStart = false,
    this.onComplete,
  }) : super(key: key);

  @override
  State<CompactTimerDisplay> createState() => _CompactTimerDisplayState();
}

class _CompactTimerDisplayState extends State<CompactTimerDisplay>
    with SingleTickerProviderStateMixin {
  Timer? _timer;
  int _remainingSeconds = 0;
  int _totalSeconds = 0;
  bool _isRunning = false;
  late AnimationController _animationController;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    
    if (widget.durationMinutes != null) {
      _totalSeconds = widget.durationMinutes! * 60;
      _remainingSeconds = _totalSeconds;
    }

    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _colorAnimation = ColorTween(
      begin: Colors.blue,
      end: Colors.orange,
    ).animate(_animationController);

    if (widget.autoStart && widget.durationMinutes != null) {
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _startTimer() {
    if (_isRunning || widget.durationMinutes == null) return;

    setState(() {
      _isRunning = true;
    });

    _animationController.repeat(reverse: true);

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
    _timer?.cancel();
    _animationController.stop();
    setState(() {
      _isRunning = false;
    });
  }

  void _completeTimer() {
    _timer?.cancel();
    _animationController.stop();
    setState(() {
      _isRunning = false;
      _remainingSeconds = 0;
    });
    widget.onComplete?.call();
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
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

  Color get _timerColor {
    if (_remainingSeconds <= 30) return Colors.red;
    if (_remainingSeconds <= 60) return Colors.orange;
    return Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    // If no timer duration, show step without timer
    if (widget.durationMinutes == null || widget.durationMinutes! <= 0) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: Colors.grey[600],
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.stepDescription,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _timerColor.withOpacity(0.1),
            _timerColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _timerColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timer header
          Row(
            children: [
              AnimatedBuilder(
                animation: _colorAnimation,
                builder: (context, child) {
                  return Icon(
                    _isRunning ? Icons.timer : Icons.timer_outlined,
                    color: _isRunning ? _colorAnimation.value : _timerColor,
                    size: 24,
                  );
                },
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isRunning ? 'Timer Berjalan' : 'Waktu Disarankan',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _timerColor,
                      ),
                    ),
                    Text(
                      _isRunning 
                          ? _formatTime(_remainingSeconds)
                          : _formatDuration(widget.durationMinutes),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _timerColor,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
              // Control button
              if (!_isRunning)
                GestureDetector(
                  onTap: _startTimer,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _timerColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              if (_isRunning)
                GestureDetector(
                  onTap: _pauseTimer,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _timerColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.pause,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Progress bar (only when timer is running)
          if (_isRunning && _totalSeconds > 0)
            LinearProgressIndicator(
              value: (_totalSeconds - _remainingSeconds) / _totalSeconds,
              backgroundColor: _timerColor.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation(_timerColor),
              minHeight: 4,
            ),
          
          if (_isRunning) const SizedBox(height: 12),
          
          // Step description
          Text(
            widget.stepDescription,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
