import '../models/activity.dart';
import '../models/measurement.dart';
import 'database_service.dart';

class StatisticsService {
  final DatabaseService _dbService = DatabaseService();

  // Generic: Get daily counts or sums for any activity type
  Future<Map<DateTime, double>> getDailyActivityMetric(
    ActivityType type,
    DateTime start,
    DateTime end, {
    bool sumDuration = false,
    bool sumAmount = false,
    bool countOnly = false,
  }) async {
    final db = await _dbService.database;
    final startMillis = start.millisecondsSinceEpoch;
    final endMillis = end.millisecondsSinceEpoch;

    final List<Map<String, dynamic>> maps = await db.query(
      'activity',
      where: 'type = ? AND start_time >= ? AND start_time <= ?',
      whereArgs: [type.dbValue, startMillis, endMillis],
    );

    final Map<DateTime, double> dailyStats = {};

    // Initialize all days with 0
    for (int i = 0; i <= end.difference(start).inDays; i++) {
      final date = DateTime(start.year, start.month, start.day + i);
      dailyStats[date] = 0.0;
    }

    for (var map in maps) {
      final activity = Activity.fromMap(map);
      final date = DateTime(
        activity.startTime.year,
        activity.startTime.month,
        activity.startTime.day,
      );

      if (dailyStats.containsKey(date)) {
        if (countOnly) {
          dailyStats[date] = (dailyStats[date] ?? 0) + 1;
        } else if (sumDuration) {
          // Duration in minutes
          double duration = activity.durationMinutes?.toDouble() ?? 0.0;
          if (duration == 0 && activity.endTime != null) {
            duration = activity.endTime!
                .difference(activity.startTime)
                .inMinutes
                .toDouble();
          }
          dailyStats[date] = (dailyStats[date] ?? 0) + duration;
        } else if (sumAmount) {
          dailyStats[date] = (dailyStats[date] ?? 0) + (activity.amount ?? 0.0);
        }
      }
    }

    return dailyStats;
  }

  // Sleep Stats: Returns map of Date -> Hours of sleep
  Future<Map<DateTime, double>> getSleepStats(
    DateTime start,
    DateTime end,
  ) async {
    final minutesMap = await getDailyActivityMetric(
      ActivityType.sleep,
      start,
      end,
      sumDuration: true,
    );
    // Convert minutes to hours
    return minutesMap.map((key, value) => MapEntry(key, value / 60.0));
  }

  // Feeding Stats
  Future<Map<String, dynamic>> getFeedingStats(
    DateTime start,
    DateTime end,
  ) async {
    final db = await _dbService.database;
    final startMillis = start.millisecondsSinceEpoch;
    final endMillis = end.millisecondsSinceEpoch;

    // Fetch all feeding related activities
    final List<Map<String, dynamic>> bottleMaps = await db.query(
      'activity',
      where: 'type = ? AND start_time >= ? AND start_time <= ?',
      whereArgs: [ActivityType.bottleFeeding.dbValue, startMillis, endMillis],
    );

    final List<Map<String, dynamic>> nursingMaps = await db.query(
      'activity',
      where: 'type = ? AND start_time >= ? AND start_time <= ?',
      whereArgs: [ActivityType.breastfeeding.dbValue, startMillis, endMillis],
    );

    // Aggregate Bottle (Volume)
    Map<DateTime, double> bottleVolume = {};
    for (var map in bottleMaps) {
      final activity = Activity.fromMap(map);
      final date = DateTime(
        activity.startTime.year,
        activity.startTime.month,
        activity.startTime.day,
      );
      bottleVolume[date] = (bottleVolume[date] ?? 0) + (activity.amount ?? 0);
    }

    // Aggregate Nursing (Duration)
    Map<DateTime, double> nursingDuration = {};
    for (var map in nursingMaps) {
      final activity = Activity.fromMap(map);
      final date = DateTime(
        activity.startTime.year,
        activity.startTime.month,
        activity.startTime.day,
      );
      double duration = activity.durationMinutes?.toDouble() ?? 0;
      if (duration == 0 && activity.endTime != null) {
        duration = activity.endTime!
            .difference(activity.startTime)
            .inMinutes
            .toDouble();
      }
      nursingDuration[date] = (nursingDuration[date] ?? 0) + duration;
    }

    return {'bottleVolume': bottleVolume, 'nursingDuration': nursingDuration};
  }

