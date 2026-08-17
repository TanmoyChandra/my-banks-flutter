import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/wallet_provider.dart';
import '../models/types.dart';
import '../constants/card_colors.dart';

class CardTransactionsScreen extends StatefulWidget {
  final String cardId;
  const CardTransactionsScreen({super.key, required this.cardId});

  @override
  State<CardTransactionsScreen> createState() => _CardTransactionsScreenState();
}

class _CardTransactionsScreenState extends State<CardTransactionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final wallet = context.watch<WalletProvider>();
    final card = wallet.cards.firstWhere(
      (c) => c.id == widget.cardId,
      orElse: () => CardEntry(
        id: '',
        type: '',
        bankName: 'Unknown',
        holderName: '',
        cardNumber: '',
        expiry: '',
        cvv: '',
        nickname: '',
      ),
    );
    final cardColorStr = card.color ?? cardColors.first.key;
    final cardColor = cardColors
        .firstWhere(
          (c) => c.key == cardColorStr,
          orElse: () => cardColors.first,
        )
        .base(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              card.bankName,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
            ),
            Text(
              '${card.type} • ${card.cardNumber.length > 4 ? card.cardNumber.substring(card.cardNumber.length - 4) : ''}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        backgroundColor: cardColor.withValues(alpha: 0.1),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: cardColor,
          labelColor: theme.colorScheme.onSurface,
          tabs: const [
            Tab(text: 'Transactions'),
            Tab(text: 'Billing Cycles'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _TransactionsTab(cardId: widget.cardId, cardColor: cardColor),
          _BillingCyclesTab(cardId: widget.cardId, cardColor: cardColor),
        ],
      ),
    );
  }
}

class _TransactionsTab extends StatefulWidget {
  final String cardId;
  final Color cardColor;
  const _TransactionsTab({required this.cardId, required this.cardColor});

  @override
  State<_TransactionsTab> createState() => _TransactionsTabState();
}

