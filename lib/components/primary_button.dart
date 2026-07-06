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
    final isButtonEnabled = onPressed != null;

    final fgColor = isDark
        ? (isButtonEnabled ? Color.lerp(baseColor, Colors.white, 0.4)! : Colors.white70)
        : Colors.white;

    final sColor = isDark ? Colors.transparent : baseColor.withValues(alpha: 0.4);

    final gradient = isDark
        ? (isButtonEnabled
            ? LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  baseColor.withValues(alpha: 0.15),
                  baseColor.withValues(alpha: 0.25),
                ],
              )
            : LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.white.withValues(alpha: 0.05),
                  Colors.white.withValues(alpha: 0.1),
                ],
              ))
        : (isDefault
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
                  Color.lerp(baseColor, Colors.white, 0.25)!,
                ],
              ));

    final border = isDark
        ? Border.all(
            color: isButtonEnabled
                ? baseColor.withValues(alpha: 0.4)
                : Colors.white.withValues(alpha: 0.1),
            width: 1.5,
          )
        : null;

    final bgColor = Colors.transparent;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      height: 54,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: gradient,
        border: border,
        boxShadow: (!isDark && isButtonEnabled && !loading)
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
          disabledForegroundColor: isDark ? Colors.white30 : null,
          disabledBackgroundColor: isDark ? Colors.transparent : null,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
      ),
    );
  }
}