  // Pumping Stats: Volume per day
  Future<Map<DateTime, double>> getPumpingStats(
    DateTime start,
    DateTime end,
  ) async {
    return await getDailyActivityMetric(
      ActivityType.pumping,
      start,
      end,
      sumAmount: true,
    );
  }

  // Diaper Stats: Breakdown by Wet, Dirty (Poop), Mixed
  Future<Map<String, int>> getDiaperStats(DateTime start, DateTime end) async {
    final db = await _dbService.database;
    final startMillis = start.millisecondsSinceEpoch;
    final endMillis = end.millisecondsSinceEpoch;

    final List<Map<String, dynamic>> maps = await db.query(
      'activity',
      where: 'type = ? AND start_time >= ? AND start_time <= ?',
      whereArgs: [ActivityType.diaper.dbValue, startMillis, endMillis],
    );

    int wet = 0;
    int dirty = 0;
    int mixed =
        0; // if we want to track both separately or just count occurrences

    for (var map in maps) {
      final isWet = map['is_wet'] == 1;
      final notes = map['notes'] as String? ?? '';
      final isPoop = notes.contains('[Poop]');

      if (isWet && isPoop) {
        mixed++;
      } else if (isWet) {
        wet++;
      } else if (isPoop) {
        dirty++;
      }
    }

    return {'wet': wet, 'dirty': dirty, 'mixed': mixed};
  }

  // Growth Stats
  Future<List<Measurement>> getGrowthStats(DateTime start, DateTime end) async {
    final db = await _dbService.database;
    final startMillis = start.millisecondsSinceEpoch;
    final endMillis = end.millisecondsSinceEpoch;

    final List<Map<String, dynamic>> maps = await db.query(
      'measurement',
      where: 'time >= ? AND time <= ?',
      whereArgs: [startMillis, endMillis],
      orderBy: 'time ASC',
    );

    return List.generate(maps.length, (i) {
      return Measurement.fromMap(maps[i]);
    });
  }

  // Generic: Get raw events for "Time of Day" analysis (Scatter Plots)
  Future<List<Activity>> getActivityEvents(
    ActivityType type,
    DateTime start,
    DateTime end,
  ) async {
    final db = await _dbService.database;
    final startMillis = start.millisecondsSinceEpoch;
    final endMillis = end.millisecondsSinceEpoch;

    final List<Map<String, dynamic>> maps = await db.query(
      'activity',
      where: 'type = ? AND start_time >= ? AND start_time <= ?',
      whereArgs: [type.dbValue, startMillis, endMillis],
      orderBy: 'start_time ASC',
    );

    return maps.map((m) => Activity.fromMap(m)).toList();
  }

  // --- Advanced Sleep Stats ---
  // Returns { 'longestStretchHours': double, 'daySleepHours': double, 'nightSleepHours': double }
  Future<Map<String, double>> getSleepDisturbanceStats(
    DateTime start,
    DateTime end,
  ) async {
    final sleepEvents = await getActivityEvents(ActivityType.sleep, start, end);
    double longestStretch = 0;
    double daySleep = 0;
    double nightSleep = 0;

    for (var event in sleepEvents) {
      if (event.endTime == null) continue;

      // Calculate duration in hours
      final duration =
          event.endTime!.difference(event.startTime).inMinutes / 60.0;
      if (duration > longestStretch) longestStretch = duration;

      // Classify as Day (6am-7pm) or Night (7pm-6am) based on Start Time
      // keeping simple logic for now: if start is day, count as day.
      // Ideally we split crossing boundary, but start time proxy is approx enough for trends.
      final hour = event.startTime.hour;
      final isDay = hour >= 6 && hour < 19;

      if (isDay) {
        daySleep += duration;
      } else {
        nightSleep += duration;
      }
    }

    return {
      'longestStretchHours': longestStretch,
      'daySleepHours': daySleep,
      'nightSleepHours': nightSleep,
    };
  }

