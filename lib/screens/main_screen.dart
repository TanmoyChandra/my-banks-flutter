import 'package:flutter/material.dart';

// Placeholder imports for tabs
import '../widgets/qr_section.dart';
import '../widgets/cards_section.dart';
import '../widgets/bank_accounts_section.dart';
import '../widgets/calculator_section.dart';
import '../widgets/settings_section.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    const QRSection(),
    const CardsSection(),
    const BankAccountsSection(),
    const CalculatorSection(),
    const SettingsSection(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _SmoothIndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.qr_code_2_outlined),
            selectedIcon: Icon(Icons.qr_code_scanner),
            label: 'QR',
          ),
          NavigationDestination(
            icon: Icon(Icons.credit_card_outlined),
            selectedIcon: Icon(Icons.credit_card),
            label: 'Cards',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_outlined),
            selectedIcon: Icon(Icons.account_balance),
            label: 'Accounts',
          ),
          NavigationDestination(
            icon: Icon(Icons.calculate_outlined),
            selectedIcon: Icon(Icons.calculate),
            label: 'Calculator',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class _SmoothIndexedStack extends StatefulWidget {
  final int index;
  final List<Widget> children;

  const _SmoothIndexedStack({
    required this.index,
    required this.children,
  });

  @override
  State<_SmoothIndexedStack> createState() => _SmoothIndexedStackState();
}

class _SmoothIndexedStackState extends State<_SmoothIndexedStack> {
  int _previousIndex = 0;

  @override
  void didUpdateWidget(_SmoothIndexedStack oldWidget) {
    if (oldWidget.index != widget.index) {
      _previousIndex = oldWidget.index;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: List.generate(widget.children.length, (i) {
        final isCurrent = i == widget.index;
        final isPrevious = i == _previousIndex;
        final isOnStage = isCurrent || isPrevious;

        return IgnorePointer(
          ignoring: !isCurrent,
          child: AnimatedOpacity(
            opacity: isCurrent ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: Offstage(
              offstage: !isOnStage,
              child: TickerMode(
                enabled: isOnStage,
                child: widget.children[i],
              ),
            ),
          ),
        );
      }),
    );
  }
}
