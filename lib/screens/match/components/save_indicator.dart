// lib/screens/match/components/save_indicator.dart

import 'package:flutter/material.dart';

class SaveIndicator extends StatelessWidget {
  final bool isVisible;
  final String? message;
  final Color? color;

  const SaveIndicator({
    super.key,
    required this.isVisible,
    this.message = 'Saving...',
    this.color = Colors.orange,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color!.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: color!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(color!),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              message!,
              style: TextStyle(
                color: color,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Optional: SaveState enum for different saving states
enum SaveState {
  idle,
  saving,
  success,
  error;

  Color get color {
    switch (this) {
      case SaveState.saving:
        return Colors.orange;
      case SaveState.success:
        return Colors.green;
      case SaveState.error:
        return Colors.red;
      case SaveState.idle:
        return Colors.grey;
    }
  }

  String get message {
    switch (this) {
      case SaveState.saving:
        return 'Saving...';
      case SaveState.success:
        return 'Saved!';
      case SaveState.error:
        return 'Error saving';
      case SaveState.idle:
        return '';
    }
  }
}

// Optional: Extended version with more features
class SaveIndicatorExtended extends StatelessWidget {
  final SaveState state;
  final String? customMessage;
  final VoidCallback? onRetry;

  const SaveIndicatorExtended({
    super.key,
    required this.state,
    this.customMessage,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: state == SaveState.idle ? 0.0 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: state.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: state.color),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (state == SaveState.saving)
              SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(state.color),
                ),
              )
            else
              Icon(
                _getStateIcon(),
                size: 12,
                color: state.color,
              ),
            const SizedBox(width: 8),
            Text(
              customMessage ?? state.message,
              style: TextStyle(
                color: state.color,
                fontSize: 12,
              ),
            ),
            if (state == SaveState.error && onRetry != null) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onRetry,
                child: Icon(
                  Icons.refresh,
                  size: 14,
                  color: state.color,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getStateIcon() {
    switch (state) {
      case SaveState.success:
        return Icons.check_circle_outline;
      case SaveState.error:
        return Icons.error_outline;
      default:
        return Icons.info_outline;
    }
  }
}
