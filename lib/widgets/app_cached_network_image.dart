import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../helpers/network_image_saver.dart';
import '../utils/app_constants.dart';
import '../utils/colors.dart';
import '../utils/dimensions.dart';

ImageProvider<Object>? appCachedImageProvider(String? imageUrl) {
  final resolvedUrl = MediaUrlHelper.resolve(imageUrl);
  if (resolvedUrl == null || _isUnsupportedImageUrl(resolvedUrl)) {
    return null;
  }
  return CachedNetworkImageProvider(resolvedUrl);
}

class AppCachedNetworkImage extends StatelessWidget {
  const AppCachedNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.enableFullscreen = false,
    this.heroTag,
    this.placeholderColor,
    this.placeholderIcon,
  });

  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final bool enableFullscreen;
  final String? heroTag;
  final Color? placeholderColor;
  final IconData? placeholderIcon;

  @override
  Widget build(BuildContext context) {
    final resolvedUrl = MediaUrlHelper.resolve(imageUrl);
    if (resolvedUrl == null || _isUnsupportedImageUrl(resolvedUrl)) {
      return _buildFallback();
    }

    Widget child = CachedNetworkImage(
      imageUrl: resolvedUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (_, __) => _buildFallback(),
      errorWidget: (_, __, error) {
        debugPrint(
          'AppCachedNetworkImage failed: url=$resolvedUrl error=$error',
        );
        return _buildFallback();
      },
    );

    if (heroTag != null) {
      child = Hero(tag: heroTag!, child: child);
    }

    if (borderRadius != null) {
      child = ClipRRect(borderRadius: borderRadius!, child: child);
    }

    if (enableFullscreen) {
      child = InkWell(
        onTap: () {
          Get.to(
            () =>
                AppNetworkImageViewer(imageUrl: resolvedUrl, heroTag: heroTag),
          );
        },
        child: child,
      );
    }

    return child;
  }

  Widget _buildFallback() {
    return Container(
      width: width,
      height: height,
      color: placeholderColor ?? AppColors.grey2,
      alignment: Alignment.center,
      child: Icon(
        placeholderIcon ?? Icons.broken_image_outlined,
        color: AppColors.grey4,
      ),
    );
  }
}

class AppNetworkImageViewer extends StatelessWidget {
  const AppNetworkImageViewer({
    super.key,
    required this.imageUrl,
    this.heroTag,
  });

  final String imageUrl;
  final String? heroTag;

  @override
  Widget build(BuildContext context) {
    final resolvedUrl = MediaUrlHelper.resolve(imageUrl) ?? imageUrl;
    if (_isUnsupportedImageUrl(resolvedUrl)) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: const Center(
          child: Icon(Icons.broken_image_outlined, color: Colors.white),
        ),
      );
    }

    Widget image = CachedNetworkImage(
      imageUrl: resolvedUrl,
      fit: BoxFit.contain,
      placeholder:
          (_, __) => const Center(
            child: CircularProgressIndicator(color: AppColors.primary5),
          ),
      errorWidget:
          (_, __, error) {
            debugPrint(
              'AppNetworkImageViewer failed: url=$resolvedUrl error=$error',
            );
            return const Center(
              child: Icon(Icons.broken_image_outlined, color: Colors.white),
            );
          },
    );

    if (heroTag != null) {
      image = Hero(tag: heroTag!, child: image);
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: () => NetworkImageSaver.saveToGallery(resolvedUrl),
            icon: const Icon(Icons.download_rounded, color: Colors.white),
            tooltip: 'Save to gallery',
          ),
          SizedBox(width: Dimensions.width10),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: InteractiveViewer(minScale: 0.8, maxScale: 4, child: image),
        ),
      ),
    );
  }
}

bool _isUnsupportedImageUrl(String url) {
  final normalized = url.toLowerCase();
  return normalized.endsWith('.svg') || normalized.contains('.svg?');
}
