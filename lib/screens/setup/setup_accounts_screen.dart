import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../providers/wallet_provider.dart';
import '../../models/types.dart';
import '../../constants/banks.dart';
import '../../constants/card_colors.dart';
import '../../widgets/bank_picker.dart';

class SetupAccountsScreen extends StatefulWidget {
  const SetupAccountsScreen({super.key});

  @override
  State<SetupAccountsScreen> createState() => _SetupAccountsScreenState();
}

class _SetupAccountsScreenState extends State<SetupAccountsScreen> {
  bool _showForm = false;
  String? _editId;

  String _accountType = 'Savings';
  String _bankName = '';
  final TextEditingController _accountHolderController =
      TextEditingController();
  final TextEditingController _accountNumberController =
      TextEditingController();
  final TextEditingController _ifscController = TextEditingController();
  final TextEditingController _branchNameController = TextEditingController();
  String _color = cardColors.first.key;

  @override
  void dispose() {
    _accountHolderController.dispose();
    _accountNumberController.dispose();
    _ifscController.dispose();
    _branchNameController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _accountType = 'Savings';
    _bankName = '';
    _accountHolderController.clear();
    _accountNumberController.clear();
    _ifscController.clear();
    _branchNameController.clear();
    _color = cardColors.first.key;
    setState(() {
      _showForm = false;
      _editId = null;
    });
  }

  void _handleEdit(BankAccount account) {
    _accountType = account.accountType;
    _bankName = account.bankName;
    _accountHolderController.text = account.accountHolder;
    _accountNumberController.text = account.accountNumber;
    _ifscController.text = account.ifsc;
    _branchNameController.text = account.branchName;
    _color = account.color ?? cardColors.first.key;
    setState(() {
      _editId = account.id;
      _showForm = true;
    });
  }

  void _handleSave(WalletProvider provider) {
    if (_bankName.trim().isEmpty ||
        _accountHolderController.text.trim().isEmpty ||
        _accountNumberController.text.trim().isEmpty ||
        _ifscController.text.trim().length < 11) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please fill all required fields and ensure IFSC is 11 characters.',
          ),
        ),
      );
      return;
    }

    final newAccount = BankAccount(
      id: _editId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      bankName: _bankName,
      accountHolder: _accountHolderController.text.trim(),
      accountNumber: _accountNumberController.text.trim(),
      ifsc: _ifscController.text.trim().toUpperCase(),
      accountType: _accountType,
      branchName: _branchNameController.text.trim(),
      color: _color,
    );

    if (_editId != null) {
      provider.updateAccount(_editId!, newAccount);
    } else {
      provider.addAccount(newAccount);
    }
    _resetForm();
  }

  void _showBankPicker() {
    BankPicker.show(context, onSelect: (name) {
      setState(() => _bankName = name);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final walletProvider = context.watch<WalletProvider>();
    final accounts = walletProvider.accounts;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Setup Bank Account',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        backgroundColor: theme.colorScheme.surface,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: _showForm
          ? SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _editId != null ? 'Edit Account' : 'New Account',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: 'Savings', label: Text('Savings')),
                        ButtonSegment(value: 'Current', label: Text('Current')),
                        ButtonSegment(value: 'Loan', label: Text('Loan')),
                      ],
                      selected: {_accountType},
                      onSelectionChanged: (set) =>
                          setState(() => _accountType = set.first),
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.resolveWith<Color>(
                          (states) {
                            if (states.contains(WidgetState.selected)) {
                              return theme.colorScheme.primaryContainer;
                            }
                            return Colors.transparent;
                          },
                        ),
                        foregroundColor: WidgetStateProperty.resolveWith<Color>(
                          (states) {
                            if (states.contains(WidgetState.selected)) {
                              return theme.colorScheme.onPrimaryContainer;
                            }
                            return theme.colorScheme.onSurface;
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: _showBankPicker,
                      child: AbsorbPointer(
                        child: TextField(
                          controller: TextEditingController(text: _bankName),
                          decoration: const InputDecoration(
                            labelText: 'Bank Name *',
                            suffixIcon: Icon(Icons.keyboard_arrow_down),
                          ),
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _accountHolderController,
                      decoration: const InputDecoration(
                        labelText: 'Account Holder Name *',
                      ),
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _accountNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Account Number *',
                      ),
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _ifscController,
                      decoration: const InputDecoration(
                        labelText: 'IFSC Code *',
                      ),
                      textCapitalization: TextCapitalization.characters,
                      maxLength: 11,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _branchNameController,
                      decoration: const InputDecoration(
                        labelText: 'Branch Name',
                      ),
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Card Color',
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 50,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: cardColors.length,
                        itemBuilder: (context, index) {
                          final c = cardColors[index];
                          final isSelected = c.key == _color;
                          return GestureDetector(
                            onTap: () => setState(() => _color = c.key),
                            child: Container(
                              margin: const EdgeInsets.only(right: 12),
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: c.base(context),
                                border: Border.all(
                                  color: isSelected
                                      ? theme.colorScheme.onSurface
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: isSelected
                                  ? Icon(
                                      Icons.check,
                                      color: c.onBase(context),
                                      size: 20,
                                    )
                                  : null,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _resetForm,
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: () => _handleSave(walletProvider),
                            child: Text(_editId != null ? 'Update' : 'Save'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (accounts.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 60, bottom: 20),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor:
                              theme.colorScheme.surfaceContainerHighest,
                          child: Icon(
                            Icons.account_balance,
                            size: 32,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No accounts added yet.',
                          style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ...accounts.map((account) {
                    final bank = findBankByName(account.bankName);
                    return Dismissible(
                      key: Key(account.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        color: theme.colorScheme.error,
                        child: Icon(
                          Icons.delete,
                          color: theme.colorScheme.onError,
                        ),
                      ),
                      onDismissed: (_) =>
                          walletProvider.deleteAccount(account.id),
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: bank != null
                              ? Image.asset(bank.symbol, width: 40, height: 40)
                              : const Icon(Icons.account_balance, size: 40),
                          title: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  account.bankName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.tertiaryContainer,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  account.accountType.toUpperCase(),
                                  style: TextStyle(
                                    color: theme.colorScheme.onTertiaryContainer,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          subtitle: Text(account.accountNumber),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _handleEdit(account),
                          ),
                        ),
                      ),
                    );
                  }),
                const SizedBox(height: 20),
                Card(
                  child: InkWell(
                    onTap: () => setState(() => _showForm = true),
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      height: 80,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_circle,
                            size: 36,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Add Bank Account',
                            style: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
