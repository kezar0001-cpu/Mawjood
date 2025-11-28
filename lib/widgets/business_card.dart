import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/business.dart';
import '../utils/app_colors.dart';

class BusinessCard extends StatelessWidget {
  const BusinessCard({
    super.key,
    required this.business,
    required this.onTap,
    this.onCall,
    this.onWhatsApp,
  });

  final Business business;
  final VoidCallback onTap;
  final VoidCallback? onCall;
  final VoidCallback? onWhatsApp;

  @override
  Widget build(BuildContext context) {
    final imageUrl = business.images.isNotEmpty ? business.images.first : null;
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        width: 76,
                        height: 76,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: 76,
                          height: 76,
                          color: AppColors.neutral,
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 76,
                          height: 76,
                          color: AppColors.neutral,
                          child: const Icon(Icons.store, color: AppColors.primary),
                        ),
                      )
                    : Container(
                        width: 76,
                        height: 76,
                        color: AppColors.neutral,
                        child: const Icon(Icons.store, color: AppColors.primary),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      business.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      business.categoryName,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 18, color: AppColors.darkText),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${business.city} • ${business.district}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13, color: AppColors.darkText),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (onCall != null)
                          IconButton(
                            icon: const Icon(Icons.call, color: AppColors.primary),
                            onPressed: onCall,
                            tooltip: 'اتصال',
                          ),
                        if (onWhatsApp != null)
                          IconButton(
                            icon: const Icon(Icons.chat, color: AppColors.primaryLight),
                            onPressed: onWhatsApp,
                            tooltip: 'واتساب',
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
