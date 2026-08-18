import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

import '../providers/wallet_provider.dart';
import '../models/types.dart';
import '../constants/card_colors.dart';

class CardTransactionsScreen extends StatefulWidget {
  final String cardId;
  const CardTransactionsScreen({super.key, required this.cardId});

  @override
  State<CardTransactionsScreen> createState() => _CardTransactionsScreenState();
}

class _CardTransactionsScreenState extends State<CardTransactionsScreen> {
  int _selectedFilterIndex = 0;
  final List<String> _filters = ['All', 'Me', 'Parnasha', 'Payment Made'];

  void _showTransactionForm(BuildContext context, {CardTransaction? transaction}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _TransactionForm(cardId: widget.cardId, transaction: transaction),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final wallet = context.watch<WalletProvider>();
    final card = wallet.cards.firstWhere(
      (c) => c.id == widget.cardId,
      orElse: () => CardEntry(
        id: '', type: '', bankName: 'Unknown', holderName: '', cardNumber: '', expiry: '', cvv: '', nickname: '',
      ),
    );
    final cardColorStr = card.color ?? cardColors.first.key;
    final cardColor = cardColors
        .firstWhere((c) => c.key == cardColorStr, orElse: () => cardColors.first)
        .base(context);

    // Fetch and sort transactions
    final txs = wallet.getTransactionsForCard(widget.cardId).toList()
      ..sort((a, b) => DateTime.parse(b.date).compareTo(DateTime.parse(a.date)));

    // Calculate mock summary data for the top card layout
    double spentAmount = 0;
    double meAmount = 0;
    double parnashaAmount = 0;
    for (var tx in txs) {
      if (tx.type == 'debit') {
        spentAmount += tx.amount;
        if (tx.payee?.toLowerCase().contains('parnasha') == true) {
          parnashaAmount += tx.amount;
        } else {
          meAmount += tx.amount;
        }
      }
    }
    double totalDue = spentAmount; // Mock total due
    double amountKept = 25891.00; // Mock amount kept

    // Group transactions by date
    final Map<String, List<CardTransaction>> groupedTxs = {};
    for (var tx in txs) {
      final date = DateTime.parse(tx.date);
      // Format like "AUG 14, 2026"
      final dateStr = DateFormat('MMM dd, yyyy').format(date).toUpperCase();
      groupedTxs.putIfAbsent(dateStr, () => []).add(tx);
    }

    final formatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          card.bankName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () {},
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _buildSummaryCard(theme, totalDue, meAmount, parnashaAmount, spentAmount, amountKept, formatter),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverAppBarDelegate(
              minHeight: 56.0,
              maxHeight: 56.0,
              theme: theme,
              child: _buildFilterChips(theme, cardColor),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 8)),
          if (groupedTxs.isEmpty)
            const SliverFillRemaining(
              child: Center(child: Text('No transactions found.')),
            )
          else
            ...groupedTxs.entries.map((entry) {
              return SliverMainAxisGroup(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                      child: Text(
                        entry.key,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final tx = entry.value[index];
                        return _buildTransactionCard(context, tx, theme, wallet, formatter);
                      },
                      childCount: entry.value.length,
                    ),
                  ),
                ],
              );
            }),
          const SliverToBoxAdapter(child: SizedBox(height: 80)), // Space for FAB
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTransactionForm(context),
        backgroundColor: theme.colorScheme.primaryContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Icon(Icons.add, color: theme.colorScheme.onPrimaryContainer),
      ),
    );
  }

  Widget _buildSummaryCard(
    ThemeData theme,
    double totalDue,
    double meAmount,
    double parnashaAmount,
    double spentAmount,
    double amountKept,
    NumberFormat formatter,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Total due',
                    style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.edit, size: 14, color: theme.colorScheme.onSurfaceVariant),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    formatter.format(totalDue),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.tertiaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, size: 12, color: theme.colorScheme.onTertiaryContainer),
                        const SizedBox(width: 4),
                        Text(
                          '10 Days Until Bill',
                          style: TextStyle(color: theme.colorScheme.onTertiaryContainer, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildBulletPoint(theme, 'Me', meAmount, formatter),
                  const SizedBox(width: 16),
                  _buildBulletPoint(theme, 'Parnasha', parnashaAmount, formatter),
                ],
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Spent amount',
                        style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12),
                      ),
                      Text(
                        formatter.format(spentAmount),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Amount Kept',
                        style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12),
                      ),
                      Text(
                        formatter.format(amountKept),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            top: -24,
            right: -24,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(24),
                  bottomLeft: Radius.circular(16),
                ),
              ),
              child: Text(
                'JULY 13 - AUG 13',
                style: TextStyle(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(ThemeData theme, String label, double amount, NumberFormat formatter) {
    return Row(
      children: [
        Icon(Icons.circle, size: 6, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12),
        ),
        Text(
          formatter.format(amount),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildFilterChips(ThemeData theme, Color activeColor) {
    return Container(
      alignment: Alignment.centerLeft,
      child: SizedBox(
        height: 40,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          itemCount: _filters.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final isSelected = _selectedFilterIndex == index;
            return ChoiceChip(
              label: Text(_filters[index]),
              selected: isSelected,
              onSelected: (val) {
                if (val) setState(() => _selectedFilterIndex = index);
              },
              showCheckmark: false,
              selectedColor: theme.colorScheme.primaryContainer, 
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              labelStyle: TextStyle(
                color: isSelected ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTransactionCard(
    BuildContext context,
    CardTransaction tx,
    ThemeData theme,
    WalletProvider wallet,
    NumberFormat formatter,
  ) {
    final isCredit = tx.type == 'credit';
    final date = DateTime.parse(tx.date);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Dismissible(
        key: Key(tx.id),
        direction: DismissDirection.horizontal,
        background: Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 20),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(Icons.edit, color: theme.colorScheme.onPrimary),
        ),
        secondaryBackground: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: theme.colorScheme.error,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(Icons.delete, color: theme.colorScheme.onError),
        ),
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.startToEnd) {
            _showTransactionForm(context, transaction: tx);
            return false;
          }
          return await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Delete Transaction'),
              content: const Text('Are you sure you want to delete this transaction?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Delete'),
                ),
              ],
            ),
          ) ?? false;
        },
        onDismissed: (direction) {
          if (direction == DismissDirection.endToStart) {
            wallet.deleteTransaction(tx.id);
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isCredit ? theme.colorScheme.tertiaryContainer : theme.colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(12),
              ),
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
              '${tx.payee ?? 'Me'} • ${DateFormat('h:mm a').format(date)}',
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isCredit ? '+' : '-'}${formatter.format(tx.amount)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isCredit ? theme.colorScheme.tertiary : theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Icon(Icons.flag_outlined, size: 16, color: theme.colorScheme.onSurfaceVariant),
              ],
            ),
            onTap: () => _showTransactionForm(context, transaction: tx),
          ),
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
    required this.theme,
  });

  final double minHeight;
  final double maxHeight;
  final Widget child;
  final ThemeData theme;

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => math.max(maxHeight, minHeight);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: theme.colorScheme.surface, // Solid background so it obscures content scrolling behind
      alignment: Alignment.center,
      child: child,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child || theme != oldDelegate.theme;
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
