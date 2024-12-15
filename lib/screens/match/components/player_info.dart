import 'package:flutter/material.dart';
import '../../../models/player.dart';

class PlayerInfo extends StatelessWidget {
  final Player player;
  final bool showRating; // Optional: Display player rating if needed
  final Alignment alignment; // Controls alignment of the display
  final double avatarSize; // Size of the avatar
  final TextStyle? nameStyle; // Customizable name text style

  const PlayerInfo({
    super.key,
    required this.player,
    this.showRating = false,
    this.alignment = Alignment.centerLeft,
    this.avatarSize = 24, // Reduced avatar size
    this.nameStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      textDirection: alignment == Alignment.centerRight
          ? TextDirection.rtl
          : TextDirection.ltr,
      children: [
        // Player Avatar
        CircleAvatar(
          radius: avatarSize / 2, // Smaller avatar
          backgroundImage: player.profileImage.isNotEmpty
              ? NetworkImage(player.profileImage) // Display player image
              : const AssetImage('assets/images/default_avatar.png')
                  as ImageProvider, // Fallback image
          backgroundColor: Colors.grey[200],
          child: player.profileImage.isEmpty
              ? Text(
                  player.name.isNotEmpty
                      ? player.name[0].toUpperCase() // Show initials
                      : '',
                  style: TextStyle(
                    fontSize: avatarSize * 0.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                )
              : null,
        ),

        const SizedBox(width: 6), // Reduced spacing

        // Player Name
        Flexible(
          child: Text(
            player.name,
            style: nameStyle ??
                const TextStyle(
                  fontSize: 12, // Reduced font size for compactness
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
