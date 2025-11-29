import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/business.dart';
import '../utils/app_colors.dart';

class BusinessCard extends StatelessWidget {
  BusinessCard({
    super.key,
    required this.business,
    required this.onTap,
    this.onCall,
    this.categoryLabel,
  });

  final Business business;
  final VoidCallback onTap;
  final VoidCallback? onCall;
  final String? categoryLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final imageUrl = business.primaryImage;
    final safeCity = business.city ?? '';
    // FIXED: Removed dangerous null-check operator (!) for Web compatibility
    final locationLabel = safeCity.isNotEmpty
        ? safeCity
        : (categoryLabel?.isNotEmpty == true ? categoryLabel ?? 'متاح' : 'متاح');

    return Card(
      elevation: 3,
      margin: EdgeInsets.zero,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _BusinessImage(imageUrl: imageUrl),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    business.name,
                                    textAlign: TextAlign.right,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.titleMedium?.copyWith(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.darkText,
                                    ),
                                  ),
                                ),
                                if (business.verified) ...[
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.verified,
                                    size: 18,
                                    color: Colors.blue,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          _CallButton(onCall: onCall),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              categoryLabel ?? business.city ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.right,
                              style: theme.labelLarge?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          _RatingStars(rating: business.rating ?? 0.0),
                          const SizedBox(width: 4),
                          Text(
                            business.rating?.toStringAsFixed(1) ?? '0.0',
                            style: theme.bodySmall?.copyWith(
                              color: Colors.black54,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (business.reviewCount > 0) ...[
                            const SizedBox(width: 4),
                            Text(
                              '(${business.reviewCount})',
                              style: theme.bodySmall?.copyWith(
                                color: Colors.black54,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        business.description ?? '',
                        textAlign: TextAlign.right,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.bodyMedium?.copyWith(color: Colors.black87),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.place_outlined, size: 18, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              business.displayAddress,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.bodySmall?.copyWith(color: Colors.black87),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (business.distanceKm != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.navigation, size: 12, color: AppColors.primary),
                                  const SizedBox(width: 4),
                                  Text(
                                    (business.distanceKm ?? 0) < 1
                                        ? '${((business.distanceKm ?? 0) * 1000).toStringAsFixed(0)} م'
                                        : '${(business.distanceKm ?? 0).toStringAsFixed(1)} كم',
                                    style: theme.labelSmall?.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.neutral,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              locationLabel,
                              style: theme.labelMedium?.copyWith(
                                color: AppColors.darkText,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
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
      ),
    );
  }
}

class _CallButton extends StatelessWidget {
  const _CallButton({required this.onCall});

  final VoidCallback? onCall;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onCall,
        child: Container(
          constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
          padding: const EdgeInsets.all(10),
          child: const Icon(
            Icons.call_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }
}

class _RatingStars extends StatelessWidget {
  const _RatingStars({required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starValue = index + 1;
        final isHalf = rating + 0.5 >= starValue && rating < starValue;
        final isFilled = rating >= starValue;
        return Icon(
          isFilled
              ? Icons.star_rounded
              : isHalf
                  ? Icons.star_half_rounded
                  : Icons.star_border_rounded,
          size: 18,
          color: AppColors.accentGold,
        );
      }),
    );
  }
}

class _BusinessImage extends StatelessWidget {
  const _BusinessImage({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 92,
        height: 92,
        color: AppColors.neutral,
        child: imageUrl != null
            ? CachedNetworkImage(
                imageUrl: imageUrl!,
                fit: BoxFit.cover,
                width: 92,
                height: 92,
                placeholder: (context, url) => Container(color: AppColors.neutral),
                errorWidget: (context, url, error) => const Icon(Icons.store_mall_directory_outlined, color: AppColors.primary),
              )
            : const Icon(Icons.store_mall_directory_outlined, color: AppColors.primary),
      ),
    );
  }
}
