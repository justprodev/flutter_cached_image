// Created by alex@justprodev.com on 16.10.2024.

import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/painting.dart';

import 'model/image_limits.dart';

/// If [imageLimits] is not null and image size > [ImageLimits.limitBytes] then image will be resized
class CachedNetworkImageProviderWithLimits extends CachedNetworkImageProvider {
  final ImageLimits? imageLimits;

  /// Creates an ImageProvider which loads an image from the [url], using the [scale].
  /// When the image fails to load [errorListener] is called.
  const CachedNetworkImageProviderWithLimits(
    super.url, {
    super.maxHeight,
    super.maxWidth,
    super.scale,
    super.errorListener,
    super.headers,
    super.cacheManager,
    super.cacheKey,
    super.imageRenderMethodForWeb,
    this.imageLimits,
  });

  @override
  ImageStreamCompleter loadImage(CachedNetworkImageProvider key, ImageDecoderCallback decode) {
    Future<Codec> wrapper(ImmutableBuffer buffer, {TargetImageSizeCallback? getTargetSize}) async {
      final imageLimits = this.imageLimits;

      if (imageLimits != null && buffer.length > imageLimits.limitBytes) {
        return instantiateImageCodecWithSize(buffer, getTargetSize: (int intrinsicWidth, int intrinsicHeight) {
          final parentTargetSize = getTargetSize?.call(intrinsicWidth, intrinsicHeight);

          int currentTargetWidth = parentTargetSize?.width ?? intrinsicWidth;
          int currentTargetHeight = parentTargetSize?.height ?? intrinsicHeight;

          if(currentTargetWidth > imageLimits.targetWidthOrHeight) {
            return TargetImageSize(width: imageLimits.targetWidthOrHeight);
          } else if(currentTargetHeight > imageLimits.targetWidthOrHeight) {
            return TargetImageSize(height: imageLimits.targetWidthOrHeight);
          }

          return getTargetSize!(currentTargetWidth, currentTargetWidth);
        });
      }

      return decode(buffer, getTargetSize: getTargetSize);
    }

    return super.loadImage(key, wrapper);
  }
}
