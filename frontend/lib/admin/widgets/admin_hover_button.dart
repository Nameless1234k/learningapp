import 'package:flutter/material.dart';

class AdminHoverButton extends StatefulWidget {
  final VoidCallback onTap;
  final IconData icon;
  final String label;
  final Color textColor;
  final Color backgroundColor;
  final Color hoverBackgroundColor;
  final Color borderColor;
  final Color hoverBorderColor;
  final Color? hoverTextColor;
  final double height;
  final EdgeInsetsGeometry padding;

  const AdminHoverButton({
    super.key,
    required this.onTap,
    required this.icon,
    required this.label,
    required this.textColor,
    required this.backgroundColor,
    required this.hoverBackgroundColor,
    required this.borderColor,
    required this.hoverBorderColor,
    this.hoverTextColor,
    this.height = 42,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  });

  @override
  State<AdminHoverButton> createState() => _AdminHoverButtonState();
}

class _AdminHoverButtonState extends State<AdminHoverButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final currentColor = (_isHovered && widget.hoverTextColor != null)
        ? widget.hoverTextColor!
        : widget.textColor;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeInOut,
          height: widget.height,
          padding: widget.padding,
          decoration: BoxDecoration(
            color: _isHovered ? widget.hoverBackgroundColor : widget.backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isHovered ? widget.hoverBorderColor : widget.borderColor,
              width: 1.5,
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 18, color: currentColor),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13.5,
                  color: currentColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
