// Created by alex@justprodev.com on 16.10.2024.

import 'dart:ui';
import 'package:flutter/painting.dart';

extension ImageProviderWithLimitsExt on ImageProvider {
  /// Returns a [ImageProviderWithLimits] that resizes image if needed in accordance with [ImageLimits]
  ///
  /// If [imageLimits] is null, returns the original [ImageProvider]
  ImageProvider withLimits(ImageLimits? imageLimits) {
    if (imageLimits == null) return this;

    return ImageProviderWithLimits(this, imageLimits);
  }
}

/// Settings to reduce the memory footprint of [ImageCache].
//
/// If some image file has size > [limitBytes] then image should be resized.
///
/// Value of [targetWidthOrHeight] used depending on which side of image is bigger than [targetWidthOrHeight].
/// Width should be checked first.
///
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ImageLimits && other.limitBytes == limitBytes && other.targetWidthOrHeight == targetWidthOrHeight;
  }

  @override
  int get hashCode => limitBytes.hashCode ^ targetWidthOrHeight.hashCode;
}

/// Wrapper over [ImageProvider] that resizes image ONLY if [ImageLimits.limitBytes] is exceeded.
///
/// Otherwise, the process of loading the image will be the same as for the original [ImageProvider].
class ImageProviderWithLimits extends ImageProvider<ImageLimitsKey> {
  final ImageLimits imageLimits;
  final ImageProvider delegatedImageProvider;

  const ImageProviderWithLimits(
    this.delegatedImageProvider,
    this.imageLimits,
  );

  @override
  ImageStreamCompleter loadImage(ImageLimitsKey key, ImageDecoderCallback decode) {
    Future<Codec> wrapper(ImmutableBuffer buffer, {TargetImageSizeCallback? getTargetSize}) {
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

    return delegatedImageProvider.loadImage(key._delegatedProviderKey, wrapper);
  }

  @override
  Future<ImageLimitsKey> obtainKey(ImageConfiguration configuration) {
    // note [SynchronousFuture.then] will also return a synchronous future.
    return delegatedImageProvider.obtainKey(configuration).then((key) => ImageLimitsKey._(key, imageLimits));
  }
}

/// Key used internally by [ImageProviderWithLimits].
///
/// This is used to identify the precise resource in the [imageCache].
///
/// So, it like [ResizeImageKey]
class ImageLimitsKey {
  final Object _delegatedProviderKey;
  final ImageLimits _imageLimits;

  const ImageLimitsKey._(this._delegatedProviderKey, this._imageLimits);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ImageLimitsKey &&
        other._delegatedProviderKey == _delegatedProviderKey &&
        other._imageLimits == _imageLimits;
  }

  @override
  int get hashCode => Object.hash(_delegatedProviderKey, _imageLimits);
}
