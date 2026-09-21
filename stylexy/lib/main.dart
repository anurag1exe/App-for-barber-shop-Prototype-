import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'config/theme.dart';
import 'services/auth_service.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set status bar style
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  // Try to restore session
  await AuthService.instance.loadSession();

  runApp(const StylexyApp());
}

class StylexyApp extends StatelessWidget {
  const StylexyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stylexy',
      debugShowCheckedModeBanner: false,
      theme: StylexyTheme.darkTheme,
      home: AuthService.instance.isLoggedIn
          ? const HomeDashboard()
          : const LoginScreen(),
    );
  }
}
