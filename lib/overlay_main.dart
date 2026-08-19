import 'package:flutter/material.dart';
import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'providers/wallet_provider.dart';
import 'models/types.dart';
import 'theme/app_theme.dart';

// Dummy function to prevent tree-shaking
void initOverlay() {}

@pragma('vm:entry-point')
void overlayMain() {
  FloatyOverlayApp.run(
    ChangeNotifierProvider(
      create: (_) => WalletProvider(),
      child: const OverlayContent(),
    ),
    theme: AppTheme.lightTheme(null),
  );
}

class OverlayContent extends StatelessWidget {
  const OverlayContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const FloatySimplePanel(
      title: 'Quick Add Transaction',
      child: QuickAddTransactionForm(),
    );
  }
}

class QuickAddTransactionForm extends StatefulWidget {
  const QuickAddTransactionForm({super.key});

  @override
  State<QuickAddTransactionForm> createState() => _QuickAddTransactionFormState();
}

class _QuickAddTransactionFormState extends State<QuickAddTransactionForm> {
  final _amountController = TextEditingController();
  String _type = 'debit';
  String? _selectedCardId;
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _save(WalletProvider wallet) {
    if (_amountController.text.isEmpty || _selectedCardId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    final tx = CardTransaction(
      id: '',
      cardId: _selectedCardId!,
      type: _type,
      amount: double.tryParse(_amountController.text) ?? 0.0,
      description: 'Quick Add',
      date: _selectedDate.toIso8601String(),
    );

    wallet.addTransaction(tx);
    
    // Notify main app to reload from SharedPreferences
    FloatyChatheads.shareData('reload_wallet');
    
    // Close the overlay panel
    FloatyChatheads.closeChatHead();
  }

  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<WalletProvider>();
    final cards = wallet.cards;

    if (cards.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('No cards available. Please add a card in the app first.'),
      );
    }

    // Default to first card if none selected
    _selectedCardId ??= cards.first.id;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            initialValue: _selectedCardId,
            decoration: const InputDecoration(labelText: 'Card'),
            items: cards.map((c) => DropdownMenuItem(
              value: c.id,
              child: Text(c.bankName),
            )).toList(),
            onChanged: (val) => setState(() => _selectedCardId = val),
          ),
          const SizedBox(height: 12),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'debit', label: Text('Debit')),
              ButtonSegment(value: 'credit', label: Text('Credit')),
            ],
            selected: {_type},
            onSelectionChanged: (set) => setState(() => _type = set.first),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _amountController,
            decoration: const InputDecoration(labelText: 'Amount'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 12),
          ListTile(
            title: const Text('Date'),
            subtitle: Text(DateFormat('dd MMM yyyy').format(_selectedDate)),
            trailing: const Icon(Icons.calendar_today),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Theme.of(context).colorScheme.outline),
            ),
            onTap: () async {
              final d = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (d != null) setState(() => _selectedDate = d);
            },
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton(
              onPressed: () => _save(wallet),
              child: const Text('Save'),
            ),
          ),
        ],
      ),
    );
  }
}
