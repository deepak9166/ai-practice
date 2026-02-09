import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';

class SmartImageView extends StatelessWidget {
  const SmartImageView(
    this.path, {
    super.key,
    this.width,
    this.height,
    this.fit,
    this.color,
    this.colorFilter,
    this.placeholder,
    this.errorWidget,
    this.packageName,
    this.radius,
    this.fadeInDuration = const Duration(milliseconds: 300),
  });

  final String? path;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Color? color;
  final ColorFilter? colorFilter;
  final Widget? placeholder;
  final Widget? errorWidget;
  final Duration fadeInDuration;
  final String? packageName;
  final double? radius;

  @override
  Widget build(BuildContext context) {

    // Fixed: added BuildContext context
    if (path == null || path!.trim().isEmpty) {
      return placeholder ?? SizedBox(width: width, height: height);
    }

    final url = path!.trim();
    final isNetwork = url.startsWith('http://') || url.startsWith('https://');
    final isSvg = url.toLowerCase().endsWith('.svg');

    final defaultPlaceholder =
        placeholder ??
        Container(
          width: width,
          height: height,
          color: Colors.grey[200],
          alignment: Alignment.center,
          child: const CircularProgressIndicator(strokeWidth: 2),
        );

    final defaultError =
        errorWidget ??
        Container(
          width: width,
          height: height,
          color: Colors.grey[200],
          alignment: Alignment.center,
          child: Icon(Icons.broken_image, color: Colors.grey[500]),
        );
    Widget? imageWidget;
    if (isNetwork) {
      if (isSvg) {
        imageWidget = SvgPicture.network(
          url,
          width: width,
          height: height,
          fit: fit ?? BoxFit.contain,
          colorFilter:
              colorFilter ??
              (color != null
                  ? ColorFilter.mode(color!, BlendMode.srcIn)
                  : null),
          placeholderBuilder: (_) => defaultPlaceholder,
        );
      }

      imageWidget = CachedNetworkImage(
        imageUrl: url,
        width: width,
        height: height,
        fit: fit ?? BoxFit.cover,
        color: color,
        placeholder: (_, __) => defaultPlaceholder,
        errorWidget: (_, __, ___) => defaultError,
        fadeInDuration: fadeInDuration,
        memCacheWidth: width != null ? (width! * 2).round() : null,
        memCacheHeight: height != null ? (height! * 2).round() : null,
      );
    }

    // Asset images
    if (isSvg) {
      return SvgPicture.asset(
        url,
        width: width,
        height: height,
        fit: fit ?? BoxFit.contain,
        colorFilter:
            colorFilter ??
            (color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null),
        placeholderBuilder: (_) => placeholder ?? const SizedBox.shrink(),
      );
    }

    imageWidget = Image.asset(
      url,
      width: width,
      height: height,
      fit: fit ?? BoxFit.cover,
      color: color,
      errorBuilder: (_, __, ___) => defaultError,
      package: packageName,
    );

    if (radius != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius ?? 0.0),
        child: imageWidget,
      );
    } else {
      return imageWidget;
    }
  }
}
