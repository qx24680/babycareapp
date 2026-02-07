import 'package:flutter/cupertino.dart';
import '../core/theme/app_theme.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Statistics'),
        backgroundColor: AppColors.surface,
        border: null,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.graph_circle,
              size: 64,
              color: AppColors.textLight.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Statistics Coming Soon',
              style: AppTypography.body.copyWith(color: AppColors.textLight),
            ),
          ],
        ),
      ),
    );
  }
}
