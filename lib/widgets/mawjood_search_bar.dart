import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../utils/app_text.dart';

class MawjoodSearchBar extends StatelessWidget {
  const MawjoodSearchBar({
    super.key,
    required this.controller,
    required this.onSubmit,
    this.onChanged,
    this.onFilterTap,
    this.hintText = AppText.searchHint,
    this.actionIcon = Icons.search_rounded,
    this.actionTooltip,
  });

  final TextEditingController controller;
  final ValueChanged<String> onSubmit;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFilterTap;
  final String hintText;
  final IconData actionIcon;
  final String? actionTooltip;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        padding: const EdgeInsetsDirectional.fromSTEB(14, 10, 14, 10),
        child: Row(
          children: [
            const Icon(Icons.search_rounded, color: AppColors.primary, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: controller,
                textAlign: TextAlign.right,
                onSubmitted: onSubmit,
                onChanged: onChanged,
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: TextStyle(
                    color: Colors.black.withOpacity(0.45),
                    fontWeight: FontWeight.w400,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 4),
                ),
              ),
            ),
            IconButton(
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(),
              icon: Icon(actionIcon, color: AppColors.primary),
              onPressed: onFilterTap ?? () => onSubmit(controller.text),
              tooltip: actionTooltip ?? hintText,
            ),
          ],
        ),
      ),
    );
  }
}
