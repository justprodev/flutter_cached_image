// Created by alex@justprodev.com on 23.08.2024.

import 'package:cached_image/cached_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

const fullImageWidth = 1920;
const fullImageHeight = fullImageWidth * defaultImageHeight / defaultImageWidth;
const defaultImageWidth = 300;
const defaultImageHeight = 200;
const spacing = 8.0;

class DemoImagesFeedView extends StatelessWidget {
  final int imageCount;

  const DemoImagesFeedView({
    super.key,
    this.imageCount = 10000,
  });

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);

    final crossAxisCount = (media.size.width / (defaultImageWidth + spacing * 2)).ceil();

    final imageWidth = (media.size.width - (crossAxisCount + 1) * spacing) / crossAxisCount;
    final imageHeight = imageWidth * defaultImageHeight / defaultImageWidth;

    return StatefulBuilder(
      builder: (_, setState) {
        return RefreshIndicator(
          onRefresh: () {
            setState(() {});
            return Future.delayed(const Duration(seconds: 1));
          },
          child: GridView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(spacing),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: spacing,
              crossAxisSpacing: spacing,
              childAspectRatio: defaultImageWidth / defaultImageHeight,
              mainAxisExtent: imageHeight,
            ),
            itemBuilder: (_, index) {
              return InkWell(
                onTap: () => launchUrlString(
                  'https://picsum.photos/seed/$index/$fullImageWidth/${fullImageHeight.ceil()}',
                ),
                child: CachedImage.image(
                  'https://picsum.photos/seed/$index/$defaultImageWidth/$defaultImageHeight',
                  width: imageWidth,
                  height: imageHeight,
                  fit: BoxFit.cover,
                  borderRadius: const BorderRadius.all(Radius.circular(24)),
                ),
              );
            },
            itemCount: imageCount,
            // two screens of images
            cacheExtent: media.size.height * 2,
            addRepaintBoundaries: false,
            addAutomaticKeepAlives: false,
          ),
        );
      },
    );
  }
}
