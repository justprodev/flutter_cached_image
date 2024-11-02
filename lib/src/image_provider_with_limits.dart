// Created by alex@justprodev.com on 16.10.2024.

import 'dart:ui';

import 'package:flutter/painting.dart';

extension ImageProviderWithLimitsExt<T extends Object> on ImageProvider<T> {
  /// Returns a [ImageProviderWithLimits] that resizes image if needed in accordance with [ImageLimits]
  ///
  /// If [imageLimits] is null, returns the original [ImageProvider]
  ImageProvider<T> withLimits(ImageLimits? imageLimits) {
    if (imageLimits == null) return this;

    return ImageProviderWithLimits<T>(this, imageLimits);
  }
}

/// Settings to reduce memory usage when rendering images.
///
/// If some image file has size > [limitBytes] then image should be resized
///
/// value of [targetWidthOrHeight] used depending on which side of image is bigger
///
/// Example:
///
/// ```dart
/// ImageLimits(
///  limitBytes: 1024 * 1024, // 1MB
///  targetWidthOrHeight: 1024,
///  )
///  ```
///  In this case, if image size > 1MB and their width = 2000px and height = 1000px
///  then image will be resized to 1024px width and 512px height.
class ImageLimits {
  final int limitBytes;
  final int targetWidthOrHeight;

  const ImageLimits({
    required this.limitBytes,
    required this.targetWidthOrHeight,
  });
}

/// Wrapper over [ImageProvider] that resizes image ONLY if [ImageLimits.limitBytes] is exceeded.
///
/// Otherwise, the process of loading the image will be the same as for the original [ImageProvider].
///
/// Note: Because we doing "full delegation", the [ImageCache] will treat this provider as delegated image provider.
/// This means that object without limits and object with limits will be treated as same objects.
class ImageProviderWithLimits<T extends Object> extends ImageProvider<T> {
  final ImageLimits imageLimits;
  final ImageProvider<T> delegatedImageProvider;

  const ImageProviderWithLimits(
    this.delegatedImageProvider,
    this.imageLimits,
  );

  @override
  ImageStreamCompleter loadImage(T key, ImageDecoderCallback decode) {
    Future<Codec> wrapper(ImmutableBuffer buffer, {TargetImageSizeCallback? getTargetSize}) async {
      if (buffer.length > imageLimits.limitBytes) {
        return decode(buffer, getTargetSize: (int intrinsicWidth, int intrinsicHeight) {
          final parentTargetSize = getTargetSize?.call(intrinsicWidth, intrinsicHeight);

          int currentTargetWidth = parentTargetSize?.width ?? intrinsicWidth;
          int currentTargetHeight = parentTargetSize?.height ?? intrinsicHeight;

          // scale down to fit width or height
          if (currentTargetWidth > imageLimits.targetWidthOrHeight) {
            return TargetImageSize(width: imageLimits.targetWidthOrHeight);
          } else if (currentTargetHeight > imageLimits.targetWidthOrHeight) {
            return TargetImageSize(height: imageLimits.targetWidthOrHeight);
          }

          return TargetImageSize(width: currentTargetWidth, height: currentTargetHeight);
        });
      }

      return decode(buffer, getTargetSize: getTargetSize);
    }

    return delegatedImageProvider.loadImage(key, wrapper);
  }

  @override
  Future<T> obtainKey(ImageConfiguration configuration) {
    return delegatedImageProvider.obtainKey(configuration);
  }

  @override
  bool operator ==(Object other) {
    return delegatedImageProvider == other;
  }

  @override
  int get hashCode => delegatedImageProvider.hashCode;
}
