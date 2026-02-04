import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';
import 'package:babycare/services/chat_repository.dart';
import 'package:babycare/models/chat_message.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('ChatRepository Workflow', () async {
    final repo = ChatRepository();
    const babyId =
        1; // Assuming baby exists or ID doesn't strict check FK in simple mocking unless we enable FKs

    // 1. Create/Fetch Conversation
    print('1. Creating Conversation...');
    final conversation = await repo.createOrFetchConversation(babyId);
    expect(conversation.id, isPositive);
    print('   Conversation ID: ${conversation.id}');

    // 2. Send Message (User)
    print('2. Sending User Message...');
    final msg1 = ChatMessage(
      conversationId: conversation.id!,
      senderRole: 'user',
      messageText: 'Is 3 hours sleep normal?',
      topic: 'sleep',
      babyAgeDays: 45,
      createdAt: DateTime.now(),
    );
    await repo.insertMessage(msg1);

    // 3. Send Message (Assistant)
    print('3. Sending Assistant Message...');
    final msg2 = ChatMessage(
      conversationId: conversation.id!,
      senderRole: 'assistant',
      messageText: 'Yes, for a 45-day old baby...',
      topic: 'sleep',
      babyAgeDays: 45,
      createdAt: DateTime.now().add(const Duration(seconds: 5)),
    );
    await repo.insertMessage(msg2);

    // 4. Fetch History
    print('4. Fetching History...');
    final messages = await repo.getMessages(conversation.id!);
    expect(messages.length, 2);
    expect(messages.first.messageText, 'Is 3 hours sleep normal?');
    expect(messages.last.senderRole, 'assistant');
    print('   Fetched ${messages.length} messages.');

    // 5. Archive
    print('5. Archiving...');
    await repo.archiveConversation(conversation.id!);

    // 6. Verify New Conversation Created (since old is archived)
    print('6. Verifying New Conversation Creation...');
    final newConv = await repo.createOrFetchConversation(babyId);
    expect(newConv.id, isNot(conversation.id));
    print('   Old ID: ${conversation.id}, New ID: ${newConv.id}');
  });
}
