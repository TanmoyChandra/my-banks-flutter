import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../providers/wallet_provider.dart';
import '../../models/types.dart';

import '../../constants/card_colors.dart';
import '../../widgets/bank_picker.dart';

class SetupCardsScreen extends StatefulWidget {
  const SetupCardsScreen({super.key});

  @override
  State<SetupCardsScreen> createState() => _SetupCardsScreenState();
}

class _SetupCardsScreenState extends State<SetupCardsScreen> {
  bool _showForm = false;
  String? _editId;

  String _type = 'Debit';
  String _network = 'Visa';
  String _bankName = '';
  final TextEditingController _holderNameController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  String _color = cardColors.first.key;
  final TextEditingController _billingDateController = TextEditingController();
  final TextEditingController _dueDaysController = TextEditingController();

  @override
  void dispose() {
    _holderNameController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _nicknameController.dispose();
    _billingDateController.dispose();
    _dueDaysController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _type = 'Debit';
    _network = 'Visa';
    _bankName = '';
    _holderNameController.clear();
    _cardNumberController.clear();
    _expiryController.clear();
    _cvvController.clear();
    _nicknameController.clear();
    _color = cardColors.first.key;
    _billingDateController.clear();
    _dueDaysController.clear();
    setState(() {
      _showForm = false;
      _editId = null;
    });
  }

  void _handleEdit(CardEntry card) {
    _type = card.type;
    _network = card.network ?? 'Visa';
    _bankName = card.bankName;
    _holderNameController.text = card.holderName;
    _cardNumberController.text = card.cardNumber;
    _expiryController.text = card.expiry;
    _cvvController.text = card.cvv;
    _nicknameController.text = card.nickname;
    _color = card.color ?? cardColors.first.key;
    _billingDateController.text = card.billingDate?.toString() ?? '';
    _dueDaysController.text = card.dueDaysAfterBilling?.toString() ?? '';
    setState(() {
      _editId = card.id;
      _showForm = true;
    });
  }

  void _handleSave(WalletProvider provider) {
    if (_bankName.trim().isEmpty ||
        _holderNameController.text.trim().isEmpty ||
        _cardNumberController.text.length < 12) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please provide valid bank name, card holder name, and card number.',
          ),
        ),
      );
      return;
    }

    final newCard = CardEntry(
      id: _editId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      type: _type,
      network: _network,
      bankName: _bankName,
      holderName: _holderNameController.text.trim(),
      cardNumber: _cardNumberController.text.trim(),
      expiry: _expiryController.text.trim(),
      cvv: _cvvController.text.trim(),
      nickname: _nicknameController.text.trim(),
      color: _color,
      billingDate: _type == 'Credit' && _billingDateController.text.isNotEmpty
          ? int.tryParse(_billingDateController.text)
          : null,
      dueDaysAfterBilling:
          _type == 'Credit' && _dueDaysController.text.isNotEmpty
          ? int.tryParse(_dueDaysController.text)
          : null,
    );

    if (_editId != null) {
      provider.updateCard(_editId!, newCard);
    } else {
      provider.addCard(newCard);
    }
    _resetForm();
  }

  void _showBankPicker() {
    BankPicker.show(context, onSelect: (name) {
      setState(() => _bankName = name);
    });
  }

  Widget _buildNetworkBtn(String key, String label, String logoPath) {
    final theme = Theme.of(context);
    final isSelected = _network == key;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _network = key),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline,
              width: 1.5,
            ),
            color: isSelected
                ? theme.colorScheme.surfaceContainer
                : Colors.transparent,
          ),
          child: Column(
            children: [
              Image.asset(logoPath, width: 52, height: 24, fit: BoxFit.contain),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isSelected
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final walletProvider = context.watch<WalletProvider>();
    final cards = walletProvider.cards;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Setup Debit/Credit Card',
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
                      _editId != null ? 'Edit Card' : 'New Card',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: 'Debit', label: Text('Debit')),
                        ButtonSegment(value: 'Credit', label: Text('Credit')),
                      ],
                      selected: {_type},
                      onSelectionChanged: (set) =>
                          setState(() => _type = set.first),
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
                    Text(
                      'Card Network',
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildNetworkBtn('Visa', 'Visa', 'assets/Visa.png'),
                        const SizedBox(width: 10),
                        _buildNetworkBtn(
                          'Mastercard',
                          'Mastercard',
                          'assets/mastercard.png',
                        ),
                        const SizedBox(width: 10),
                        _buildNetworkBtn('RuPay', 'RuPay', 'assets/rupay.png'),
                      ],
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
                      controller: _holderNameController,
                      decoration: const InputDecoration(
                        labelText: 'Card Holder Name *',
                      ),
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _cardNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Card Number *',
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 19,
                      style: const TextStyle(fontSize: 14),
                      onChanged: (val) {
                        final clean = val
                            .replaceAll(RegExp(r'\D'), '')
                            .substring(0, 16);
                        final formatted = clean
                            .replaceAllMapped(
                              RegExp(r'.{4}'),
                              (m) => '${m[0]} ',
                            )
                            .trim();
                        if (formatted != _cardNumberController.text) {
                          _cardNumberController.value = TextEditingValue(
                            text: formatted,
                            selection: TextSelection.collapsed(
                              offset: formatted.length,
                            ),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _expiryController,
                            decoration: const InputDecoration(
                              labelText: 'Expiry (MM/YY) *',
                            ),
                            keyboardType: TextInputType.number,
                            maxLength: 5,
                            style: const TextStyle(fontSize: 14),
                            onChanged: (val) {
                              String clean = val.replaceAll(RegExp(r'\D'), '');
                              if (clean.length > 2) {
                                clean =
                                    '${clean.substring(0, 2)}/${clean.substring(2, clean.length > 4 ? 4 : clean.length)}';
                              }
                              if (clean != _expiryController.text) {
                                _expiryController.value = TextEditingValue(
                                  text: clean,
                                  selection: TextSelection.collapsed(
                                    offset: clean.length,
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _cvvController,
                            decoration: const InputDecoration(
                              labelText: 'CVV',
                            ),
                            keyboardType: TextInputType.number,
                            maxLength: 4,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _nicknameController,
                      decoration: const InputDecoration(
                        labelText: 'Nickname',
                      ),
                      style: const TextStyle(fontSize: 14),
                    ),
                    if (_type == 'Credit') ...[
                      const SizedBox(height: 12),
                      TextField(
                        controller: _billingDateController,
                        decoration: const InputDecoration(
                          labelText: 'Billing Date (1-31)',
                          hintText: 'e.g. 5',
                        ),
                        keyboardType: TextInputType.number,
                        maxLength: 2,
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _dueDaysController,
                        decoration: const InputDecoration(
                          labelText: 'Due After Billing (Days)',
                          hintText: 'e.g. 15',
                        ),
                        keyboardType: TextInputType.number,
                        maxLength: 3,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
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
                if (cards.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 60, bottom: 20),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor:
                              theme.colorScheme.surfaceContainerHighest,
                          child: Icon(
                            Icons.credit_card,
                            size: 32,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No cards added yet.',
                          style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ...cards.map((card) {
                    return Dismissible(
                      key: Key(card.id),
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
                      onDismissed: (_) => walletProvider.deleteCard(card.id),
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.credit_card, size: 40),
                          title: Text(
                            card.bankName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${card.type} • ${card.cardNumber.length > 4 ? card.cardNumber.substring(card.cardNumber.length - 4) : ''}',
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _handleEdit(card),
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
                            'Add New Card',
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
