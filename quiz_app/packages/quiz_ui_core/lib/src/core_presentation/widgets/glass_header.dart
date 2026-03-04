import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:quiz_domain/quiz_domain.dart';
import '../design_system.dart';

class GlassHeader extends StatelessWidget {
  final Widget? title;
  final Widget? child;
  final List<Widget>? actions;
  final Widget? leading;
  final double height;
  final bool showBorder;
  final OrganizationBrandingEntity? branding;

  const GlassHeader({
    super.key,
    this.title,
    this.child,
    this.actions,
    this.leading,
    this.height = AppSpacing.headerHeightCompact,
    this.showBorder = true,
    this.branding,
  });

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final bannerUrl = branding?.bannerUrl;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          height: height + topPadding + 1.0,
          padding: EdgeInsets.only(top: topPadding),
          decoration: BoxDecoration(
            color: bannerUrl != null
                ? Colors.black.withValues(alpha: 0.6)
                : AppColors.surface.withValues(alpha: 0.12),
            image: bannerUrl != null
                ? DecorationImage(
                    image: CachedNetworkImageProvider(bannerUrl),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                        Colors.black.withValues(alpha: 0.4), BlendMode.darken),
                  )
                : null,
            border: showBorder
                ? Border(
                    bottom: BorderSide(
                      color: Colors.white.withValues(alpha: 0.1),
                      width: 0.5,
                    ),
                  )
                : null,
          ),
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Column(
              mainAxisAlignment: child != null
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: child != null ? kToolbarHeight : height,
                  child: NavigationToolbar(
                    leading: leading != null
                        ? Padding(
                            padding: const EdgeInsets.only(left: AppSpacing.sm),
                            child: leading!,
                          )
                        : null,
                    middle: title != null
                        ? DefaultTextStyle(
                            style: AppTypography.h3.copyWith(
                              fontSize: child != null ? 18 : 20,
                              letterSpacing: -0.5,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: title!,
                          )
                        : null,
                    trailing: actions != null
                        ? Padding(
                            padding:
                                const EdgeInsets.only(right: AppSpacing.sm),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: actions!,
                            ),
                          )
                        : null,
                    centerMiddle: true,
                  ),
                ),
                if (child != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    child: child!,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
