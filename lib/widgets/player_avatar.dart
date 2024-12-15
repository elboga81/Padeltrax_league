import 'package:flutter/material.dart';
import '../models/player.dart';
import '../utils/url_converter.dart';

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
    final imageUrl = UrlConverter.getDirectGoogleDriveUrl(player.profileImage);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: borderColor != null
            ? Border.all(color: borderColor!, width: 2)
            : null,
      ),
      child: ClipOval(
        child: imageUrl.startsWith('assets/')
            ? Image.asset(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildFallbackAvatar(),
              )
            : Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildFallbackAvatar(),
                loadingBuilder: (_, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return _buildLoadingIndicator();
                },
              ),
      ),
    );
  }

  Widget _buildFallbackAvatar() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: player.name.isNotEmpty
            ? Text(
                player.name[0].toUpperCase(),
                style: TextStyle(
                  fontSize: size * 0.4,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              )
            : Image.asset('assets/images/profile.png', fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: SizedBox(
          width: size * 0.4,
          height: size * 0.4,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[400]!),
          ),
        ),
      ),
    );
  }
}
