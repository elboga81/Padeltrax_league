import 'package:flutter/material.dart';
import 'dart:math';

class ProfileImageWidget extends StatelessWidget {
  final String imageUrl;
  final String name;
  final double size;
  final Color? borderColor;
  final VoidCallback? onTap;
  final bool isEditable;

  const ProfileImageWidget({
    super.key,
    required this.imageUrl,
    required this.name,
    this.size = 60,
    this.borderColor,
    this.onTap,
    this.isEditable = false,
  });

  String _getInitials() {
    final nameParts = name.split(' ');
    if (nameParts.isEmpty) return '';
    if (nameParts.length == 1) {
      return nameParts[0]
          .substring(0, min(2, nameParts[0].length))
          .toUpperCase();
    }
    return (nameParts[0][0] + (nameParts.length > 1 ? nameParts[1][0] : ''))
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final bool isAssetImage = imageUrl.startsWith('assets/');

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: borderColor != null
            ? Border.all(color: borderColor!, width: size / 30)
            : null,
      ),
      child: Stack(
        children: [
          ClipOval(
            child: isAssetImage
                ? Image.asset(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildFallbackWidget(),
                  )
                : Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return _buildLoadingWidget();
                    },
                    errorBuilder: (context, error, stackTrace) =>
                        _buildFallbackWidget(),
                  ),
          ),
          if (isEditable)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(Icons.edit, color: Colors.white, size: 16),
              ),
            ),
          if (onTap != null)
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onTap,
                  customBorder: const CircleBorder(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: SizedBox(
          width: size * 0.4,
          height: size * 0.4,
          child: const CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  Widget _buildFallbackWidget() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Text(
          _getInitials(),
          style: TextStyle(
            color: Colors.grey[800],
            fontWeight: FontWeight.bold,
            fontSize: size * 0.4,
          ),
        ),
      ),
    );
  }
}
