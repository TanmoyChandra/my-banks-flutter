import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/ui_provider.dart';
import 'providers/wallet_provider.dart';
import 'theme/app_theme.dart';
import 'navigation/app_router.dart';
import 'package:dynamic_color/dynamic_color.dart';

import 'package:floaty_chatheads/floaty_chatheads.dart';
// ignore: unused_import
import 'overlay_main.dart'; // Ensure overlayMain is compiled

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initOverlay(); // Explicit call to prevent tree shaking
  
  final uiProvider = UiProvider();
  final walletProvider = WalletProvider();

  FloatyChatheads.onData.listen((data) {
    if (data == 'reload_wallet') {
      walletProvider.loadFromPrefs();
    }
  });

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: uiProvider),
        ChangeNotifierProvider.value(value: walletProvider),
      ],
      child: const MyBanksApp(),
    ),
  );
}

class MyBanksApp extends StatelessWidget {
  const MyBanksApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        return Consumer<UiProvider>(
          builder: (context, uiProvider, child) {
            return MaterialApp.router(
              title: 'My Banks',
              theme: AppTheme.lightTheme(lightDynamic),
              darkTheme: AppTheme.darkTheme(darkDynamic),
              themeMode: uiProvider.isDark ? ThemeMode.dark : ThemeMode.light,
              routerConfig: AppRouter.getRouter(uiProvider),
              debugShowCheckedModeBanner: false,
            );
          },
        );
      },
    );
  }
}
