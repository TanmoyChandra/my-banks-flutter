import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/ui_provider.dart';
import '../screens/onboarding_screen.dart';

import '../screens/card_transactions_screen.dart';
import '../screens/main_screen.dart';
import '../screens/setup/setup_qr_screen.dart';
import '../screens/setup/setup_cards_screen.dart';
import '../screens/setup/setup_accounts_screen.dart';
import '../screens/setup/setup_merchant_qr_screen.dart';
import '../screens/setup/setup_backup_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static GoRouter getRouter(UiProvider uiProvider) {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: uiProvider.hasCompletedOnboarding ? '/main' : '/onboarding',
      refreshListenable: uiProvider,
      redirect: (context, state) {
        final hasCompleted = uiProvider.hasCompletedOnboarding;
        final isGoingToOnboarding = state.uri.toString() == '/onboarding';

        if (!hasCompleted && !isGoingToOnboarding) return '/onboarding';
        if (hasCompleted && isGoingToOnboarding) return '/main';
        return null;
      },
      routes: [
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: '/main',
          builder: (context, state) => const MainScreen(),
          routes: [
            GoRoute(
              path: 'card-transactions/:cardId',
              builder: (context, state) {
                final cardId = state.pathParameters['cardId']!;
                return CardTransactionsScreen(cardId: cardId);
              },
            ),
            GoRoute(
              path: 'setup-qr',
              pageBuilder: (context, state) => const MaterialPage(
                fullscreenDialog: true,
                child: SetupQRScreen(),
              ),
            ),
            GoRoute(
              path: 'setup-cards',
              pageBuilder: (context, state) => const MaterialPage(
                fullscreenDialog: true,
                child: SetupCardsScreen(),
              ),
            ),
            GoRoute(
              path: 'setup-accounts',
              pageBuilder: (context, state) => const MaterialPage(
                fullscreenDialog: true,
                child: SetupAccountsScreen(),
              ),
            ),
            GoRoute(
              path: 'setup-merchant-qr',
              pageBuilder: (context, state) => const MaterialPage(
                fullscreenDialog: true,
                child: SetupMerchantQRScreen(),
              ),
            ),
            GoRoute(
              path: 'setup-backup',
              pageBuilder: (context, state) => const MaterialPage(
                fullscreenDialog: true,
                child: SetupBackupScreen(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
