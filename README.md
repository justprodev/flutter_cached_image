[![Flutter Test in Pull Requests](https://github.com/justprodev/flutter_cached_image/actions/workflows/pull_request.yaml/badge.svg)](https://github.com/justprodev/flutter_cached_image/actions/workflows/pull_request.yaml)
[![codecov](https://codecov.io/gh/justprodev/flutter_cached_image/graph/badge.svg?token=2QHJCEYEBU)](https://codecov.io/gh/justprodev/flutter_cached_image)

# Motivation

1. Preconfigure [CachedNetworkImage](https://pub.dev/packages/cached_network_image).
2. Ability to using [memory limits](/lib/src/image_provider_with_limits.dart) for using in mobile for a cases when backend sends big images sometimes.

[Online demo](https://justprodev.com/demo/cached_image/index.html)

# Usage

Add to `pubspec.yaml`:

```yaml
  cached_image:
    git:
      url: https://github.com/justprodev/flutter_cached_image.git
      tag: 3.4.2-rc.05 # control the version, please - check releases
```

```dart
CachedImage.image(
  'https://picsum.photos/seed/100/300/200',
  width: 300,
  height: 200,
  fit: BoxFit.cover,
  borderRadius: const BorderRadius.all(Radius.circular(24)),
  // If some image size > [limitBytes] then downscale
  imageLimits: const ImageLimits(limitBytes: 1024 * 1024, targetWidthOrHeight: 1024),
);
```

You can also preconfigure the error and placeholder widgets.

```dart
configureCachedImage() {
  CachedImage.setDefaultErrorWidget((context, url, error, [widgetParameters]) {
    if (widgetParameters == null) {
      return const SizedBox();
    }

    return ClipRRect(
      clipBehavior: Clip.hardEdge,
      borderRadius: widgetParameters.$1 ?? const BorderRadius.all(Radius.circular(4)),
      child: ColoredBox(
        color: Colors.white,
        child: SizedBox(
          width: widgetParameters.$2,
          height: widgetParameters.$3,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '😢',
                  style: Theme.of(context).textTheme.displayLarge,
                  textAlign: TextAlign.center,
                ),
                Text(
                  'Image not loaded',
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  });

  CachedImage.setDefaultPlaceholder((context, url, widgetParameters) {
    return defaultPlaceholder(context, url, widgetParameters).animate(onPlay: (c) => c.loop()).shimmer(
      colors: [
        Colors.white,
        Colors.grey[300]!,
        Colors.white,
      ],
      duration: const Duration(milliseconds: 1500),
    );
  });
}
```

See [example](/example/) for more details.
