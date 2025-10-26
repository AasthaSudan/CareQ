import 'package:flutter/material.dart';

class StatusIndicator extends StatelessWidget {
  final String status;
  final double size;
  final bool showLabel;
  final bool showPulse;
  final StatusStyle style;

  const StatusIndicator({
    super.key,
    required this.status,
    this.size = 20,
    this.showLabel = true,
    this.showPulse = false,
    this.style = StatusStyle.dot,
  });

  Color getStatusColor() {
    switch (status.toLowerCase()) {
      case 'available':
      case 'green':
      case 'active':
      case 'approved':
      case 'completed':
        return const Color(0xFF4CAF50);
      case 'busy':
      case 'yellow':
      case 'warning':
      case 'pending':
        return const Color(0xFFFFA726);
      case 'offline':
      case 'red':
      case 'critical':
      case 'rejected':
      case 'cancelled':
        return const Color(0xFFEF5350);
      case 'away':
      case 'inactive':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String getStatusLabel() {
    switch (status.toLowerCase()) {
      case 'available':
      case 'active':
        return 'Available';
      case 'busy':
        return 'Busy';
      case 'offline':
        return 'Offline';
      case 'away':
        return 'Away';
      case 'pending':
        return 'Pending';
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      case 'critical':
        return 'Critical';
      default:
        return status.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = getStatusColor();

    switch (style) {
      case StatusStyle.dot:
        return _buildDotStyle(color);
      case StatusStyle.badge:
        return _buildBadgeStyle(color);
      case StatusStyle.chip:
        return _buildChipStyle(color);
      case StatusStyle.outlined:
        return _buildOutlinedStyle(color);
    }
  }

  Widget _buildDotStyle(Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            if (showPulse)
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 1500),
                repeat: true,
                builder: (context, value, child) {
                  return Container(
                    width: size * (1 + value * 0.8),
                    height: size * (1 + value * 0.8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.3 * (1 - value)),
                      shape: BoxShape.circle,
                    ),
                  );
                },
              ),
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ],
        ),
        if (showLabel) ...[
          const SizedBox(width: 8),
          Text(
            getStatusLabel(),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 13,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBadgeStyle(Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          if (showLabel) ...[
            const SizedBox(width: 6),
            Text(
              getStatusLabel(),
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChipStyle(Color color) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: showLabel ? 12 : 8,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: showLabel
          ? Text(
        getStatusLabel(),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 12,
          letterSpacing: 0.5,
        ),
      )
          : Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _buildOutlinedStyle(Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          if (showLabel) ...[
            const SizedBox(width: 6),
            Text(
              getStatusLabel(),
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

enum StatusStyle {
  dot,      // Simple dot with optional label
  badge,    // Rounded rectangle with background
  chip,     // Solid color chip
  outlined, // Outlined border style
}

// Preset status widgets
class OnlineStatus extends StatelessWidget {
  final bool isOnline;
  final bool showPulse;
  final StatusStyle style;

  const OnlineStatus({
    super.key,
    this.isOnline = true,
    this.showPulse = true,
    this.style = StatusStyle.dot,
  });

  @override
  Widget build(BuildContext context) {
    return StatusIndicator(
      status: isOnline ? 'available' : 'offline',
      showLabel: false,
      showPulse: showPulse && isOnline,
      size: 12,
      style: style,
    );
  }
}

class AppointmentStatus extends StatelessWidget {
  final String status; // pending, approved, completed, cancelled
  final StatusStyle style;

  const AppointmentStatus({
    super.key,
    required this.status,
    this.style = StatusStyle.badge,
  });

  @override
  Widget build(BuildContext context) {
    return StatusIndicator(
      status: status,
      showLabel: true,
      style: style,
    );
  }
}

class RoomStatus extends StatelessWidget {
  final bool isAvailable;
  final StatusStyle style;

  const RoomStatus({
    super.key,
    required this.isAvailable,
    this.style = StatusStyle.chip,
  });

  @override
  Widget build(BuildContext context) {
    return StatusIndicator(
      status: isAvailable ? 'available' : 'busy',
      showLabel: true,
      style: style,
    );
  }
}

class PriorityIndicator extends StatelessWidget {
  final String priority; // critical, warning, normal
  final StatusStyle style;

  const PriorityIndicator({
    super.key,
    required this.priority,
    this.style = StatusStyle.outlined,
  });

  @override
  Widget build(BuildContext context) {
    return StatusIndicator(
      status: priority,
      showLabel: true,
      style: style,
    );
  }
}