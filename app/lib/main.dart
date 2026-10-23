import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router.dart';
import 'core/theme.dart';

void main() {
  runApp(const ProviderScope(child: ScrollSmartApp()));
}

class ScrollSmartApp extends StatelessWidget {
  const ScrollSmartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Scroll Smart',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      scrollBehavior: const AppScrollBehavior(),
      routerConfig: router,
    );
  }
}
