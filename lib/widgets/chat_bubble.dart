import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rumour/theme/app_colors.dart';
import '../models/message.dart';

class ChatBubble extends StatelessWidget {
  final Message message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = message.isMe
        ? AppColors.limeAccent
        : isDark
        ? AppColors.cardDark.withAlpha((255 * .8).round())
        : AppColors.cardLight;

    final textColor = message.isMe
        ? AppColors.backButtonBg
        : isDark
        ? Colors.white
        : Colors.black;

    final metaColor = message.isMe
        ? AppColors.backButtonBg.withAlpha((255 * .8).round())
        : isDark
        ? AppColors.textMuted
        : AppColors.textSecondaryLight;

    final align = message.isMe
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: align,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 4, left: 4, right: 4),
              child: Text(
                message.isMe ? "You" : message.displayName,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 13.23,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width,
              ),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: const Radius.circular(11.34),
                  bottomRight: const Radius.circular(11.34),
                  topLeft: message.isMe
                      ? const Radius.circular(11.34)
                      : Radius.zero,
                  topRight: message.isMe
                      ? Radius.zero
                      : const Radius.circular(11.34),
                ),
                border: (!message.isMe && !isDark)
                    ? Border.all(color: AppColors.cardBorderLight, width: 1)
                    : null,
              ),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 13.23,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('hh:mm a').format(message.timestamp),
                    style: TextStyle(
                      color: metaColor,
                      fontSize: 11.34,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
