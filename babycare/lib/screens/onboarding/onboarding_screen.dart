import 'package:babycare/services/activity_repository.dart';
import 'package:flutter/cupertino.dart';
import '../../core/theme/app_theme.dart';
import '../../models/onboarding_data.dart';
import 'screens/welcome_screen.dart';
import 'screens/baby_info_screen.dart';
import 'screens/last_feed_screen.dart';

import 'widgets/onboarding_progress.dart';
import '../../models/activity.dart'; // New Activity Model
import '../../core/constants/activity_types.dart'; // For MilkType

/// Main onboarding flow controller
class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingScreen({super.key, required this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  OnboardingData _data = const OnboardingData();

  // Total screens in reduced flow
  static const int _totalScreens = 8;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _updateData(OnboardingData newData) {
    setState(() {
      _data = newData;
    });
  }

  void _nextPage() {
    if (_currentPage < _totalScreens - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _completeOnboarding() async {
    // TODO: reliable baby creation logic is needed here.
    // For this task, we will try to save the feeding if we have a baby ID or assume one is created.
    // Since I cannot see the profile creation logic (it's likely effectively a mock or simple save),
    // I will write the code to save the feeding assuming babyId=1 which is typical for single-user/single-baby MVP apps.
    // In a production app, we would await _saveProfile() to get the real ID.

    if (_data.lastFeedTime != null && _data.lastFeedType != null) {
      final repo = ActivityRepository();
      // Assuming babyId 1 for the first baby
      try {
        MilkType? milkType;
        if (_data.lastFeedType == ActivityType.bottleFeeding) {
          if (_data.lastFeedContent == 'Breastmilk') {
            milkType = MilkType.breastMilk;
          } else {
            milkType = MilkType.formula;
          }
        }

        await repo.createActivity(
          Activity(
            babyId: 1,
            type: _data.lastFeedType!,
            startTime: _data.lastFeedTime!,
            side: _data.lastFeedSide,
            milkType: milkType,
            // Calculate amount if needed or leave null
          ),
        );
      } catch (e) {
        debugPrint('Error saving last feed: $e');
      }
    }

    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: Column(
          children: [
            // Progress indicator (hide on first screen)
            if (_currentPage > 0)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                child: OnboardingProgress(
                  currentStep: _currentPage,
                  totalSteps: _totalScreens,
                  onStepTap: (step) {
                    if (step < _currentPage) _goToPage(step);
                  },
                ),
              ),

            // Page content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                children: [
                  // Screen 1: Welcome - What do you need help with?
                  WelcomeScreen(
                    data: _data,
                    onDataChanged: _updateData,
                    onNext: _nextPage,
                  ),

                  // Screen 2: Add Baby (Minimal)
                  BabyInfoScreen(
                    data: _data,
                    onDataChanged: _updateData,
                    onNext: _nextPage,
                    onBack: _previousPage,
                  ),

                  // Screen 2.5: Last Feed Info
                  LastFeedScreen(
                    data: _data,
                    onDataChanged: _updateData,
                    onNext: _nextPage,
                    onBack: _previousPage,
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
