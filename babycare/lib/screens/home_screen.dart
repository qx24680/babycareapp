import 'package:flutter/cupertino.dart';
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
      // Load activities from today going back 7 days
      final activities = <ActivityLog>[];
      final now = DateTime.now();
      
      for (int i = 0; i < 7; i++) {
        final date = now.subtract(Duration(days: i));
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
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          widget.title,
          style: CupertinoTheme.of(context).textTheme.navTitleTextStyle,
        ),
        backgroundColor: AppColors.primary,
        border: null,
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            // TODO: Navigate to profile/settings
          },
          child: const Icon(CupertinoIcons.person_circle),
        ),
      ),
      child: Stack(
        children: [
          SafeArea(
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
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  boxShadow: AppShadows.lg,
                ),
                child: const Icon(
                  CupertinoIcons.add,
                  color: AppColors.text,
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
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.full),
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
            CupertinoButton(
              color: AppColors.primary,
              onPressed: () {
                // TODO: Navigate to create baby profile
              },
              child: const Text(
                'Create Baby Profile',
                style: TextStyle(color: AppColors.text),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
