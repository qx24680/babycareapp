import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:babycare/services/baby_repository.dart';
import 'package:babycare/models/baby_profile.dart';
import 'package:babycare/models/activity_log.dart';
import 'package:babycare/models/guardian.dart';
import 'dart:convert';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('BabyRepository MVP Workflow', () async {
    final repo = BabyRepository();

    // 1. Create Profile
    print('1. Creating Baby Profile...');
    final profile = BabyProfile(
      name: 'Baby Doe',
      dob: DateTime.now().subtract(const Duration(days: 30)),
      feedingType: 'breast',
      birthWeight: 3.5,
      height: 50.0,
      country: 'US',
      gender: 'male',
    );

    final babyId = await repo.saveBabyProfile(profile);
    print('   Baby Created with ID: $babyId');
    expect(babyId, isPositive);

    // Verify Profile
    final fetchedProfile = await repo.getBabyProfile(babyId);
    expect(fetchedProfile?.name, 'Baby Doe');
    print('   Fetched Profile: ${fetchedProfile?.name}');

    // 2. Create Guardian
    print('2. Creating Guardian...');
    final guardian = Guardian(name: 'Jane Doe', role: 'mother', babyId: babyId);
    await repo.saveGuardian(guardian);
    print('   Guardian Created.');

    // 3. Log Activity
    print('3. Logging Activity (Feeding)...');
    final activity = ActivityLog(
      babyId: babyId,
      activityType: 'feeding_breast',
      startTime: DateTime.now(),
      details: jsonEncode({'side': 'left', 'duration_min': 15}),
    );

    await repo.insertActivityLog(activity);
    print('   Activity Logged.');

    // 4. Fetch Logs
    print('4. Fetching Daily Logs...');
    final logs = await repo.getDailyLogs(babyId, DateTime.now());
    expect(logs.isNotEmpty, true);
    print('   Found ${logs.length} logs.');
    for (var log in logs) {
      print('   - ${log.activityType} at ${log.startTime}');
      print('     Details: ${log.detailsMap}');
    }

    // 5. Check Streak
    print('5. Checking Daily Streak...');
    final streak = await repo.getStreakForDate(babyId, DateTime.now());
    expect(streak?.logCount, greaterThanOrEqualTo(1));
    print('   Streak count for today: ${streak?.logCount}');
  });
}
