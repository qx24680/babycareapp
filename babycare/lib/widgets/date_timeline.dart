import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_theme.dart';

class DateTimeline extends StatefulWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  const DateTimeline({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  State<DateTimeline> createState() => _DateTimelineState();
}

class _DateTimelineState extends State<DateTimeline> {
  late ScrollController _scrollController;
  final int _daysBack = 30; // Activity log usually looks back

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    // Scroll to end (today) after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        // Simple calculation: item width approx 60 + spacing.
        // Better to just jump to end for "Today"
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Generate dates: Today - 30 days ... Today
    final dates = List.generate(_daysBack + 1, (index) {
      return DateTime.now().subtract(Duration(days: _daysBack - index));
    });

    return SizedBox(
      height: 80,
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        separatorBuilder: (context, index) =>
            const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final date = dates[index];
          final isSelected = _isSameDay(date, widget.selectedDate);
          final isToday = _isSameDay(date, DateTime.now());

          return _buildDateItem(date, isSelected, isToday);
        },
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Widget _buildDateItem(DateTime date, bool isSelected, bool isToday) {
    return GestureDetector(
      onTap: () => widget.onDateSelected(date),
      child: Container(
        width: 60,
        margin: const EdgeInsets.symmetric(vertical: 4), // Margin for shadow
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : CupertinoColors.white,
          borderRadius: BorderRadius.circular(AppRadius.md),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    offset: const Offset(0, 4),
                    blurRadius: 10,
                  ),
                ]
              : [
                  BoxShadow(
                    color: AppColors.text.withValues(alpha: 0.05),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
          border: isToday && !isSelected
              ? Border.all(color: AppColors.primary, width: 1.5)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              DateFormat('E').format(date).toUpperCase(), // MON, TUE
              style: AppTypography.caption.copyWith(
                color: isSelected
                    ? CupertinoColors.white.withValues(alpha: 0.8)
                    : AppColors.textLight,
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              date.day.toString(),
              style: AppTypography.h3.copyWith(
                color: isSelected ? CupertinoColors.white : AppColors.text,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
