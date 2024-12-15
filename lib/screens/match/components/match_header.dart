import 'package:flutter/material.dart';
import '../../../models/match.dart';

class MatchHeader extends StatelessWidget {
  final MatchStatus status;
  final String time;

  const MatchHeader({
    super.key,
    required this.status,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: _getStatusColor(status),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _getStatusText(status),
              style: TextStyle(
                color: _getStatusColor(status),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
        Text(
          time,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(MatchStatus status) {
    switch (status) {
      case MatchStatus.scheduled:
        return Colors.blue;
      case MatchStatus.inProgress:
        return Colors.orange;
      case MatchStatus.completed:
        return Colors.green;
      case MatchStatus.cancelled:
        return Colors.red;
      case MatchStatus.waitingPlayers:
        return Colors.purple;
    }
  }

  String _getStatusText(MatchStatus status) {
    switch (status) {
      case MatchStatus.scheduled:
        return 'Scheduled';
      case MatchStatus.inProgress:
        return 'In Progress';
      case MatchStatus.completed:
        return 'Completed';
      case MatchStatus.cancelled:
        return 'Cancelled';
      case MatchStatus.waitingPlayers:
        return 'Waiting Players';
    }
  }
}
