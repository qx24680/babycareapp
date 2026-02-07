import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/chat_message.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 36,
              height: 36,
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
                    blurRadius: 8,
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  CupertinoIcons.sparkles,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isUser ? 20 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: isUser
                  ? Text(
                      message.message ?? '',
                      style: AppTypography.body.copyWith(
                        color: AppColors.textOnPrimary,
                        height: 1.4,
                      ),
                    )
                  : MarkdownBody(
                      data: message.message ?? '',
                      selectable: true,
                      styleSheet: MarkdownStyleSheet(
                        p: AppTypography.body.copyWith(
                          color: AppColors.text,
                          height: 1.5,
                        ),
                        strong: AppTypography.body.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                        ),
                        listBullet: AppTypography.body.copyWith(
                          color: AppColors.primary,
                        ),
                        blockSpacing: 12,
                      ),
                    ),
            ),
          ),
          if (isUser)
            const SizedBox(width: 48), // Padding on left for user messages
          if (!isUser)
            const SizedBox(width: 32), // Padding on right for AI messages
        ],
      ),
    );
  }
}
