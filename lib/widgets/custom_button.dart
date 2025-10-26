import 'package:flutter/material.dart';
import '../config/theme.dart';

class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final LinearGradient? gradient;
  final Color? backgroundColor;
  final double height;
  final double borderRadius;
  final bool hasShadow;
  final bool isLoading;
  final IconData? icon;
  final Color? textColor;
  final double? fontSize;
  final FontWeight? fontWeight;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final bool isOutlined;
  final Color? borderColor;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.gradient,
    this.backgroundColor,
    this.height = 56,
    this.borderRadius = 24,
    this.hasShadow = false,
    this.isLoading = false,
    this.icon,
    this.textColor,
    this.fontSize = 16,
    this.fontWeight = FontWeight.w600,
    this.padding,
    this.width,
    this.isOutlined = false,
    this.borderColor,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> with SingleTickerProviderStateMixin {
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
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
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
    final buttonGradient = widget.gradient ?? PremiumTheme.purpleGradient;
    final isDisabled = widget.onPressed == null || widget.isLoading;

    return GestureDetector(
      onTapDown: isDisabled
          ? null
          : (_) {
        setState(() => _isPressed = true);
        _scaleController.forward();
      },
      onTapUp: isDisabled
          ? null
          : (_) {
        setState(() => _isPressed = false);
        _scaleController.reverse();
      },
      onTapCancel: isDisabled
          ? null
          : () {
        setState(() => _isPressed = false);
        _scaleController.reverse();
      },
      onTap: isDisabled ? null : widget.onPressed,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: widget.height,
          width: widget.width,
          padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            gradient: widget.isOutlined || isDisabled ? null : (widget.backgroundColor == null ? buttonGradient : null),
            color: widget.isOutlined
                ? Colors.transparent
                : (widget.backgroundColor ?? (isDisabled ? Colors.grey[300] : null)),
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: widget.isOutlined
                ? Border.all(
              color: widget.borderColor ?? const Color(0xFF7C6FDC),
              width: 2,
            )
                : null,
            boxShadow: widget.hasShadow && !isDisabled && !widget.isOutlined
                ? [
              BoxShadow(
                color: const Color(0xFF7C6FDC).withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
                spreadRadius: 0,
              ),
            ]
                : [],
          ),
          alignment: Alignment.center,
          child: widget.isLoading
              ? SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(
                widget.textColor ?? Colors.white,
              ),
            ),
          )
              : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(
                  widget.icon,
                  color: widget.textColor ??
                      (widget.isOutlined ? const Color(0xFF7C6FDC) : Colors.white),
                  size: 20,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                widget.text,
                style: TextStyle(
                  color: widget.textColor ??
                      (widget.isOutlined ? const Color(0xFF7C6FDC) : (isDisabled ? Colors.grey[600] : Colors.white)),
                  fontSize: widget.fontSize,
                  fontWeight: widget.fontWeight,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Preset button styles matching the medical app theme
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      icon: icon,
      gradient: const LinearGradient(
        colors: [Color(0xFF7C6FDC), Color(0xFF9087E5)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ),
      hasShadow: true,
    );
  }
}

class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  const SecondaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      icon: icon,
      backgroundColor: const Color(0xFFF5F5F5),
      textColor: const Color(0xFF2D2D2D),
      hasShadow: false,
    );
  }
}

class OutlinedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  const OutlinedButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      icon: icon,
      isOutlined: true,
      borderColor: const Color(0xFF7C6FDC),
      textColor: const Color(0xFF7C6FDC),
    );
  }
}

class BlackButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  const BlackButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      icon: icon,
      backgroundColor: const Color(0xFF1E1E1E),
      textColor: Colors.white,
      borderRadius: 16,
    );
  }
}