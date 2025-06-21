import 'dart:async';
import 'package:flutter/material.dart';

class LiveClock extends StatefulWidget {
  final TextStyle? textStyle;
  final Color? backgroundColor;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;

  const LiveClock({
    Key? key,
    this.textStyle,
    this.backgroundColor,
    this.padding,
    this.borderRadius,
  }) : super(key: key);

  @override
  State<LiveClock> createState() => _LiveClockState();
}

class _LiveClockState extends State<LiveClock> {
  late Timer _timer;
  DateTime _currentTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime time) {
    const List<String> days = [
      'Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'
    ];
    const List<String> months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];

    return '${days[time.weekday % 7]}, ${time.day} ${months[time.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? Colors.black.withOpacity(0.7),
        borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _formatTime(_currentTime),
            style: widget.textStyle ??
                const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
          ),
          Text(
            _formatDate(_currentTime),
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class CookingSessionTimer extends StatefulWidget {
  final DateTime startTime;
  final TextStyle? textStyle;
  final Color? backgroundColor;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;

  const CookingSessionTimer({
    Key? key,
    required this.startTime,
    this.textStyle,
    this.backgroundColor,
    this.padding,
    this.borderRadius,
  }) : super(key: key);

  @override
  State<CookingSessionTimer> createState() => _CookingSessionTimerState();
}

class _CookingSessionTimerState extends State<CookingSessionTimer> {
  late Timer _timer;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _elapsed = DateTime.now().difference(widget.startTime);
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    int hours = duration.inHours;
    int minutes = duration.inMinutes % 60;
    int seconds = duration.inSeconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? Colors.green.withOpacity(0.1),
        borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
        border: Border.all(
          color: Colors.green.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.timer,
                color: Colors.green,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                'Memasak: ${_formatDuration(_elapsed)}',
                style: widget.textStyle ??
                    const TextStyle(
                      color: Colors.green,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'monospace',
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