class _TransactionsTabState extends State<_TransactionsTab> {
  void _showTransactionForm(
    BuildContext context, {
    CardTransaction? transaction,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) =>
          _TransactionForm(cardId: widget.cardId, transaction: transaction),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final wallet = context.watch<WalletProvider>();
    final txs = wallet.getTransactionsForCard(widget.cardId).toList()
      ..sort(
        (a, b) => DateTime.parse(b.date).compareTo(DateTime.parse(a.date)),
      );

    final formatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

    return Scaffold(
      body: txs.isEmpty
          ? const Center(child: Text('No transactions found.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: txs.length,
              itemBuilder: (context, index) {
                final tx = txs[index];
                final isCredit = tx.type == 'credit';
                final date = DateTime.parse(tx.date);
                return Dismissible(
                  key: Key(tx.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    color: theme.colorScheme.error,
                    child: Icon(Icons.delete, color: theme.colorScheme.onError),
                  ),
                  onDismissed: (_) => wallet.deleteTransaction(tx.id),
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isCredit
                            ? theme.colorScheme.tertiaryContainer
                            : theme.colorScheme.errorContainer,
                        child: Icon(
                          isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                          color: isCredit ? theme.colorScheme.onTertiaryContainer : theme.colorScheme.onErrorContainer,
                        ),
                      ),
                      title: Text(
                        tx.description,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '${tx.payee ?? 'N/A'} • ${DateFormat('dd MMM yyyy').format(date)}',
                      ),
                      trailing: Text(
                        '${isCredit ? '+' : '-'}${formatter.format(tx.amount)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isCredit
                              ? theme.colorScheme.tertiary
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                      onTap: () =>
                          _showTransactionForm(context, transaction: tx),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTransactionForm(context),
        backgroundColor: widget.cardColor,
        child: Icon(Icons.add, color: theme.colorScheme.onPrimary),
      ),
    );
  }
}

class _TransactionForm extends StatefulWidget {
  final String cardId;
  final CardTransaction? transaction;
  const _TransactionForm({required this.cardId, this.transaction});

  @override
  State<_TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<_TransactionForm> {
  late TextEditingController _descController;
  late TextEditingController _amountController;
  late TextEditingController _payeeController;
  late String _type;
  late DateTime _selectedDate;
  String? _billingCycleId;

  @override
  void initState() {
    super.initState();
    _descController = TextEditingController(
      text: widget.transaction?.description ?? '',
    );
    _amountController = TextEditingController(
      text: widget.transaction?.amount.toString() ?? '',
    );
    _payeeController = TextEditingController(
      text: widget.transaction?.payee ?? '',
    );
    _type = widget.transaction?.type ?? 'debit';
    _selectedDate = widget.transaction != null
        ? DateTime.parse(widget.transaction!.date)
        : DateTime.now();
    _billingCycleId = widget.transaction?.billingCycleId;
  }

  @override
  void dispose() {
    _descController.dispose();
    _amountController.dispose();
    _payeeController.dispose();
    super.dispose();
  }

  void _save(WalletProvider wallet) {
    if (_descController.text.isEmpty || _amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter description and amount')),
      );
      return;
    }

    final tx = CardTransaction(
      id: widget.transaction?.id ?? '',
      cardId: widget.cardId,
      type: _type,
      amount: double.tryParse(_amountController.text) ?? 0.0,
      description: _descController.text,
      date: _selectedDate.toIso8601String(),
      payee: _payeeController.text.isEmpty ? null : _payeeController.text,
      billingCycleId: _billingCycleId,
    );

    if (widget.transaction != null) {
      wallet.updateTransaction(tx.id, tx);
    } else {
      wallet.addTransaction(tx);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<WalletProvider>();
    final cycles = wallet.billingCycles
        .where((b) => b.cardId == widget.cardId)
        .toList();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.transaction != null ? 'Edit Transaction' : 'New Transaction',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
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
            controller: _descController,
            decoration: const InputDecoration(
              labelText: 'Description',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _amountController,
            decoration: const InputDecoration(
              labelText: 'Amount',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _payeeController,
            decoration: const InputDecoration(
              labelText: 'Payee / Merchant',
            ),
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
          const SizedBox(height: 12),
          if (cycles.isNotEmpty)
            DropdownButtonFormField<String>(
              initialValue: _billingCycleId,
              decoration: const InputDecoration(
                labelText: 'Billing Cycle',
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('None')),
                ...cycles.map(
                  (c) => DropdownMenuItem(value: c.id, child: Text(c.name)),
                ),
              ],
              onChanged: (v) => setState(() => _billingCycleId = v),
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
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _BillingCyclesTab extends StatelessWidget {
  final String cardId;
  final Color cardColor;
  const _BillingCyclesTab({required this.cardId, required this.cardColor});

  void _showCycleForm(BuildContext context, WalletProvider wallet) {
    String name = '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Billing Cycle'),
        content: TextField(
          decoration: const InputDecoration(
            labelText: 'Cycle Name (e.g. Sep 2024)',
          ),
          onChanged: (v) => name = v,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (name.isNotEmpty) {
                wallet.addBillingCycle(
                  BillingCycle(
                    id: '',
                    cardId: cardId,
                    name: name,
                    startDate: DateTime.now().toIso8601String(),
                    isClosed: false,
                  ),
                );
              }
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final wallet = context.watch<WalletProvider>();
    final cycles = wallet.billingCycles
        .where((b) => b.cardId == cardId)
        .toList();

    return Scaffold(
      body: cycles.isEmpty
          ? const Center(child: Text('No billing cycles found.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: cycles.length,
              itemBuilder: (context, index) {
                final cycle = cycles[index];
                return Dismissible(
                  key: Key(cycle.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    color: theme.colorScheme.error,
                    child: Icon(Icons.delete, color: theme.colorScheme.onError),
                  ),
                  onDismissed: (_) => wallet.deleteBillingCycle(cycle.id),
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.receipt)),
                      title: Text(
                        cycle.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(cycle.isClosed ? 'Closed' : 'Open'),
                      trailing: Switch(
                        value: cycle.isClosed,
                        onChanged: (v) {
                          wallet.updateBillingCycle(
                            cycle.id,
                            BillingCycle(
                              id: cycle.id,
                              cardId: cycle.cardId,
                              name: cycle.name,
                              startDate: cycle.startDate,
                              billingDate: cycle.billingDate,
                              isClosed: v,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCycleForm(context, wallet),
        backgroundColor: cardColor,
        child: Icon(Icons.add, color: theme.colorScheme.onPrimary),
      ),
    );
  }
}
