import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/ui_provider.dart';
import 'providers/wallet_provider.dart';
import 'theme/app_theme.dart';
import 'navigation/app_router.dart';
import 'package:dynamic_color/dynamic_color.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UiProvider()),
        ChangeNotifierProvider(create: (_) => WalletProvider()),
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
