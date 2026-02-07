import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../models/activity.dart';
import '../../models/measurement.dart';
import '../../services/statistics_service.dart';
import '../../core/theme/app_theme.dart';
import 'stats_summary_card.dart';
import 'last_activity_card.dart';

class StatsCharts extends StatelessWidget {
  final ActivityType type;
  final DateTime startDate;
  final DateTime endDate;
  final StatisticsService service;

  const StatsCharts({
    super.key,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case ActivityType.sleep:
        return _buildSleepStats();
      case ActivityType.breastfeeding:
      case ActivityType.bottleFeeding:
        // Combined Feeding view or separate? Request said select specific activity.
        // Let's build specific for selected.
        return _buildFeedingStats(type);
      case ActivityType.diaper:
        return _buildDiaperStats();
      case ActivityType.pumping:
        return _buildPumpingStats();
      case ActivityType.health:
        return _buildHealthStats();
      case ActivityType.measurement:
        return _buildGrowthStats();
      default:
        // Generic charts for everything else (Duration or Count)
        return _buildGenericStats(type);
    }
  }

  // --- Sleep Stats ---

  // --- Growth Stats ---
  Widget _buildGrowthStats() {
    return FutureBuilder<List<Measurement>>(
      future: service.getGrowthStats(startDate, endDate),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());
        final data = snapshot.data!;

        if (data.isEmpty) {
          return Container(
            height: 200,
            alignment: Alignment.center,
            child: Text(
              "No measurements for this period",
              style: AppTypography.body.copyWith(color: AppColors.textLight),
            ),
          );
        }

        // Prepare Spots
        List<FlSpot> weightSpots = [];
        List<FlSpot> heightSpots = [];
        List<FlSpot> headSpots = [];

        for (int i = 0; i < data.length; i++) {
          final m = data[i];
          final x = i.toDouble();
          if (m.weight != null) weightSpots.add(FlSpot(x, m.weight!));
          if (m.height != null) heightSpots.add(FlSpot(x, m.height!));
          if (m.headCircumference != null)
            headSpots.add(FlSpot(x, m.headCircumference!));
        }

        final last = data.last;

        return Column(
          children: [
            // Weight
            if (weightSpots.isNotEmpty) ...[
              StatsSummaryCard(
                title: 'Latest Weight',
                value: '${last.weight} ${last.weightUnit ?? 'kg'}',
                icon: Icons.monitor_weight,
              ),
              const SizedBox(height: 16),
              _buildSimpleLineChart(
                weightSpots,
                title: "Weight",
                color: AppColors.primary,
              ),
              const SizedBox(height: 32),
            ],

            // Height
            if (heightSpots.isNotEmpty) ...[
              StatsSummaryCard(
                title: 'Latest Height',
                value: '${last.height} ${last.heightUnit ?? 'cm'}',
                icon: Icons.height,
              ),
              const SizedBox(height: 16),
              _buildSimpleLineChart(
                heightSpots,
                title: "Height",
                color: Colors.teal,
              ),
              const SizedBox(height: 32),
            ],

            // Head
            if (headSpots.isNotEmpty) ...[
              StatsSummaryCard(
                title: 'Head Circumference',
                value:
                    '${last.headCircumference} ${last.headCircumferenceUnit ?? 'cm'}',
                icon: Icons.face,
              ),
              const SizedBox(height: 16),
              _buildSimpleLineChart(
                headSpots,
                title: "Head Circ.",
                color: Colors.purple,
              ),
              const SizedBox(height: 32),
            ],

            if (weightSpots.isEmpty && heightSpots.isEmpty && headSpots.isEmpty)
              const Text("No numeric data found"),
          ],
        );
      },
    );
  }

  // --- Health Stats ---
  Widget _buildHealthStats() {
    return FutureBuilder<List<Activity>>(
      future: service.getHealthEvents(startDate, endDate),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());

        final events = snapshot.data!;
        // Filter for temperature
        final tempEvents = events.where((e) => e.temperature != null).toList();

        // Count medications
        int medCount = events
            .where((e) => e.medication != null && e.medication!.isNotEmpty)
            .length;

        // Prepare Temp Spots
        List<FlSpot> tempSpots = [];
        for (int i = 0; i < tempEvents.length; i++) {
          // Use index or time? Let's use simple index sequence for trend
          tempSpots.add(FlSpot(i.toDouble(), tempEvents[i].temperature!));
        }

        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: StatsSummaryCard(
                    title: 'Health Logs',
                    value: '${events.length}',
                    icon: Icons.health_and_safety,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: StatsSummaryCard(
                    title: 'Meds Given',
                    value: '$medCount',
                    icon: Icons.medication,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            if (tempSpots.isNotEmpty) ...[
              Text(
                "Temperature Trend",
                style: AppTypography.h3.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 16),
              _buildSimpleLineChart(
                tempSpots,
                title: "Temp (°C)",
                color: Colors.redAccent,
              ),
            ] else
              const Padding(
                padding: EdgeInsets.all(32.0),
                child: Text("No temperature records found for this period."),
              ),
          ],
        );
      },
    );
  }

  Widget _buildSimpleLineChart(
    List<FlSpot> spots, {
    required String title,
    required Color color,
  }) {
    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: color,
              barWidth: 3,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: color.withOpacity(0.1),
              ),
            ),
          ],
          titlesData: FlTitlesData(
            bottomTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (v, m) =>
                    Text(v.toStringAsFixed(1), style: AppTypography.caption),
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: const FlGridData(show: true),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: AppColors.divider),
          ),
        ),
      ),
    );
  }

  Widget _buildSleepStats() {
    return FutureBuilder<Map<String, dynamic>>(
      future:
          Future.wait([
            service.getSleepStats(startDate, endDate),
            service.getSleepDisturbanceStats(startDate, endDate),
            service.getLastActivity(ActivityType.sleep),
          ]).then((results) {
            final basicStats =
                (results[0] as Map?)?.cast<DateTime, double>() ?? {};
            final advancedStats =
                (results[1] as Map?)?.cast<String, double>() ?? {};
            final lastActivity = results[2] as Activity?;
            return {
              'basic': basicStats,
              'advanced': advancedStats,
              'last': lastActivity,
            };
          }),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());

        final basicData =
            (snapshot.data!['basic'] as Map?)?.cast<DateTime, double>() ?? {};
        final advancedData =
            (snapshot.data!['advanced'] as Map?)?.cast<String, double>() ?? {};
        final lastActivity = snapshot.data!['last'] as Activity?;

        // Basic Totals
        double totalHours = basicData.values.fold(0, (sum, val) => sum + val);
        double avgHours = basicData.isNotEmpty
            ? totalHours / basicData.length
            : 0;

        // Advanced totals
        double longestStretch = advancedData['longestStretchHours'] ?? 0;
        double daySleep = advancedData['daySleepHours'] ?? 0;
        double nightSleep = advancedData['nightSleepHours'] ?? 0;

        return Column(
          children: [
            // Last Sleep Card
            LastActivityCard(
              title: 'Last Sleep',
              activity: lastActivity,
              icon: Icons.nightlight_round,
              color: Colors.indigo,
            ),

            // Row 1: Totals & Avg
            Row(
              children: [
                Expanded(
                  child: StatsSummaryCard(
                    title: 'Total Sleep',
                    value: '${totalHours.toStringAsFixed(1)}h',
                    icon: Icons.nightlight_round,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: StatsSummaryCard(
                    title: 'Daily Avg',
                    value: '${avgHours.toStringAsFixed(1)}h',
                    icon: Icons.show_chart,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: StatsSummaryCard(
                    title: 'Max Stretch',
                    value: '${longestStretch.toStringAsFixed(1)}h',
                    icon: Icons.bed,
                    color: Colors.indigo.shade50,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Main Bar Chart
            _buildBarChart(
              basicData,
              label: 'Hours',
              color: Colors.indigoAccent,
            ),

            const SizedBox(height: 32),

            // Day vs Night Pie Check
            if (daySleep > 0 || nightSleep > 0) ...[
              Text(
                "Day vs Night Sleep",
                style: AppTypography.h3.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 180,
                child: PieChart(
                  PieChartData(
                    sections: [
                      PieChartSectionData(
                        value: daySleep,
                        title: 'Day\n${daySleep.toStringAsFixed(1)}h',
                        color: Colors.orangeAccent,
                        radius: 50,
                        titleStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      PieChartSectionData(
                        value: nightSleep,
                        title: 'Night\n${nightSleep.toStringAsFixed(1)}h',
                        color: Colors.indigo,
                        radius: 50,
                        titleStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                    centerSpaceRadius: 30,
                    sectionsSpace: 2,
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],

            // Sleep Start Times Scatter
            FutureBuilder<List<Activity>>(
              future: service.getActivityEvents(
                ActivityType.sleep,
                startDate,
                endDate,
              ),
              builder: (ctx, snap) {
                if (!snap.hasData) return const SizedBox.shrink();
                return _buildTimeScatterChart(
                  snap.data!,
                  title: "Sleep Pattern (Starts)",
                  color: Colors.indigo,
                );
              },
            ),
          ],
        );
      },
    );
  }

  // --- Feeding Stats ---
  Widget _buildFeedingStats(ActivityType specificType) {
    final bool isNursing = specificType == ActivityType.breastfeeding;

    return FutureBuilder<Map<String, dynamic>>(
      future:
          Future.wait([
            // 0: Daily metric (Duration/Amount)
            service.getDailyActivityMetric(
              specificType,
              startDate,
              endDate,
              sumDuration: isNursing,
              sumAmount: !isNursing,
            ),
            // 1: Daily Count
            service.getDailyActivityMetric(
              specificType,
              startDate,
              endDate,
              countOnly: true,
            ),
            // 2: Average Interval
            service.getAverageFeedingInterval(startDate, endDate),
            // 3: Side Stats (Null if bottle)
            isNursing
                ? service.getNursingSideStats(startDate, endDate)
                : Future.value(<String, double>{}),
            // 4: Bottle Distribution (Null if nursing)
            !isNursing
                ? service.getBottleVolumeDistribution(startDate, endDate)
                : Future.value(<String, int>{}),
            // 5: Last Activity
            service.getLastActivity(specificType),
          ]).then(
            (results) => {
              'daily':
                  (results[0] as Map?)?.cast<DateTime, double>() ??
                  <DateTime, double>{},
              'count':
                  (results[1] as Map?)?.cast<DateTime, double>() ??
                  <DateTime, double>{},
              'interval': (results[2] as double?) ?? 0.0,
              'side':
                  (results[3] as Map?)?.cast<String, double>() ??
                  <String, double>{},
              'bottle_dist':
                  (results[4] as Map?)?.cast<String, int>() ?? <String, int>{},
              'last': results[5] as Activity?,
            },
          ),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());

        final data = snapshot.data!;
        final dailyData =
            (data['daily'] as Map?)?.cast<DateTime, double>() ?? {};
        final countData =
            (data['count'] as Map?)?.cast<DateTime, double>() ?? {};
        final avgIntervalForDisplay = (data['interval'] as double?) ?? 0.0;
        final sideData = (data['side'] as Map?)?.cast<String, double>() ?? {};
        final bottleDist =
            (data['bottle_dist'] as Map?)?.cast<String, int>() ?? {};
        final lastActivity = data['last'] as Activity?;

        double total = dailyData.values.fold(0, (sum, val) => sum + val);

        String unit = isNursing ? 'min' : 'ml';

        // Interval string
        int intervalH = avgIntervalForDisplay.floor();
        int intervalM = ((avgIntervalForDisplay - intervalH) * 60).round();
        String intervalStr = '${intervalH}h ${intervalM}m';

        return Column(
          children: [
            LastActivityCard(
              title: isNursing ? 'Last Nursing' : 'Last Bottle',
              activity: lastActivity,
              icon: isNursing ? Icons.spa : Icons.local_drink,
              color: isNursing ? Colors.pinkAccent : Colors.blueAccent,
            ),

            Row(
              children: [
                Expanded(
                  child: StatsSummaryCard(
                    title: isNursing ? 'Total Time' : 'Total Vol',
                    value: '${total.toStringAsFixed(0)} $unit',
                    icon: isNursing ? Icons.timer : Icons.local_drink,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: StatsSummaryCard(
                    title: 'Avg Interval',
                    value: intervalStr,
                    icon: Icons.timelapse,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildBarChart(
              dailyData,
              label: unit,
              color: isNursing ? Colors.pinkAccent : Colors.blueAccent,
            ),
            const SizedBox(height: 32),

            // Nursing Side Preference
            if (isNursing &&
                (sideData['leftMinutes']! > 0 ||
                    sideData['rightMinutes']! > 0)) ...[
              Text(
                "Side Preference",
                style: AppTypography.h3.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 180,
                child: PieChart(
                  PieChartData(
                    sections: [
                      PieChartSectionData(
                        value: sideData['leftMinutes']!,
                        title: 'L',
                        color: Colors.pink[200],
                        radius: 50,
                        titleStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        badgeWidget: _Badge(
                          '${sideData['leftMinutes']!.toInt()}m',
                          Colors.pink[200]!,
                        ),
                        badgePositionPercentageOffset: 1.3,
                      ),
                      PieChartSectionData(
                        value: sideData['rightMinutes']!,
                        title: 'R',
                        color: Colors.pink,
                        radius: 50,
                        titleStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        badgeWidget: _Badge(
                          '${sideData['rightMinutes']!.toInt()}m',
                          Colors.pink,
                        ),
                        badgePositionPercentageOffset: 1.3,
                      ),
                    ],
                    centerSpaceRadius: 30,
                    sectionsSpace: 4,
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],

            // Bottle Volume Distribution
            if (!isNursing && bottleDist.isNotEmpty) ...[
              Text(
                "Feed Volume Distribution",
                style: AppTypography.h3.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 16),
              _buildHistogram(bottleDist, color: Colors.blueAccent),
              const SizedBox(height: 32),
            ],

            // Count Chart
            Text(
              "Feeds per Day",
              style: AppTypography.h3.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 16),
            _buildBarChart(countData, label: 'feeds', color: AppColors.accent),
          ],
        );
      },
    );
  }

  // Helper for Histogram
  Widget _buildHistogram(Map<String, int> data, {required Color color}) {
    // Convert to spots 0,1,2,3
    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: (data.values.fold(0, (p, e) => p > e ? p : e) * 1.2).toDouble(),
          barGroups: data.entries.toList().asMap().entries.map((entry) {
            final index = entry.key; // 0, 1, 2...
            final val = entry.value.value.toDouble();
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: val,
                  color: color,
                  width: 22,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ],
            );
          }).toList(),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx >= 0 && idx < data.keys.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        data.keys.elementAt(idx),
                        style: AppTypography.caption.copyWith(fontSize: 10),
                      ),
                    );
                  }
                  return const Text('');
                },
                reservedSize: 30,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ), // Hide counts Y axis for clean look
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }

  Widget _Badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)],
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // --- Diaper Stats ---
  Widget _buildDiaperStats() {
    return Column(
      children: [
        // 1. Breakdown Pie & Summary (Existing)
        FutureBuilder<Map<String, dynamic>>(
          future:
              Future.wait([
                service.getDiaperStats(startDate, endDate),
                // Calculate interval on the fly from raw events for now or add service method.
                // Let's use generic metric count and calc interval simply
                service.getDailyActivityMetric(
                  ActivityType.diaper,
                  startDate,
                  endDate,
                  countOnly: true,
                ),
                service.getLastActivity(ActivityType.diaper),
              ]).then(
                (results) => {
                  'breakdown': (results[0] as Map?)?.cast<String, int>() ?? {},
                  'daily_counts':
                      (results[1] as Map?)?.cast<DateTime, double>() ?? {},
                  'last': results[2] as Activity?,
                },
              ),
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return const SizedBox(
                height: 100,
                child: Center(child: CircularProgressIndicator()),
              );
            final data = snapshot.data!;
            final breakdown =
                (data['breakdown'] as Map?)?.cast<String, int>() ?? {};
            final dailyCounts =
                (data['daily_counts'] as Map?)?.cast<DateTime, double>() ?? {};
            final lastActivity = data['last'] as Activity?;

            // Calc total & interval
            int total = breakdown.values.fold(0, (sum, val) => sum + val);
            double days = endDate.difference(startDate).inDays.toDouble();
            if (days < 1) days = 1;
            // Approx interval
            double intervalHours = total > 0 ? (days * 24) / total : 0;

            return Column(
              children: [
                LastActivityCard(
                  title: 'Last Change',
                  activity: lastActivity,
                  icon: Icons.baby_changing_station,
                  color: Colors.teal,
                ),

                Row(
                  children: [
                    Expanded(
                      child: StatsSummaryCard(
                        title: 'Total Changes',
                        value: '$total',
                        icon: Icons.baby_changing_station,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: StatsSummaryCard(
                        title: 'Avg Interval',
                        value: intervalHours > 0
                            ? '${intervalHours.toStringAsFixed(1)}h'
                            : '--',
                        icon: Icons.timer,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                SizedBox(
                  height: 180,
                  child: PieChart(
                    PieChartData(
                      sections: [
                        if (breakdown['wet']! > 0)
                          PieChartSectionData(
                            value: breakdown['wet']!.toDouble(),
                            title: '${breakdown['wet']}',
                            color: Colors.blueAccent,
                            radius: 40,
                            titleStyle: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        if (breakdown['dirty']! > 0)
                          PieChartSectionData(
                            value: breakdown['dirty']!.toDouble(),
                            title: '${breakdown['dirty']}',
                            color: Colors.brown,
                            radius: 40,
                            titleStyle: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        if (breakdown['mixed']! > 0)
                          PieChartSectionData(
                            value: breakdown['mixed']!.toDouble(),
                            title: '${breakdown['mixed']}',
                            color: Colors.orange,
                            radius: 40,
                            titleStyle: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                      centerSpaceRadius: 30,
                      sectionsSpace: 4,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text("Diaper Breakdown", style: AppTypography.caption),
                const SizedBox(height: 32),

                // Daily Frequency
                const Text("Changes per Day", style: AppTypography.h3),
                const SizedBox(height: 16),
                _buildBarChart(
                  dailyCounts,
                  label: 'changes',
                  color: AppColors.primary,
                ),
              ],
            );
          },
        ),

        const SizedBox(height: 32),

        // 2. Poop Time Distribution (Scatter)
        FutureBuilder<List<Activity>>(
          future: service.getActivityEvents(
            ActivityType.diaper,
            startDate,
            endDate,
          ),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.isEmpty)
              return const SizedBox.shrink();

            // Filter only dirty/mixed for scatter
            final dirtyEvents = snapshot.data!.where((e) {
              final notes = e.notes ?? '';
              return notes.contains('[Poop]') ||
                  (e.isDry == false && e.isWet == false); // Fallback?
            }).toList();

            // If no Poop notes, maybe just show all? No, scatter is useful for patterns.
            if (dirtyEvents.isEmpty) return const SizedBox.shrink();

            return _buildTimeScatterChart(
              dirtyEvents,
              title: "Poop Patterns (Time of Day)",
              color: Colors.brown,
            );
          },
        ),
      ],
    );
  }

  // --- Pumping Stats ---
  Widget _buildPumpingStats() {
    return FutureBuilder<Map<String, dynamic>>(
      future:
          Future.wait([
            service.getPumpingStats(startDate, endDate),
            service.getPumpingOutputByHour(startDate, endDate),
            service.getLastActivity(ActivityType.pumping),
          ]).then(
            (results) => {
              'total': (results[0] as Map<DateTime, double>?) ?? {},
              'time_dist': (results[1] as Map<int, double>?) ?? {},
              'last': results[2] as Activity?,
            },
          ),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());

        final data = snapshot.data!;
        final totalData = data['total'] as Map<DateTime, double>;
        final timeDist = data['time_dist'] as Map<int, double>;
        final lastActivity = data['last'] as Activity?;

        double total = totalData.values.fold(0, (sum, val) => sum + val);

        return Column(
          children: [
            LastActivityCard(
              title: 'Last Pump',
              activity: lastActivity,
              icon: Icons.water_drop,
              color: Colors.purple,
            ),
            StatsSummaryCard(
              title: 'Total Pumping Vol',
              value: '${total.toStringAsFixed(0)} ml',
              icon: Icons.water_drop_outlined,
            ),
            const SizedBox(height: 24),
            _buildBarChart(totalData, label: 'ml', color: Colors.purpleAccent),

            const SizedBox(height: 32),
            Text(
              "Output by Time of Day",
              style: AppTypography.h3.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 16),
            // Custom Bar Chart for 4 buckets
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          switch (value.toInt()) {
                            case 0:
                              return const Text(
                                'Night',
                                style: TextStyle(fontSize: 10),
                              );
                            case 1:
                              return const Text(
                                'Morn',
                                style: TextStyle(fontSize: 10),
                              );
                            case 2:
                              return const Text(
                                'Aft',
                                style: TextStyle(fontSize: 10),
                              );
                            case 3:
                              return const Text(
                                'Eve',
                                style: TextStyle(fontSize: 10),
                              );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    _buildtimeDistGroup(0, timeDist[0] ?? 0, Colors.indigo),
                    _buildtimeDistGroup(1, timeDist[1] ?? 0, Colors.orange),
                    _buildtimeDistGroup(
                      2,
                      timeDist[2] ?? 0,
                      Colors.yellow[700]!,
                    ),
                    _buildtimeDistGroup(3, timeDist[3] ?? 0, Colors.purple),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  BarChartGroupData _buildtimeDistGroup(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 22,
          borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
        ),
      ],
    );
  }

  // --- Generic Generic ---
  Widget _buildGenericStats(ActivityType type) {
    // Determine if we should count or sum duration.
    // List of duration-based activities:
    // We treat Nap, Bath, Crying, Walking as Duration based.

    // Check if Type is one of the known duration ones
    bool isDuration = [
      ActivityType.nap,
      ActivityType.walkingOutside,
      ActivityType.crying,
      ActivityType.bath,
    ].contains(type);

    return FutureBuilder<Map<DateTime, double>>(
      future: service.getDailyActivityMetric(
        type,
        startDate,
        endDate,
        sumDuration: isDuration,
        countOnly: !isDuration,
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());
        final data = snapshot.data!;

        double total = data.values.fold(0, (sum, val) => sum + val);
        String unit = isDuration ? 'min' : 'times';

        return Column(
          children: [
            StatsSummaryCard(
              title: isDuration ? 'Total Duration' : 'Frequency',
              value: '${total.toStringAsFixed(0)} $unit',
              icon: Icons.timeline,
            ),
            const SizedBox(height: 24),
            _buildBarChart(data, label: unit, color: AppColors.primary),
          ],
        );
      },
    );
  }

  // --- Time Scatter Chart (Time of Day Distribution) ---
  Widget _buildTimeScatterChart(
    List<Activity> events, {
    required String title,
    required Color color,
  }) {
    if (events.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        const SizedBox(height: 16),
        Text(title, style: AppTypography.h3.copyWith(fontSize: 16)),
        const SizedBox(height: 8),
        SizedBox(
          height: 200,
          child: ScatterChart(
            ScatterChartData(
              scatterSpots: events.map((e) {
                // X: Day Index relative to StartDate
                // Y: Hour of day + Minute/60
                final dayIndex = e.startTime
                    .difference(startDate)
                    .inDays
                    .toDouble();
                final timeY = e.startTime.hour + (e.startTime.minute / 60.0);
                return ScatterSpot(
                  dayIndex,
                  timeY,
                  dotPainter: FlDotCirclePainter(
                    radius: 6,
                    color: color.withOpacity(0.6),
                    strokeWidth: 0,
                  ),
                );
              }).toList(),
              minY: 0,
              maxY: 24,
              gridData: FlGridData(
                show: true,
                drawHorizontalLine: true,
                horizontalInterval: 6, // 6am, 12pm, 6pm...
                getDrawingHorizontalLine: (value) => FlLine(
                  color: AppColors.divider,
                  strokeWidth: 1,
                  dashArray: [5, 5],
                ),
                drawVerticalLine: true,
                getDrawingVerticalLine: (value) =>
                    FlLine(color: AppColors.divider, strokeWidth: 1),
              ),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final date = startDate.add(Duration(days: value.toInt()));
                      if (value % 2 == 0)
                        return Text(
                          DateFormat('E').format(date),
                          style: AppTypography.caption,
                        );
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    interval: 6,
                    getTitlesWidget: (value, meta) {
                      if (value == 0 || value == 24)
                        return const SizedBox.shrink();
                      final hour = value.toInt();
                      final suffix = hour >= 12 ? 'pm' : 'am';
                      final displayHour = hour > 12 ? hour - 12 : hour;
                      return Text(
                        '$displayHour$suffix',
                        style: AppTypography.caption,
                      );
                    },
                  ),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: AppColors.divider),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- Chart Helper ---
  Widget _buildBarChart(
    Map<DateTime, double> data, {
    required String label,
    required Color color,
  }) {
    // Sort keys just in case
    final sortedKeys = data.keys.toList()..sort();

    if (data.isEmpty || data.values.every((v) => v == 0)) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        child: Text(
          "No Data for this period",
          style: AppTypography.body.copyWith(color: AppColors.textLight),
        ),
      );
    }

    return SizedBox(
      height: 250,
      width: double.infinity,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: (data.values.reduce((a, b) => a > b ? a : b) * 1.2)
              .ceilToDouble(),
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: AppColors.surface, // Background
              tooltipPadding: const EdgeInsets.all(8),
              tooltipMargin: 8,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final date = sortedKeys[group.x];
                return BarTooltipItem(
                  '${DateFormat('E').format(date)}\n',
                  AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold),
                  children: [
                    TextSpan(
                      text: '${rod.toY.toStringAsFixed(1)} $label',
                      style: TextStyle(color: color, fontSize: 14),
                    ),
                  ],
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 && value.toInt() < sortedKeys.length) {
                    final date = sortedKeys[value.toInt()];
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        DateFormat('E').format(date),
                        style: AppTypography.caption,
                      ),
                    );
                  }
                  return const Text('');
                },
                reservedSize: 30,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: AppTypography.caption,
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: const FlGridData(show: true, drawVerticalLine: false),
          borderData: FlBorderData(show: false),
          barGroups: sortedKeys.asMap().entries.map((entry) {
            final index = entry.key;
            final date = entry.value;
            final value = data[date] ?? 0.0;
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: value,
                  color: color,
                  width: 16,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY:
                        (data.values.reduce((a, b) => a > b ? a : b) *
                        1.1), // Max background
                    color: AppColors.background,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
