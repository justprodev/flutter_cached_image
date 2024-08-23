// Created by alex@justprodev.com on 23.08.2024.

import 'package:flutter/widgets.dart';

typedef WidgetParameters = (
  BorderRadius? borderRadius,
  double width,
  double height,
);

/// Builder function to create a placeholder widget. The function is called
/// once while the ImageProvider is loading the image.
typedef ExtendedPlaceholderWidgetBuilder = Widget Function(
  BuildContext context,
  String url,
  WidgetParameters widgetParameters,
);

/// Builder function to create a error widget. The function is called
/// when the ImageProvider failed to load the image.
typedef ExtendedErrorWidgetBuilder = Widget Function(
  BuildContext context,
  String url,
  Object error, [
  WidgetParameters? widgetParameters,
]);