  // --- Advanced Feeding Stats ---
  Future<Map<String, double>> getNursingSideStats(
    DateTime start,
    DateTime end,
  ) async {
    final nursingEvents = await getActivityEvents(
      ActivityType.breastfeeding,
      start,
      end,
    );
    double leftDuration = 0;
    double rightDuration = 0;

    for (var event in nursingEvents) {
      double duration = event.durationMinutes?.toDouble() ?? 0.0;
      if (duration == 0 && event.endTime != null) {
        duration = event.endTime!
            .difference(event.startTime)
            .inMinutes
            .toDouble();
      }

      // Check side from string value in DB or Activity Object
      // Activity object has `side` enum.
      if (event.side?.toString().contains('left') == true) {
        leftDuration += duration;
      } else if (event.side?.toString().contains('right') == true) {
        rightDuration += duration;
      }
    }
    return {'leftMinutes': leftDuration, 'rightMinutes': rightDuration};
  }

  // Calculate Average Interval between feeds (Start to Start)
  Future<double> getAverageFeedingInterval(DateTime start, DateTime end) async {
    // combine bottle and nursing
    final nursing = await getActivityEvents(
      ActivityType.breastfeeding,
      start,
      end,
    );
    final bottle = await getActivityEvents(
      ActivityType.bottleFeeding,
      start,
      end,
    );

    final allFeeds = [...nursing, ...bottle]
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    if (allFeeds.length < 2) return 0.0;

    double totalMinutesDiff = 0;
    int gaps = 0;

    for (int i = 0; i < allFeeds.length - 1; i++) {
      final diff = allFeeds[i + 1].startTime
          .difference(allFeeds[i].startTime)
          .inMinutes;
      // Filter out unrealistic gaps (e.g. > 10 hours might be night sleep, but let's count all for true avg)
      // Or maybe filter very short ones (cluster feeding)? Let's keep raw for now.
      totalMinutesDiff += diff;
      gaps++;
    }

    return gaps == 0
        ? 0.0
        : (totalMinutesDiff / gaps) / 60.0; // Return in Hours
  }

  // Bottle Volume Distribution (Histogram bins)
  Future<Map<String, int>> getBottleVolumeDistribution(
    DateTime start,
    DateTime end,
  ) async {
    final bottleEvents = await getActivityEvents(
      ActivityType.bottleFeeding,
      start,
      end,
    );
    final Map<String, int> distribution = {};

    for (var event in bottleEvents) {
      final vol = event.amount ?? 0;
      if (vol == 0) continue;

      String bin;
      if (vol < 60)
        bin = '< 60ml';
      else if (vol < 100)
        bin = '60-100ml';
      else if (vol < 150)
        bin = '100-150ml';
      else
        bin = '150ml+';

      distribution[bin] = (distribution[bin] ?? 0) + 1;
    }
    return distribution;
  }

  // --- Pumping Time Distribution ---
  Future<Map<int, double>> getPumpingOutputByHour(
    DateTime start,
    DateTime end,
  ) async {
    final pumpingEvents = await getActivityEvents(
      ActivityType.pumping,
      start,
      end,
    );
    // 0-3, 4-7, 8-11, 12-15, 16-19, 20-23 (6 buckets of 4 hours)
    // Or just simple 6-hour buckets: Morning (6-12), Afternoon (12-18), Evening (18-24), Night (0-6)

    final Map<int, double> buckets = {
      0: 0, // Night (00:00 - 05:59)
      1: 0, // Morning (06:00 - 11:59)
      2: 0, // Afternoon (12:00 - 17:59)
      3: 0, // Evening (18:00 - 23:59)
    };

    for (var event in pumpingEvents) {
      final hour = event.startTime.hour;
      int bucket;
      if (hour < 6)
        bucket = 0;
      else if (hour < 12)
        bucket = 1;
      else if (hour < 18)
        bucket = 2;
      else
        bucket = 3;

      buckets[bucket] = (buckets[bucket] ?? 0) + (event.amount ?? 0);
    }
    return buckets;
  }

  // --- Health Stats ---
  Future<List<Activity>> getHealthEvents(DateTime start, DateTime end) async {
    return getActivityEvents(ActivityType.health, start, end);
  }

  // --- Last Activity ---
  Future<Activity?> getLastActivity(ActivityType type) async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'activity',
      where: 'type = ?',
      whereArgs: [type.dbValue],
      orderBy: 'start_time DESC',
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return Activity.fromMap(maps.first);
    }
    return null;
  }
}
