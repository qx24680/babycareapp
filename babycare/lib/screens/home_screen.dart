import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_theme.dart';
import '../models/activity_log.dart';
import '../services/baby_repository.dart';
import '../widgets/timeline_feed.dart';
import '../widgets/activity_logger_modal.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title, this.babyId, this.userId});

  final String title;
  final int? babyId;
  final int? userId;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _repository = BabyRepository();
  List<ActivityLog> _activities = [];
  bool _isLoading = true;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    if (widget.babyId == null) {
      setState(() => _isLoading = false);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Load activities for selected date and previous 6 days
      final activities = <ActivityLog>[];
      
      for (int i = 0; i < 7; i++) {
        final date = _selectedDate.subtract(Duration(days: i));
        final dailyLogs = await _repository.getDailyLogs(widget.babyId!, date);
        activities.addAll(dailyLogs);
      }

      // Sort by newest first
      activities.sort((a, b) => b.startTime.compareTo(a.startTime));

      setState(() {
        _activities = activities;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _showDatePicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 300,
        color: CupertinoColors.systemBackground,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  CupertinoButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _loadActivities();
                    },
                    child: const Text('Done'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: _selectedDate,
                maximumDate: DateTime.now(),
                onDateTimeChanged: (newDate) {
                  setState(() => _selectedDate = newDate);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showActivityLogger() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => ActivityLoggerModal(
        babyId: widget.babyId ?? 1, // Default to 1 for demo
        userId: widget.userId,
        onActivityLogged: () {
          _loadActivities();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          widget.title,
          style: CupertinoTheme.of(context).textTheme.navTitleTextStyle.copyWith(
                color: CupertinoColors.white,
                fontWeight: FontWeight.w600,
              ),
        ),
        backgroundColor: AppColors.primary,
        border: null,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _showDatePicker,
          child: const Icon(CupertinoIcons.calendar, color: CupertinoColors.white),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            // TODO: Navigate to profile/settings
          },
          child: const Icon(CupertinoIcons.person_circle, color: CupertinoColors.white),
        ),
      ),
      child: Stack(
        children: [
          // Gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primary.withValues(alpha: 0.05),
                  AppColors.background,
                  AppColors.secondary.withValues(alpha: 0.03),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Date selector bar
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.1),
                        CupertinoColors.white,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    boxShadow: AppShadows.card,
                  ),
                  child: GestureDetector(
                    onTap: _showDatePicker,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: CupertinoColors.white,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          width: 1,
                        ),
                        boxShadow: AppShadows.sm,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.xs),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                            ),
                            child: const Icon(
                              CupertinoIcons.calendar_today,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              _selectedDate.day == DateTime.now().day &&
                                      _selectedDate.month == DateTime.now().month &&
                                      _selectedDate.year == DateTime.now().year
                                  ? 'Today'
                                  : DateFormat('MMM d, yyyy').format(_selectedDate),
                              style: AppTypography.body.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.text,
                              ),
                            ),
                          ),
                          Icon(
                            CupertinoIcons.chevron_down,
                            color: AppColors.primary,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Timeline content
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CupertinoActivityIndicator(
                            radius: 16,
                            color: AppColors.primary,
                          ),
                        )
                      : widget.babyId == null
                          ? _buildNoBabyState()
                          : TimelineFeed(
                              activities: _activities,
                              onRefresh: _loadActivities,
                            ),
                ),
              ],
            ),
          ),
          
          // Floating Action Button
          Positioned(
            right: AppSpacing.lg,
            bottom: AppSpacing.xl,
            child: GestureDetector(
              onTap: _showActivityLogger,
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      offset: const Offset(0, 4),
                      blurRadius: 16,
                      spreadRadius: 0,
                    ),
                    ...AppShadows.lg,
                  ],
                ),
                child: const Icon(
                  CupertinoIcons.add,
                  color: CupertinoColors.white,
                  size: 32,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoBabyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.2),
                    AppColors.secondary.withValues(alpha: 0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(AppRadius.full),
                boxShadow: AppShadows.md,
              ),
              child: const Icon(
                CupertinoIcons.person_2_fill,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            const Text(
              'Welcome to BabyCare!',
              style: AppTypography.h1,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Create a baby profile to start tracking activities',
              style: AppTypography.body.copyWith(
                color: AppColors.text.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(AppRadius.md),
                boxShadow: AppShadows.md,
              ),
              child: CupertinoButton(
                onPressed: () {
                  // TODO: Navigate to create baby profile
                },
                child: const Text(
                  'Create Baby Profile',
                  style: TextStyle(color: CupertinoColors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
