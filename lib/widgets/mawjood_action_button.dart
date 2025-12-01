import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

class MawjoodActionButton extends StatelessWidget {
  const MawjoodActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.enabled = true,
    this.backgroundColor,
    this.foregroundColor,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool enabled;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final effectiveBg = backgroundColor ?? AppColors.primaryLight.withOpacity(0.18);
    final effectiveFg = foregroundColor ?? AppColors.darkText;
    final disabled = !enabled;
    return Material(
      color: disabled ? effectiveBg.withOpacity(0.3) : effectiveBg,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: disabled ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              textDirection: TextDirection.rtl,
              children: [
                Icon(icon, color: disabled ? effectiveFg.withOpacity(0.5) : effectiveFg, size: 22),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: theme.labelLarge?.copyWith(
                    color: disabled ? effectiveFg.withOpacity(0.6) : effectiveFg,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
