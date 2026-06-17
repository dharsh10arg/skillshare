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

/// Application theme configuration using Material 3
class AppTheme {
  // Teal green color for SkillSphere brand
  static const Color _brandColor = Color(0xFF1F8A70);
  static const Color _brandColorLight = Color(0xFF2BB3A3);

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _brandColor,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      
      // AppBar styling
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        elevation: 2,
        centerTitle: false,
      ),

      // Card styling
      cardTheme: CardThemeData(
        elevation: 1,
        margin: EdgeInsets.zero,
        color: colorScheme.surface,
      ),

      // Button styling
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),

      // Text field styling
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        filled: true,
        fillColor: colorScheme.surface,
      ),

      // Chip styling
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerHighest,
        selectedColor: colorScheme.primary,
        labelStyle: const TextStyle(color: Colors.black87),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),

      // Navigation bar styling
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primaryContainer,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: colorScheme.primary);
          }
          return IconThemeData(color: colorScheme.onSurfaceVariant);
        }),
      ),

      // Text theme for better typography
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          letterSpacing: -1.5,
        ),
        displayMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
        headlineSmall: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.5,
        ),
      ),

      // Scaffold background
      scaffoldBackgroundColor: colorScheme.surface,

      // Dialog theme
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surface,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // Snackbar theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colorScheme.surfaceContainerHighest,
        contentTextStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  static ThemeData dark() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _brandColorLight,
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,

      // AppBar styling
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        elevation: 2,
        centerTitle: false,
      ),

      // Card styling
      cardTheme: CardThemeData(
        elevation: 1,
        margin: EdgeInsets.zero,
        color: colorScheme.surface,
      ),

      // Button styling
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),

      // Text field styling
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        filled: true,
        fillColor: colorScheme.surface,
      ),

      // Chip styling
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerHighest,
        selectedColor: colorScheme.primary,
        labelStyle: const TextStyle(color: Colors.white70),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),

      // Navigation bar styling
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primaryContainer,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: colorScheme.primary);
          }
          return IconThemeData(color: colorScheme.onSurfaceVariant);
        }),
      ),

      // Scaffold background
      scaffoldBackgroundColor: colorScheme.surface,

      // Dialog theme
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surface,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // Snackbar theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colorScheme.surfaceContainerHighest,
        contentTextStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
