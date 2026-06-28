import 'package:flutter/material.dart';
import 'package:ubuntu_simulate/features/diploma/ui/pages/diploma_page.dart';
import 'package:ubuntu_simulate/features/monitor/ui/pages/monitor_page.dart';
import 'package:smart_watch/smart_watch.dart' as watch;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  ErrorWidget.builder = (details) => Center(
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        'Component Error:\n${details.exception}',
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.redAccent, fontSize: 12),
      ),
    ),
  );

  try {
    await watch.init(); 
  } catch (e) {
    debugPrint('Watch initialization failed: $e');
  }

  runApp(const MyApp());
}

enum AppView { monitor, diploma }

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final viewParam = Uri.base.queryParameters['view']?.toLowerCase();
    final appView = AppView.values.firstWhere(
      (e) => e.name == viewParam,
      orElse: () => AppView.monitor,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Living Portfolio',
      theme: _buildTheme(),
      home: Scaffold(
        backgroundColor: Colors.transparent,
        body: _buildBody(appView),
      ),
    );
  }

  ThemeData _buildTheme() {
    final base = ThemeData.dark();
    return base.copyWith(
      colorScheme: base.colorScheme.copyWith(primary: const Color(0xFF3584E4)),
      appBarTheme: const AppBarTheme(backgroundColor: Colors.transparent, elevation: 0),
    );
  }

  Widget _buildBody(AppView view) {
    return switch (view) {
      AppView.monitor => const Monitor(),
      AppView.diploma => const Diploma(),
    };
  }
}
