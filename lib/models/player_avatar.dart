import 'package:flutter/material.dart';
import '../models/player.dart';

class PlayerAvatar extends StatelessWidget {
  final Player player;
  final double size;
  final Color? borderColor;

  const PlayerAvatar({
    super.key,
    required this.player,
    this.size = 60,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: borderColor != null
            ? Border.all(color: borderColor!, width: 2)
            : null,
        color: Colors.grey[200],
      ),
      child: ClipOval(
        child: _buildProfileImage(),
      ),
    );
  }

  Widget _buildProfileImage() {
    // Always use initials as fallback
    final fallback = _buildInitialsAvatar();

    // If no profile image, return initials
    if (player.profileImage.isEmpty) {
      return fallback;
    }

    // Handle asset images
    if (player.profileImage.startsWith('assets/')) {
      return Image.asset(
        player.profileImage,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallback,
      );
    }

    // Handle network images
    return Image.network(
      player.profileImage,
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => fallback,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return _buildLoadingIndicator();
      },
    );
  }

  Widget _buildInitialsAvatar() {
    final initials = player.name.isNotEmpty
        ? player.name.split(' ').take(2).map((e) => e[0]).join().toUpperCase()
        : '?';

    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: Colors.grey[800],
            fontWeight: FontWeight.bold,
            fontSize: size * 0.4,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: SizedBox(
        width: size * 0.5,
        height: size * 0.5,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[400]!),
        ),
      ),
    );
  }
}
