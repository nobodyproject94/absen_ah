import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool loading;
  final Color? backgroundColor;

  const PrimaryButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.loading = false,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDefault = backgroundColor == null;
    final baseColor = backgroundColor ?? AppColors.primary;
    
    final fgColor = (isDark && !isDefault) ? Color.lerp(baseColor, Colors.white, 0.2)! : Colors.white;
    final sColor = isDark ? Colors.transparent : baseColor.withValues(alpha: 0.4);

    final gradient = isDefault
        ? const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [AppColors.primary, AppColors.secondary],
          )
        : LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              baseColor,
              Color.lerp(baseColor, Colors.white, 0.25)!
            ],
          );

    final bgColor = Colors.transparent; // Since all buttons now have gradients, background should be transparent

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      height: 54,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: gradient,
        boxShadow: (!isDark && !loading)
            ? [BoxShadow(color: sColor, blurRadius: 6, offset: const Offset(0, 3))]
            : null,
      ),
      child: ElevatedButton.icon(
        onPressed: loading ? null : onPressed,
        icon: loading
            ? SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: fgColor),
              )
            : Icon(icon ?? Icons.arrow_forward_rounded, color: fgColor),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: fgColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          elevation: 0, // Elevation is handled by AnimatedContainer's boxShadow
          shadowColor: Colors.transparent,
        ),
      ),
    );
  }
}
