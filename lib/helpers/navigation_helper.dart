import 'package:flutter/widgets.dart';

class NavigationHelper {
  static Future<bool> maybePop<T extends Object?>(
    BuildContext context, {
    T? result,
  }) {
    return Navigator.of(context).maybePop(result);
  }

  static void pop<T extends Object?>(
    BuildContext context, {
    T? result,
  }) {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop(result);
    }
  }
}
