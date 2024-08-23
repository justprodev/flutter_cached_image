// Created by alex@justprodev.com on 07.07.2024.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'src/model/blank_asset.dart';
import 'src/model/default_handlers.dart';
import 'src/model/types.dart';

export 'package:flutter_cache_manager/flutter_cache_manager.dart' show FileInfo;
export 'src/model/types.dart';
export 'src/model/default_handlers.dart';

/// cache for images
class CachedImage {
  static BaseCacheManager _cacheManager = DefaultCacheManager();
  static Function(Object)? _defaultErrorListener = defaultErrorListener;
  static ExtendedPlaceholderWidgetBuilder _defaultPlaceholder = defaultPlaceholder;
  static ExtendedErrorWidgetBuilder _defaultErrorWidget = defaultErrorWidget;

  /// just wrapper over [cached_network_image]
  /// Now, it just handles blank urls to avoid network errors
  /// [errorListener] - Listener to be called when images fails to load.
  static ImageProvider provider(
    String? url, {
    Map<String, String>? httpHeaders,
    Function(Object)? errorListener,
  }) {
    if (url != null && url.isNotEmpty) {
      return CachedNetworkImageProvider(
        cacheManager: _cacheManager,
        headers: httpHeaders,
        errorListener: errorListener ?? _defaultErrorListener,
        url,
      );
    } else {
      return blankAsset;
    }
  }

  /// [errorListener] - Listener to be called when images fails to load.
  /// [animation] - If true, the image will fade in once it has been loaded.
  /// Widget displayed while the target [url] failed loading.
  static Widget image(
    String? url, {
    Key? key,
    double? width,
    double? height,
    BoxFit? fit,
    Map<String, String>? httpHeaders,
    PlaceholderWidgetBuilder? placeholder,
    BorderRadius? borderRadius,
    Function(Object)? errorListener,
    LoadingErrorWidgetBuilder? errorWidget,
    bool animation = false,
    Alignment alignment = Alignment.center,
  }) {
    // if width and height are provided, then we can use default placeholder and error widget
    if (width != null && height != null) {
      placeholder ??= (context, _) => _defaultPlaceholder(context, url ?? '', (borderRadius, width, height));
      errorWidget ??= (context, _, error) {
        return _defaultErrorWidget(context, url ?? '', error, (borderRadius, width, height));
      };
    }

    // if no error widget provided, then use default error widget without width and height
    errorWidget ??= (context, _, error) => _defaultErrorWidget(context, url ?? '', error);

    // if no image url provided, then return placeholder or blank image
    if (url == null || url.isEmpty) {
      if (placeholder != null) {
        return Builder(builder: (context) => placeholder!(context, ''));
      } else {
        return const SizedBox();
      }
    }

    // if borderRadius is provided, then wrap image with ClipRRect
    ImageWidgetBuilder? imageBuilder;
    if (borderRadius != null) {
      imageBuilder = (context, imageProvider) {
        return ClipRRect(
          clipBehavior: Clip.hardEdge,
          borderRadius: borderRadius,
          child: Image(image: imageProvider, fit: fit ?? BoxFit.cover, width: width, height: height),
        );
      };
    }

    // if animation is enabled, then set fadeInDuration and fadeOutDuration
    final Duration? fadeInDuration;
    final Duration? fadeOutDuration;
    if (animation) {
      fadeInDuration = const Duration(milliseconds: 250);
      fadeOutDuration = const Duration(milliseconds: 500);
    } else {
      fadeInDuration = Duration.zero;
      fadeOutDuration = Duration.zero;
    }

    return CachedNetworkImage(
      cacheManager: _cacheManager,
      alignment: alignment,
      key: key,
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      httpHeaders: httpHeaders,
      placeholder: placeholder,
      imageBuilder: imageBuilder,
      useOldImageOnUrlChange: true,
      errorWidget: errorWidget,
      errorListener: errorListener ?? defaultErrorListener,
      fadeInDuration: fadeInDuration,
      fadeOutDuration: fadeOutDuration,
    );
  }

  /// To directly manipulate the cache,
  /// i.e. to preload images, clear cache, etc.
  static BaseCacheManager get cacheManager => _cacheManager;

  // set static fields

  /// Set the default cache manager used for image caching.
  /// The default cache manager is [DefaultCacheManager].
  static setCacheManager(BaseCacheManager cacheManager) {
    _cacheManager = cacheManager;
  }

  /// Set the default error listener to be called when images fails to load.
  /// The default error listener is [defaultErrorListener].
  static setDefaultErrorListener(Function(Object) errorListener) {
    _defaultErrorListener = errorListener;
  }

  /// Set the default placeholder widget builder.
  /// The default placeholder widget builder is [defaultPlaceholder].
  static setDefaultPlaceholder(ExtendedPlaceholderWidgetBuilder placeholder) {
    _defaultPlaceholder = placeholder;
  }

  /// Set the default error widget builder.
  /// The default error widget builder is [defaultErrorWidget].
  static setDefaultErrorWidget(ExtendedErrorWidgetBuilder errorWidget) {
    _defaultErrorWidget = errorWidget;
  }
}
