/// Service for optimizing media delivery using Supabase Image Transformation.
///
/// Instead of fetching original high-res assets, it transforms URLs to
/// request optimized, resized versions from the edge CDN.
class MediaTransformationService {
  static const String _supabaseBaseUrl =
      'https://your-project.supabase.co/storage/v1/render/image/public';

  /// Generates a transformed URL for an image.
  ///
  /// [bucket] The Supabase storage bucket.
  /// [path] The path to the file.
  /// [width] Target width.
  /// [height] Target height.
  /// [quality] Quality (1-100).
  /// [format] Target format (webp is default).
  static String getTransformedUrl({
    required String bucket,
    required String path,
    int? width,
    int? height,
    int quality = 80,
    String format = 'webp',
  }) {
    final params = [
      'quality=$quality',
      'format=$format',
      if (width != null) 'width=$width',
      if (height != null) 'height=$height',
      'resize=contain',
    ].join('&');

    return '$_supabaseBaseUrl/$bucket/$path?$params';
  }
}
