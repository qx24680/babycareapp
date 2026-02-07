import 'dart:async';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import '../core/constants/activity_types.dart';
import '../core/theme/app_theme.dart';

class BreastfeedingScreen extends StatefulWidget {
  final Function({
    required String activityType,
    required Map<String, dynamic> metadata,
    DateTime? startTime,
    DateTime? endTime,
  })
  onSubmit;

  const BreastfeedingScreen({super.key, required this.onSubmit});

  @override
  State<BreastfeedingScreen> createState() => _BreastfeedingScreenState();
}

class _BreastfeedingScreenState extends State<BreastfeedingScreen> {
  // Timer State
  Timer? _timer;
  String? _activeSide; // 'left' or 'right' or null
  int _leftSeconds = 0;
  int _rightSeconds = 0;
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _timer?.cancel();
    _notesController.dispose();
    super.dispose();
  }

  void _toggleTimer(String side) {
    if (_activeSide == side) {
      // Pause
      _pauseTimer();
    } else {
      // Switch side (automatically pauses other side)
      _timer?.cancel();
      setState(() {
        _activeSide = side;
      });
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          if (side == 'left') {
            _leftSeconds++;
          } else {
            _rightSeconds++;
          }
        });
      });
    }
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _activeSide = null;
    });
  }

  String _formatDuration(int totalSeconds) {
    final m = totalSeconds ~/ 60;
    final s = totalSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _submit() {
    final now = DateTime.now();

    // Submit Left if it has duration
    if (_leftSeconds > 0) {
      widget.onSubmit(
        activityType: ActivityTypes.feeding,
        metadata: {
          'feeding_type': FeedingTypes.breast,
          'side': 'left',
          'duration_minutes': (_leftSeconds / 60).round() < 1
              ? 1
              : (_leftSeconds / 60).round(),
        },
        startTime: now.subtract(Duration(seconds: _leftSeconds)),
      );
    }

    // Submit Right if it has duration
    if (_rightSeconds > 0) {
      widget.onSubmit(
        activityType: ActivityTypes.feeding,
        metadata: {
          'feeding_type': FeedingTypes.breast,
          'side': 'right',
          'duration_seconds': _rightSeconds,
          'duration_minutes': (_rightSeconds / 60).round() < 1
              ? 1
              : (_rightSeconds / 60).round(),
        },
        startTime: now.subtract(Duration(seconds: _rightSeconds)),
      );
    }

    // Close screen handled by callback
    // Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final totalSeconds = _leftSeconds + _rightSeconds;

    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Breastfeeding'),
        backgroundColor: AppColors.background,
        border: null,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    // 1. Total Duration
                    Column(
                      children: [
                        Text(
                          'Total Duration',
                          style: AppTypography.body.copyWith(
                            color: AppColors.textLight,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDuration(totalSeconds),
                          style: AppTypography.h1.copyWith(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            fontFeatures: [const FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // 2. Side Timers
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildTimerButton(
                          'Left',
                          _leftSeconds,
                          _activeSide == 'left',
                        ),
                        _buildTimerButton(
                          'Right',
                          _rightSeconds,
                          _activeSide == 'right',
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // 3. Notes
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Notes', style: AppTypography.h3),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    CupertinoTextField(
                      controller: _notesController,
                      placeholder: 'Add any notes...',
                      maxLines: 3,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: CupertinoColors.white,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(color: AppColors.divider),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Submit Button Area
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                boxShadow: AppShadows.sm,
              ),
              child: SafeArea(
                top: false,
                child: CupertinoButton.filled(
                  onPressed: (_leftSeconds == 0 && _rightSeconds == 0)
                      ? null
                      : _submit,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  child: const Text('Save Entry', style: AppTypography.button),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimerButton(String sideLabel, int seconds, bool isActive) {
    return GestureDetector(
      onTap: () => _toggleTimer(sideLabel.toLowerCase()),
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? AppColors.primary : CupertinoColors.white,
              border: Border.all(
                color: isActive ? AppColors.primary : AppColors.divider,
                width: 4,
              ),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            alignment: Alignment.center,
            child: isActive
                ? const Icon(
                    CupertinoIcons.pause_fill,
                    size: 48,
                    color: CupertinoColors.white,
                  )
                : const Icon(
                    CupertinoIcons.play_fill,
                    size: 48,
                    color: AppColors.primary,
                  ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(sideLabel, style: AppTypography.h3),
          const SizedBox(height: 4),
          Text(
            _formatDuration(seconds),
            style: AppTypography.body.copyWith(
              color: isActive ? AppColors.primary : AppColors.textLight,
              fontWeight: FontWeight.w600,
              fontFeatures: [const FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
