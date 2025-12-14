import 'package:flutter/material.dart';
import 'package:rumour/theme/app_colors.dart';
import 'package:rumour/services/presence_service.dart';

class RoomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String roomCode;
  final String roomId;

  const RoomAppBar({
    super.key,
    required this.roomCode,
    required this.roomId,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final presenceService = PresenceService();

    return AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.backButtonBg : AppColors.cardLight,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.arrow_back_ios_new,
              size: 20,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
      centerTitle: true,
      title: Column(
        children: [
          Text(
            "Room #$roomCode",
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 19.53,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          StreamBuilder<int>(
            stream: presenceService.getActiveMemberCount(roomId),
            initialData: 1,
            builder: (context, snapshot) {
              final count = snapshot.data ?? 1;
              return Text(
                "$count member${count == 1 ? '' : 's'}",
                style: TextStyle(
                  color: isDark ? AppColors.textMuted : AppColors.textSecondaryLight,
                  fontSize: 13.67,
                  fontWeight: FontWeight.w400,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
