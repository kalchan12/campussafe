import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/config/env.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Env.init();

  runApp(
    const ProviderScope(
      child: CampusSafeApp(),
    ),
  );
}
