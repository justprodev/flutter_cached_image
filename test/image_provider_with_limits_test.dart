// Copyright 2020 Rene Floor. All rights reserved.
// Use of this source code is governed by a MIT-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

import 'package:cached_image/src/image_provider_with_limits.dart';
import 'package:cached_image/src/model/blank_asset.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_cache_manager.dart';
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
    test(
      'downscale rendered & source saved',
      () async {
        // upscale 1x1 image to 10x10
        final kBigImage = await kTransparentImage.resize(10);
        // instruct the image provider to downscale kBigImage back to kTransparentImage
        final imageLimits = ImageLimits(limitBytes: kBigImage.length - 1, targetWidthOrHeight: 1);

        final events = <ImageChunkEvent>[];
        var url = 'foo';
        var expectedResult = cacheManager.returns(url, kBigImage);

        final ImageProvider imageProvider = CachedNetworkImageProvider(
          nonconst('foo'),
          cacheManager: cacheManager,
        ).withLimits(imageLimits);

        final resultImageInfo = await imageProvider.invoke(onChunk: events.add);

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

        // downscale 10x10 image to 1x1
        expect(resultImageInfo.image.width, 1);
        expect(resultImageInfo.image.height, 1);
      },
      skip: isBrowser,
    );

    test(
      'using original provider if limits is null',
      () {
        final originalProvider = MemoryImage(Uint8List(0));
        expect(identical(originalProvider.withLimits(null), originalProvider), true);
      },
      skip: isBrowser,
    );

    test(
      'using original provider if size less than limit',
      () async {
        final kBigImage = await kTransparentImage.resize(10);
        // limit will be never reached
        final imageLimits = ImageLimits(limitBytes: kBigImage.length + 1, targetWidthOrHeight: 1);

        final imageProvider = MemoryImage(Uint8List.fromList(kBigImage)).withLimits(imageLimits);
        final resultImageInfo = await imageProvider.invoke();

        //
        expect(resultImageInfo.image.width, 10);
        expect(resultImageInfo.image.height, 10);
      },
      skip: isBrowser,
    );

    test(
      'skip scaling if intrinsics less than target',
      () async {
        final kBigImage = await kTransparentImage.resize(10);
        // limit will be reached, but image is already smaller than target
        final imageLimits = ImageLimits(limitBytes: 0, targetWidthOrHeight: 20);

        final imageProvider = MemoryImage(Uint8List.fromList(kBigImage)).withLimits(imageLimits);
        final resultImageInfo = await imageProvider.invoke();

        // no scaling
        expect(resultImageInfo.image.width, 10);
        expect(resultImageInfo.image.height, 10);
      },
      skip: isBrowser,
    );

    test(
      'downscale resized image',
      () async {
        // upscale 1x1 image to 20x20
        final kBigImage = await kTransparentImage.resize(20, 20);
        final imageLimits = ImageLimits(limitBytes: 0, targetWidthOrHeight: 1);

        final imageProvider = ResizeImage(
          MemoryImage(Uint8List.fromList(kBigImage)),
          // downscale 20x20 image to 10x10
          width: 10,
        ).withLimits(imageLimits);
        final resultImageInfo = await imageProvider.invoke();

        // downscale 10x10 image to 1x1
        expect(resultImageInfo.image.width, 1);
        expect(resultImageInfo.image.height, 1);
      },
      skip: isBrowser,
    );

    test(
      'downscale if height side is bigger',
      () async {
        // upscale 1x1 image to 2x4
        final kTransparentDoubleHeightImage = await kTransparentImage.resize(2, 4);
        final imageLimits = ImageLimits(limitBytes: 0, targetWidthOrHeight: 2);

        final imageProvider = MemoryImage(Uint8List.fromList(kTransparentDoubleHeightImage)).withLimits(imageLimits);
        final resultImageInfo = await imageProvider.invoke();

        // downscale 2x4 image to 1x2, because height side is bigger than target
        expect(resultImageInfo.image.width, 1);
        expect(resultImageInfo.image.height, 2);
      },
      skip: isBrowser,
    );

    test(
      'image cache hit',
          () async {
        final imageLimits = ImageLimits(limitBytes: 1000, targetWidthOrHeight: 1000);

        final imageProvider = MemoryImage(Uint8List.fromList(kTransparentImage)).withLimits(imageLimits);
        await imageProvider.invoke();

        //
        expect(PaintingBinding.instance.imageCache.containsKey(imageProvider), true);
      },
      skip: isBrowser,
    );
  });
}

extension on List<int> {
  Future<List<int>> resize(int targetWidth, [int? targetHeight]) async {
    final pngCodec = await instantiateImageCodec(
      Uint8List.fromList(this),
      targetWidth: targetWidth,
      targetHeight: targetHeight,
      allowUpscaling: true,
    );

    final image = (await pngCodec.getNextFrame()).image;

    return (await image.toByteData(format: ImageByteFormat.png))!.buffer.asUint8List();
  }
}

extension on ImageProvider {
  Future<ImageInfo> invoke({ImageChunkListener? onChunk}) {
    final imageAvailable = Completer<ImageInfo>();
    final result = resolve(ImageConfiguration.empty);
    result.addListener(
      ImageStreamListener(
        (image, _) => imageAvailable.complete(image),
        onChunk: onChunk,
        onError: imageAvailable.completeError,
      ),
    );
    return imageAvailable.future;
  }
}
