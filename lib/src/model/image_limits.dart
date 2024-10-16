// Created by alex@justprodev.com on 16.10.2024.

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