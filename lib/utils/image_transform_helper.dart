class ImageTransformHelper {
  /// Transforms a Supabase storage URL to include image transformations
  /// for optimized loading (thumbnails, quality adjustments, etc.)
  ///
  /// Supabase Storage supports image transformations via URL parameters:
  /// - width: resize width in pixels
  /// - height: resize height in pixels
  /// - quality: JPEG quality (1-100)
  /// - format: output format (webp, jpg, png)
  /// - resize: resize mode (cover, contain, fill)
  ///
  /// Example URL transformation:
  /// Original: https://project.supabase.co/storage/v1/object/public/bucket/image.jpg
  /// Transformed: https://project.supabase.co/storage/v1/render/image/public/bucket/image.jpg?width=200&quality=80
  static String getThumbnailUrl(
    String originalUrl, {
    int width = 200,
    int quality = 80,
    String? format,
  }) {
    if (originalUrl.isEmpty || !originalUrl.contains('supabase')) {
      return originalUrl;
    }

    // Check if URL is already transformed
    if (originalUrl.contains('/render/image/')) {
      return originalUrl;
    }

    try {
      // Convert storage URL to render URL
      // From: /storage/v1/object/public/...
      // To:   /storage/v1/render/image/public/...
      String transformedUrl = originalUrl.replaceFirst(
        '/storage/v1/object/',
        '/storage/v1/render/image/',
      );

      // Build query parameters
      final params = <String>[];
      params.add('width=$width');
      params.add('quality=$quality');
      if (format != null) {
        params.add('format=$format');
      }

      // Add parameters to URL
      final separator = transformedUrl.contains('?') ? '&' : '?';
      transformedUrl = '$transformedUrl$separator${params.join('&')}';

      return transformedUrl;
    } catch (e) {
      // If transformation fails, return original URL
      return originalUrl;
    }
  }

  /// Get a medium-sized image (400px width)
  static String getMediumUrl(String originalUrl) {
    return getThumbnailUrl(originalUrl, width: 400, quality: 85);
  }

  /// Get a large image (800px width)
  static String getLargeUrl(String originalUrl) {
    return getThumbnailUrl(originalUrl, width: 800, quality: 90);
  }

  /// Get optimized WebP format (best for web)
  static String getWebPUrl(
    String originalUrl, {
    int width = 200,
    int quality = 80,
  }) {
    return getThumbnailUrl(
      originalUrl,
      width: width,
      quality: quality,
      format: 'webp',
    );
  }

  /// Get the original URL without transformations
  static String getOriginalUrl(String url) {
    if (url.contains('/render/image/')) {
      return url
          .replaceFirst('/storage/v1/render/image/', '/storage/v1/object/')
          .split('?')
          .first;
    }
    return url;
  }
}
