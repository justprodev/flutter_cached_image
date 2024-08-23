// Created by alex@justprodev.com on 24.08.2024.

import 'dart:io' show HttpException;

import 'package:flutter/material.dart';

import 'types.dart';

defaultErrorListener(Object error) {
  // skip 404 errors and etc
  // remove this if you want to see all errors
  if (error is! HttpException) {
    debugPrint('CachedImage: $error');
  }
}

@pragma('vm:prefer-inline')
Widget defaultPlaceholder(BuildContext context, String url, WidgetParameters widgetParameters) {
  return ClipRRect(
    clipBehavior: Clip.hardEdge,
    borderRadius: widgetParameters.$1 ?? const BorderRadius.all(Radius.circular(4)),
    child: ColoredBox(
      color: Colors.white,
      child: SizedBox(width: widgetParameters.$2, height: widgetParameters.$3),
    ),
  );
}

Widget defaultErrorWidget(BuildContext context, String url, Object error, [WidgetParameters? widgetParameters]) {
  if(widgetParameters != null) {
    return defaultPlaceholder(context, url, widgetParameters);
  } else {
    return const SizedBox();
  }
}