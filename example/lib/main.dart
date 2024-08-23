import 'package:cached_image/cached_image.dart';
import 'package:example/view/demo_images_feed_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  configureCachedImage();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Demo images feed',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const DemoImagesFeedView(),
    );
  }
}

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
