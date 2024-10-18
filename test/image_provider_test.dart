// Copyright 2020 Rene Floor. All rights reserved.
// Use of this source code is governed by a MIT-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

import 'package:cached_image/src/image_provider_with_limits.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_cache_manager.dart';
import 'image_data.dart';
import 'rendering_tester.dart';

void main() {
  TestRenderingFlutterBinding();

  late FakeCacheManager cacheManager;

  setUp(() {
    cacheManager = FakeCacheManager();
  });

  tearDown(() {
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
  });

  group('Image limits', () {
    // upscale 1x1 image to 10x10
    final targetSize = 10;
    late final List<int> kBigImage;

    setUpAll(() async {
      kBigImage = await kTransparentImage.resize(targetSize);
    });

    test(
      'downscale',
      () async {
        // instruct the image provider to downscale kBigImage back to kTransparentImage
        final imageLimits = ImageLimits(limitBytes: kBigImage.length - 1, targetWidthOrHeight: 1);

        final imageAvailable = Completer<ImageInfo>();
        var url = 'foo';
        var expectedResult = cacheManager.returns(url, kBigImage);

        final ImageProvider imageProvider = CachedNetworkImageProvider(
          nonconst('foo'),
          cacheManager: cacheManager,
        ).withLimits(imageLimits);

        final result = imageProvider.resolve(ImageConfiguration.empty);
        final events = <ImageChunkEvent>[];
        result.addListener(
          ImageStreamListener(
            (ImageInfo image, bool synchronousCall) {
              imageAvailable.complete(image);
            },
            onChunk: (ImageChunkEvent event) {
              events.add(event);
            },
            onError: (Object error, StackTrace? stackTrace) {
              imageAvailable.completeError(error, stackTrace);
            },
          ),
        );
        final resultImageInfo = await imageAvailable.future;

        // original image saved
        expect(events.length, expectedResult.chunks);
        for (var i = 0; i < events.length; i++) {
          expect(
            events[i].cumulativeBytesLoaded,
            math.min(
              (i + 1) * expectedResult.chunkSize,
              kBigImage.length,
            ),
          );
          expect(events[i].expectedTotalBytes, kBigImage.length);
        }

        // downscaled image rendered
        expect(resultImageInfo.image.width, 1);
        expect(resultImageInfo.image.height, 1);
      },
      skip: isBrowser,
    );

    test(
      'using original provider if limits is null',
      () async {
        final originalProvider = CachedNetworkImageProvider(
          nonconst('foo'),
          cacheManager: cacheManager,
        );
        expect(identical(originalProvider.withLimits(null), originalProvider), true);
      },
      skip: isBrowser,
    );

    test(
      'using original provider if size less than limit',
      () async {
        // instruct the image provider to downscale kBigImage back to kTransparentImage
        final imageLimits = ImageLimits(limitBytes: kBigImage.length + 1, targetWidthOrHeight: 1);

        final imageAvailable = Completer<ImageInfo>();
        var url = 'foo';
        cacheManager.returns(url, kBigImage);

        final ImageProvider imageProvider = CachedNetworkImageProvider(
          nonconst('foo'),
          cacheManager: cacheManager,
        ).withLimits(imageLimits);

        final result = imageProvider.resolve(ImageConfiguration.empty);

        result.addListener(
          ImageStreamListener(
            (ImageInfo image, bool synchronousCall) {
              imageAvailable.complete(image);
            },
          ),
        );
        final resultImageInfo = await imageAvailable.future;

        // original image rendered
        expect(resultImageInfo.image.width, targetSize);
        expect(resultImageInfo.image.height, targetSize);
      },
      skip: isBrowser,
    );
  });
}

extension on List<int> {
  Future<List<int>> resize(int targetWidth) async {
    final pngCodec = await instantiateImageCodec(
      Uint8List.fromList(kTransparentImage),
      targetWidth: targetWidth,
      allowUpscaling: true,
    );

    final image = (await pngCodec.getNextFrame()).image;

    return (await image.toByteData(format: ImageByteFormat.png))!.buffer.asUint8List();
  }
}
