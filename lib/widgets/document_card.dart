import 'package:flutter/material.dart';

class DocumentCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;
  final Color? iconBackgroundColor;
  final Color? iconColor;
  final Widget? trailing;
  final bool showArrow;
  final String? badge;
  final Color? badgeColor;

  const DocumentCard({
    super.key,
    required this.title,
    this.subtitle = '',
    this.icon = Icons.insert_drive_file,
    this.onTap,
    this.iconBackgroundColor,
    this.iconColor,
    this.trailing,
    this.showArrow = true,
    this.badge,
    this.badgeColor,
  });

  @override
  State<DocumentCard> createState() => _DocumentCardState();
}

class _DocumentCardState extends State<DocumentCard> with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final iconBgColor = widget.iconBackgroundColor ??
        const Color(0xFF7C6FDC).withOpacity(0.1);
    final iconClr = widget.iconColor ?? const Color(0xFF7C6FDC);

    return GestureDetector(
      onTapDown: widget.onTap == null
          ? null
          : (_) {
        setState(() => _isPressed = true);
        _scaleController.forward();
      },
      onTapUp: widget.onTap == null
          ? null
          : (_) {
        setState(() => _isPressed = false);
        _scaleController.reverse();
      },
      onTapCancel: widget.onTap == null
          ? null
          : () {
        setState(() => _isPressed = false);
        _scaleController.reverse();
      },
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _isPressed
                  ? const Color(0xFF7C6FDC).withOpacity(0.3)
                  : Colors.grey.withOpacity(0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon Container
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: iconBgColor,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      widget.icon,
                      size: 28,
                      color: iconClr,
                    ),
                  ),
                  // Badge
                  if (widget.badge != null)
                    Positioned(
                      top: -6,
                      right: -6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: widget.badgeColor ?? Colors.red,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Text(
                          widget.badge!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),
              // Text Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D2D2D),
                        letterSpacing: 0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (widget.subtitle.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        widget.subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                          letterSpacing: 0.1,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ]
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Trailing Widget or Arrow
              if (widget.trailing != null)
                widget.trailing!
              else if (widget.showArrow)
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: Colors.grey[400],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// Preset card styles for common use cases
class DoctorCard extends StatelessWidget {
  final String doctorName;
  final String specialization;
  final String? imageUrl;
  final VoidCallback? onTap;
  final bool isAvailable;

  const DoctorCard({
    super.key,
    required this.doctorName,
    required this.specialization,
    this.imageUrl,
    this.onTap,
    this.isAvailable = true,
  });

  @override
  Widget build(BuildContext context) {
    return DocumentCard(
      title: doctorName,
      subtitle: specialization,
      icon: Icons.person,
      iconColor: const Color(0xFF7C6FDC),
      onTap: onTap,
      badge: isAvailable ? null : 'Busy',
      badgeColor: Colors.orange,
    );
  }
}

class AppointmentCard extends StatelessWidget {
  final String title;
  final String dateTime;
  final IconData icon;
  final VoidCallback? onTap;
  final Color? accentColor;

  const AppointmentCard({
    super.key,
    required this.title,
    required this.dateTime,
    this.icon = Icons.calendar_today,
    this.onTap,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? const Color(0xFF7C6FDC);
    return DocumentCard(
      title: title,
      subtitle: dateTime,
      icon: icon,
      iconColor: color,
      iconBackgroundColor: color.withOpacity(0.1),
      onTap: onTap,
    );
  }
}

class MedicalRecordCard extends StatelessWidget {
  final String recordType;
  final String date;
  final VoidCallback? onTap;
  final bool isNew;

  const MedicalRecordCard({
    super.key,
    required this.recordType,
    required this.date,
    this.onTap,
    this.isNew = false,
  });

  @override
  Widget build(BuildContext context) {
    return DocumentCard(
      title: recordType,
      subtitle: date,
      icon: Icons.description_outlined,
      onTap: onTap,
      badge: isNew ? 'New' : null,
      badgeColor: const Color(0xFF4CAF50),
    );
  }
}

class RoomCard extends StatelessWidget {
  final String roomNumber;
  final String roomType;
  final bool isAvailable;
  final VoidCallback? onTap;

  const RoomCard({
    super.key,
    required this.roomNumber,
    required this.roomType,
    this.isAvailable = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return DocumentCard(
      title: 'Room $roomNumber',
      subtitle: roomType,
      icon: Icons.meeting_room_outlined,
      iconColor: isAvailable ? const Color(0xFF4CAF50) : Colors.grey,
      iconBackgroundColor: isAvailable
          ? const Color(0xFF4CAF50).withOpacity(0.1)
          : Colors.grey.withOpacity(0.1),
      onTap: onTap,
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isAvailable
              ? const Color(0xFF4CAF50).withOpacity(0.1)
              : Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          isAvailable ? 'Available' : 'Occupied',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isAvailable ? const Color(0xFF4CAF50) : Colors.red,
          ),
        ),
      ),
      showArrow: false,
    );
  }
}