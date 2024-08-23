// Created by alex@justprodev.com on 23.08.2024.

import 'package:cached_image/cached_image.dart';
import 'package:flutter/material.dart';

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
            ),
            itemBuilder: (_, index) {
              return CachedImage.image(
                'https://picsum.photos/seed/$index/$defaultImageWidth/$defaultImageHeight',
                width: imageWidth,
                height: imageHeight,
                fit: BoxFit.cover,
                borderRadius: const BorderRadius.all(Radius.circular(24)),
              );
            },
            itemCount: imageCount,
          ),
        );
      },
    );
  }
}
