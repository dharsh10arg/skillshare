import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/api_client.dart';
import 'providers/session_provider.dart';
import 'screens/auth_screen.dart';
import 'screens/shell_screen.dart';

void main() {
  runApp(const SkillSphereApp());
}

class SkillSphereApp extends StatelessWidget {
  const SkillSphereApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => ApiClient()),
        ChangeNotifierProvider(
          create: (context) =>
              SessionProvider(context.read<ApiClient>())..restore(),
        ),
      ],
      child: Consumer<SessionProvider>(
        builder: (context, session, _) {
          return MaterialApp(
            title: 'SkillSphere',
            debugShowCheckedModeBanner: false,
            themeMode: ThemeMode.system,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            home: session.isAuthenticated
                ? const ShellScreen()
                : const AuthScreen(),
          );
        },
      ),
    );
  }
}

class AppTheme {
  static ThemeData light() => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1F8A70),
          brightness: Brightness.light,
        ),
        cardTheme: const CardThemeData(elevation: 0, margin: EdgeInsets.zero),
      );

  static ThemeData dark() => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2BB3A3),
          brightness: Brightness.dark,
        ),
        cardTheme: const CardThemeData(elevation: 0, margin: EdgeInsets.zero),
      );
}
