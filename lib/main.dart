import 'package:flutter/material.dart';
import 'features/navigation/pages/app_shell.dart';
import 'core/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Deli4Route',
    theme: buildAppTheme(),
    home: const AppShell(),
  );
}
