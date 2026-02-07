import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors;
import '../../core/theme/app_theme.dart';
import '../../models/chat_message.dart';
import '../../models/chat_session.dart';
import '../../repositories/chat_repository.dart';
import '../../services/gemini_service.dart';
import 'widgets/chat_bubble.dart';
import 'widgets/chat_history_list.dart';
import 'widgets/typing_indicator.dart';
import 'widgets/suggested_prompts.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatRepository _repository = ChatRepository();
  final GeminiService _geminiService = GeminiService();

  List<ChatMessage> _messages = [];
  List<ChatSession> _sessions = [];
  bool _isLoading = false;
  int? _currentSessionId;

  @override
  void initState() {
    super.initState();
    _loadLatestSession();
  }

  Future<void> _loadLatestSession() async {
    setState(() => _isLoading = true);
    try {
      final sessions = await _repository.getSessions();
      setState(() {
        _sessions = sessions;
      });

      if (sessions.isNotEmpty) {
        // Load the most recent session
        final session = sessions.first;
        await _selectSession(session.id!);
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Error loading session: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectSession(int? sessionId) async {
    if (sessionId == _currentSessionId && sessionId != null) return;

    if (sessionId == null) {
      setState(() {
        _currentSessionId = null;
        _messages = [];
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _currentSessionId = sessionId;
      _isLoading = true;
    });

    try {
      final messages = await _repository.getMessages(sessionId);
      if (mounted) {
        setState(() {
          _messages = messages;
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      debugPrint('Error loading messages: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshSessions() async {
    final sessions = await _repository.getSessions();
    if (mounted) {
      setState(() {
        _sessions = sessions;
      });
    }
  }

  Future<void> _handleSubmitted(String text) async {
    if (text.trim().isEmpty) return;

    final messageText = text.trim();
    _textController.clear();

    // Optimistic UI update
    final userMsg = ChatMessage(
      sessionId: _currentSessionId ?? 0, // Placeholder if new
      isUser: true,
      message: messageText,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMsg);
      _isLoading = true; // Show typing indicator
    });
    _scrollToBottom();

    try {
      // Create session if needed
      bool isNewSession = false;
      if (_currentSessionId == null) {
        // New Session Title Logic
        // Truncate message for title if it's long, or use a default
        String title = messageText;
        if (title.length > 30) {
          title = '${title.substring(0, 30)}...';
        }

        _currentSessionId = await _repository.createSession(title);
        isNewSession = true;
      }

      // Save User Message
      await _repository.saveMessage(_currentSessionId!, messageText, true);

      if (isNewSession) {
        await _refreshSessions();
      }

      // Get AI Response
      // We pass the *previous* messages as history, excluding the one just added
      final responseText = await _geminiService.sendMessage(
        messageText,
        history: _messages.where((m) => m != userMsg).toList(),
      );

      // Save AI Message
      await _repository.saveMessage(_currentSessionId!, responseText, false);

      // Update UI with real AI message
      if (mounted) {
        final aiMsg = ChatMessage(
          sessionId: _currentSessionId!,
          isUser: false,
          message: responseText,
          timestamp: DateTime.now(),
        );
        setState(() {
          _messages.add(aiMsg);
        });

        // Refresh session list to update timestamp order if needed
        await _refreshSessions();

        _scrollToBottom();
      }
    } catch (e) {
      debugPrint('Error in chat loop: $e');
      if (mounted) {
        // Show error message
        setState(() {
          _messages.add(
            ChatMessage(
              sessionId: _currentSessionId ?? 0,
              isUser: false,
              message: "Sorry, something went wrong. Please try again.",
              timestamp: DateTime.now(),
            ),
          );
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('AI Assistant', style: AppTypography.h3),
        backgroundColor: AppTheme.theme.barBackgroundColor,
        border: null,
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Chat History List
            ChatHistoryList(
              sessions: _sessions,
              currentSessionId: _currentSessionId,
              onSessionSelected: _selectSession,
            ),

            Expanded(
              child: _messages.isEmpty && !_isLoading
                  ? Center(
                      child: SuggestedPrompts(
                        onPromptSelected: (text) => _handleSubmitted(text),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      itemCount: _messages.length + (_isLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _messages.length) {
                          return const TypingIndicator();
                        }
                        return ChatBubble(message: _messages[index]);
                      },
                    ),
            ),
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.text.withOpacity(0.05),
            offset: const Offset(0, -4),
            blurRadius: 16,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: CupertinoTextField(
                    controller: _textController,
                    placeholder: 'Ask anything about your baby...',
                    placeholderStyle: AppTypography.body.copyWith(
                      color: AppColors.textLight,
                    ),
                    style: AppTypography.body,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: null,
                    minLines: 1,
                    maxLines: 5,
                    textInputAction: TextInputAction.send,
                    onSubmitted: _handleSubmitted,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              CupertinoButton(
                padding: EdgeInsets.zero,
                minSize: 48,
                onPressed: () => _handleSubmitted(_textController.text),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6B4EE6), Color(0xFF9747FF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6B4EE6).withOpacity(0.3),
                        offset: const Offset(0, 4),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: const Icon(
                    CupertinoIcons.arrow_up,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
