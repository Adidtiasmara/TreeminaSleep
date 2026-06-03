import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'pages/login_page.dart';
import 'pages/main_page.dart';
import 'providers/sleep_provider.dart';
import 'providers/theme_provider.dart';
import 'services/notification_service.dart';
import 'services/storage_service.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock portrait orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize services
  await StorageService.init();
  await NotificationService.init();
  await initializeDateFormatting('id_ID', null);

  runApp(const TreeminaSleepApp());
}

class TreeminaSleepApp extends StatelessWidget {
  const TreeminaSleepApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => SleepProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Treemina Sleep',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: StorageService.isLoggedIn()
                ? const MainPage()
                : const LoginPage(),
          );
        },
      ),
    );
  }
}
