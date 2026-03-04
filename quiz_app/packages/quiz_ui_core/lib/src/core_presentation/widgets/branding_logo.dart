import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:quiz_domain/quiz_domain.dart';

class BrandingLogo extends StatelessWidget {
  final double size;
  final Widget? fallback;
  final OrganizationBrandingEntity? branding;

  const BrandingLogo({
    super.key,
    this.size = 32,
    this.fallback,
    this.branding,
  });

  @override
  Widget build(BuildContext context) {
    if (branding?.logoUrl != null) {
      return CachedNetworkImage(
        imageUrl: branding!.logoUrl!,
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorWidget: (_, __, ___) => _buildFallback(),
        placeholder: (_, __) => _buildFallback(),
      );
    }

    return _buildFallback();
  }

  Widget _buildFallback() {
    return fallback ??
        Icon(Icons.token_rounded, size: size, color: Colors.white);
  }
}
