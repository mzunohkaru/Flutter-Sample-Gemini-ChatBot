import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'ui/homePage.dart';

class App extends HookWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}