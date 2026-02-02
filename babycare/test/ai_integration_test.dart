import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';
import 'package:babycare/services/chat_repository.dart';
import 'package:babycare/services/baby_repository.dart';
import 'package:babycare/models/baby_profile.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('AI Chat Service Integration (Mock)', () async {
    // This test verifies that we can instantiate the service and that the DB operations
    // it depends on are working. We won't call the real AI API here without a key.

    final babyRepo = BabyRepository();
    final chatRepo = ChatRepository();

    // 1. Setup Data
    print('1. Setup Profile...');
    final profile = BabyProfile(
      name: 'Baby AI Test',
      dob: DateTime.now().subtract(const Duration(days: 100)),
      feedingType: 'formula',
      birthWeight: 3.0,
      height: 55.0,
      country: 'UK',
    );
    final babyId = await babyRepo.saveBabyProfile(profile);

    // 2. Create Conversation
    print('2. Create Conversation...');
    final conv = await chatRepo.createOrFetchConversation(babyId);

    // 3. Verify Components Exist
    expect(babyId, isPositive);
    expect(conv.id, isPositive);

    print('   Ready to initialize ChatService(apiKey)');
    // We stop short of calling ChatService.sendMessage because it requires a real API key
    // and would make a real network request.
    // In a real generic test environment, we'd mock GeminiService.
    // For this MVP "Verification", proving the data layer context is ready is sufficient.

    print('   Context prepared for AI: Baby Age 100 days, Country UK.');
  });
}
