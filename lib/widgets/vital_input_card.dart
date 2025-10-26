import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class VitalInputCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String unit;
  final String hint;
  final TextEditingController controller;
  final LinearGradient? gradient;
  final Color? backgroundColor;
  final TextInputType keyboardType;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final bool readOnly;
  final String? value;
  final Widget? trailing;

  const VitalInputCard({
    super.key,
    required this.icon,
    required this.title,
    required this.unit,
    required this.hint,
    required this.controller,
    this.gradient,
    this.backgroundColor,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.validator,
    this.inputFormatters,
    this.readOnly = false,
    this.value,
    this.trailing,
  });

  @override
  State<VitalInputCard> createState() => _VitalInputCardState();
}

class _VitalInputCardState extends State<VitalInputCard> {
  bool _isFocused = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
    if (widget.value != null) {
      widget.controller.text = widget.value!;
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasGradient = widget.gradient != null;
    final bgColor = widget.backgroundColor ?? Colors.white;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: hasGradient ? widget.gradient : null,
        color: hasGradient ? null : bgColor,
        borderRadius: BorderRadius.circular(20),
        border: !hasGradient
            ? Border.all(
          color: _isFocused
              ? const Color(0xFF7C6FDC)
              : Colors.grey.withOpacity(0.2),
          width: _isFocused ? 2 : 1,
        )
            : null,
        boxShadow: [
          BoxShadow(
            color: _isFocused
                ? const Color(0xFF7C6FDC).withOpacity(0.2)
                : Colors.black.withOpacity(0.04),
            blurRadius: _isFocused ? 12 : 8,
            offset: const Offset(0, 2),
            spreadRadius: _isFocused ? 1 : 0,
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon Container
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: hasGradient
                  ? Colors.white.withOpacity(0.2)
                  : const Color(0xFF7C6FDC).withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              widget.icon,
              size: 28,
              color: hasGradient ? Colors.white : const Color(0xFF7C6FDC),
            ),
          ),
          const SizedBox(width: 14),
          // Input Field
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 14,
                    color: hasGradient
                        ? Colors.white.withOpacity(0.9)
                        : Colors.grey[600],
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 4),
                TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  keyboardType: widget.keyboardType,
                  readOnly: widget.readOnly,
                  inputFormatters: widget.inputFormatters,
                  onChanged: widget.onChanged,
                  style: TextStyle(
                    color: hasGradient ? Colors.white : const Color(0xFF2D2D2D),
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.hint,
                    hintStyle: TextStyle(
                      color: hasGradient
                          ? Colors.white.withOpacity(0.5)
                          : Colors.grey.withOpacity(0.5),
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
          // Unit or Trailing
          if (widget.trailing != null)
            widget.trailing!
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: hasGradient
                    ? Colors.white.withOpacity(0.2)
                    : const Color(0xFF7C6FDC).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                widget.unit,
                style: TextStyle(
                  fontSize: 14,
                  color: hasGradient ? Colors.white : const Color(0xFF7C6FDC),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Preset vital cards for common measurements
class HeartRateCard extends StatelessWidget {
  final TextEditingController controller;
  final String? value;
  final Function(String)? onChanged;

  const HeartRateCard({
    super.key,
    required this.controller,
    this.value,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return VitalInputCard(
      icon: Icons.favorite,
      title: 'Heart Rate',
      unit: 'BPM',
      hint: '72',
      controller: controller,
      value: value,
      gradient: const LinearGradient(
        colors: [Color(0xFFFF6B6B), Color(0xFFFF8E8E)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onChanged: onChanged,
    );
  }
}

class BloodPressureCard extends StatelessWidget {
  final TextEditingController controller;
  final String? value;
  final Function(String)? onChanged;

  const BloodPressureCard({
    super.key,
    required this.controller,
    this.value,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return VitalInputCard(
      icon: Icons.monitor_heart,
      title: 'Blood Pressure',
      unit: 'mmHg',
      hint: '120/80',
      controller: controller,
      value: value,
      gradient: const LinearGradient(
        colors: [Color(0xFF7C6FDC), Color(0xFF9087E5)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      keyboardType: TextInputType.text,
      onChanged: onChanged,
    );
  }
}

class TemperatureCard extends StatelessWidget {
  final TextEditingController controller;
  final String? value;
  final Function(String)? onChanged;

  const TemperatureCard({
    super.key,
    required this.controller,
    this.value,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return VitalInputCard(
      icon: Icons.thermostat,
      title: 'Temperature',
      unit: '°F',
      hint: '98.6',
      controller: controller,
      value: value,
      gradient: const LinearGradient(
        colors: [Color(0xFFFF9066), Color(0xFFFFAA85)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}')),
      ],
      onChanged: onChanged,
    );
  }
}

class OxygenCard extends StatelessWidget {
  final TextEditingController controller;
  final String? value;
  final Function(String)? onChanged;

  const OxygenCard({
    super.key,
    required this.controller,
    this.value,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return VitalInputCard(
      icon: Icons.air,
      title: 'Oxygen Level',
      unit: '%',
      hint: '98',
      controller: controller,
      value: value,
      gradient: const LinearGradient(
        colors: [Color(0xFF4FC3F7), Color(0xFF29B6F6)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onChanged: onChanged,
    );
  }
}

class WeightCard extends StatelessWidget {
  final TextEditingController controller;
  final String? value;
  final Function(String)? onChanged;

  const WeightCard({
    super.key,
    required this.controller,
    this.value,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return VitalInputCard(
      icon: Icons.monitor_weight,
      title: 'Weight',
      unit: 'kg',
      hint: '70.5',
      controller: controller,
      value: value,
      backgroundColor: Colors.white,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}')),
      ],
      onChanged: onChanged,
    );
  }
}

class HeightCard extends StatelessWidget {
  final TextEditingController controller;
  final String? value;
  final Function(String)? onChanged;

  const HeightCard({
    super.key,
    required this.controller,
    this.value,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return VitalInputCard(
      icon: Icons.height,
      title: 'Height',
      unit: 'cm',
      hint: '175',
      controller: controller,
      value: value,
      backgroundColor: Colors.white,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onChanged: onChanged,
    );
  }
}