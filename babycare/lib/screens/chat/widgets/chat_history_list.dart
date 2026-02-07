import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/chat_session.dart';

class ChatHistoryList extends StatelessWidget {
  final List<ChatSession> sessions;
  final int? currentSessionId;
  final Function(int?) onSessionSelected; // null means new chat

  const ChatHistoryList({
    super.key,
    required this.sessions,
    required this.currentSessionId,
    required this.onSessionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: sessions.length + 1, // +1 for New Chat
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildNewChatButton();
          }

          final session = sessions[index - 1];
          final isSelected = session.id == currentSessionId;

          return _buildSessionItem(session, isSelected);
        },
      ),
    );
  }

  Widget _buildNewChatButton() {
    final isSelected = currentSessionId == null;
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: () => onSessionSelected(null),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.divider,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.text.withOpacity(0.05),
                offset: const Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                CupertinoIcons.add,
                size: 16,
                color: isSelected ? Colors.white : AppColors.primary,
              ),
              const SizedBox(width: 6),
              Text(
                'New Chat',
                style: AppTypography.bodySmall.copyWith(
                  color: isSelected ? Colors.white : AppColors.text,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSessionItem(ChatSession session, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: () => onSessionSelected(session.id),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.divider,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.text.withOpacity(0.05),
                offset: const Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isSelected) ...[
                const Icon(
                  CupertinoIcons.chat_bubble_text,
                  size: 14,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                _formatTitle(session.title),
                style: AppTypography.bodySmall.copyWith(
                  color: isSelected ? Colors.white : AppColors.text,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTitle(String? title) {
    if (title == null || title.isEmpty) return 'Untitled';
    if (title.length > 20) {
      return '${title.substring(0, 20)}...';
    }
    return title;
  }
}
