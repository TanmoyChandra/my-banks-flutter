import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../providers/ui_provider.dart';
import '../providers/wallet_provider.dart';
import '../models/types.dart';
import '../constants/banks.dart';
import '../constants/card_colors.dart';

class CardsSection extends StatelessWidget {
  const CardsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final uiProvider = context.watch<UiProvider>();
    final walletProvider = context.watch<WalletProvider>();
    final cards = walletProvider.cards;
    final transactions = walletProvider.transactions;

    final insets = MediaQuery.of(context).padding;
    final initials = uiProvider.userName.isNotEmpty ? uiProvider.userName[0].toUpperCase() : '?';

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Payment cards',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Manage your payment cards and view transactions.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.brightness == Brightness.dark ? const Color(0xFFA1A1AA) : const Color(0xFF52525B),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                CircleAvatar(
                  radius: 20,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Text(
                    initials,
                    style: TextStyle(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ReorderableListView.builder(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 96, top: 16),
              itemCount: cards.length + 1,
              onReorder: (oldIndex, newIndex) {
                if (oldIndex < cards.length && newIndex < cards.length) {
                  if (newIndex > oldIndex) {
                    newIndex -= 1;
                  }
                  final newCards = List<CardEntry>.from(cards);
                  final item = newCards.removeAt(oldIndex);
                  newCards.insert(newIndex, item);
                  walletProvider.reorderCards(newCards.map((c) => c.id).toList());
                }
              },
              itemBuilder: (context, index) {
                if (index == cards.length) {
                  return _buildAddCardButton(context, key: const ValueKey('add_card_btn'));
                }

                final card = cards[index];
                final cardTxs = transactions.where((t) => t.cardId == card.id);
                final totalDue = cardTxs.fold(0.0, (sum, t) => t.type == 'debit' ? sum + t.amount : sum - t.amount);

                return Padding(
                  key: ValueKey(card.id),
                  padding: const EdgeInsets.only(bottom: 24),
                  child: _BankCard(
                    card: card,
                    totalDue: totalDue,
                    onPress: () {
                      context.push('/main/card-transactions/${card.id}');
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddCardButton(BuildContext context, {required Key key}) {
    final screenW = MediaQuery.of(context).size.width;
    final cardWidth = min(screenW - 32, 420.0);
    final cardHeight = cardWidth * (240 / 380);
    final theme = Theme.of(context);

    return Align(
      key: key,
      alignment: Alignment.center,
      child: GestureDetector(
        onTap: () => context.push('/main/setup-cards'),
        child: Container(
          width: cardWidth,
          height: cardHeight,
          decoration: BoxDecoration(
            color: theme.brightness == Brightness.dark ? const Color(0xFF2A2A2A) : Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.transparent,
                  child: Icon(Icons.add, size: 32, color: theme.colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add new card',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BankCard extends StatefulWidget {
  final CardEntry card;
  final double totalDue;
  final VoidCallback onPress;

  const _BankCard({
    required this.card,
    required this.totalDue,
    required this.onPress,
  });

  @override
  State<_BankCard> createState() => _BankCardState();
}

class _BankCardState extends State<_BankCard> {
  bool _showFull = false;

  String _formatCardNumber(String num) {
    final clean = num.replaceAll(RegExp(r'\D'), '');
    final padded = clean.padRight(16, '0').substring(0, 16);
    return padded.replaceAllMapped(RegExp(r'.{4}'), (m) => '${m[0]}  ').trim();
  }

  String _maskCardNumber(String num) {
    final clean = num.replaceAll(RegExp(r'\D'), '');
    final padded = clean.padRight(16, '0').substring(0, 16);
    final first = padded.substring(0, 4);
    final last = padded.substring(12, 16);
    return '$first  ••••  ••••  $last';
  }

  String _getNetwork() {
    if (widget.card.network != null && widget.card.network!.isNotEmpty) return widget.card.network!;
    final clean = widget.card.cardNumber.replaceAll(RegExp(r'\D'), '');
    if (RegExp(r'^5[1-5]').hasMatch(clean) || RegExp(r'^2[2-7]').hasMatch(clean)) return 'Mastercard';
    if (RegExp(r'^6(?:0|5|22|52|53)').hasMatch(clean)) return 'RuPay';
    return 'Visa';
  }

  Future<void> _copy(String val) async {
    await Clipboard.setData(ClipboardData(text: val.replaceAll(' ', '')));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied to clipboard'), duration: Duration(seconds: 1)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final cardWidth = min(screenW - 32, 420.0);
    final cardHeight = cardWidth * (240 / 380);
    
    final palette = getCardColors(widget.card.color);
    final network = _getNetwork();
    final bank = findBankByName(widget.card.bankName);

    final displayNumber = _showFull ? _formatCardNumber(widget.card.cardNumber) : _maskCardNumber(widget.card.cardNumber);

    return Column(
      children: [
        GestureDetector(
          onTap: () => setState(() => _showFull = !_showFull),
          child: Container(
            width: cardWidth,
            height: cardHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [palette.from, palette.via, palette.to],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black45,
                  blurRadius: 28,
                  offset: Offset(0, 20),
                )
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  // Glows
                  Positioned(
                    top: -80, right: -50,
                    child: Container(
                      width: 200, height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: palette.glow1.withOpacity(0.18),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -70, left: -40,
                    child: Container(
                      width: 160, height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: palette.glow2.withOpacity(0.12),
                      ),
                    ),
                  ),
                  // Content
                  Padding(
                    padding: EdgeInsets.all(cardWidth * 0.06),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Top row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  if (bank != null) ...[
                                    Image.asset(bank.symbol, width: 28, height: 28),
                                    const SizedBox(width: 10),
                                  ],
                                  Flexible(
                                    child: Text(
                                      widget.card.bankName.toUpperCase(),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1.2,
                                        fontSize: cardWidth * 0.038,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Image.asset('assets/taptopay.png', width: 24, height: 24),
                          ],
                        ),
                        // Middle row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 46, height: 36,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(7),
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFFd4af37), Color(0xFFf5d060), Color(0xFFb8860b)],
                                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.25),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.white.withOpacity(0.5)),
                                  ),
                                  child: Text(
                                    '${widget.card.type?.toUpperCase() ?? 'DEBIT'} CARD',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 2,
                                      fontSize: cardWidth * 0.026,
                                    ),
                                  ),
                                )
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('DUE AMOUNT', style: TextStyle(color: Colors.white70, fontSize: cardWidth * 0.02, letterSpacing: 1)),
                                Text(
                                  '₹ ${widget.totalDue.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5,
                                    fontSize: cardWidth * 0.045,
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                        // Number
                        Row(
                          children: [
                            Text(
                              displayNumber,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: cardWidth * 0.058,
                                letterSpacing: cardWidth * 0.012,
                                shadows: const [Shadow(color: Colors.black54, offset: Offset(0, 2), blurRadius: 6)],
                              ),
                            ),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: () => _copy(widget.card.cardNumber),
                              child: Icon(Icons.copy, color: Colors.white60, size: cardWidth * 0.045),
                            )
                          ],
                        ),
                        // Bottom row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('CARD HOLDER', style: TextStyle(color: Colors.white70, fontSize: cardWidth * 0.023, letterSpacing: 1)),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          (widget.card.holderName.isNotEmpty ? widget.card.holderName : 'CARD HOLDER').toUpperCase(),
                                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: cardWidth * 0.034, letterSpacing: 1),
                                          maxLines: 1, overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      GestureDetector(
                                        onTap: () => _copy(widget.card.holderName),
                                        child: Icon(Icons.copy, color: Colors.white60, size: cardWidth * 0.045),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('EXPIRES', style: TextStyle(color: Colors.white70, fontSize: cardWidth * 0.023, letterSpacing: 1)),
                                  Row(
                                    children: [
                                      Text(
                                        widget.card.expiry.isNotEmpty ? widget.card.expiry : 'MM/YY',
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: cardWidth * 0.034, letterSpacing: 1),
                                      ),
                                      const SizedBox(width: 6),
                                      GestureDetector(
                                        onTap: () => _copy(widget.card.expiry),
                                        child: Icon(Icons.copy, color: Colors.white60, size: cardWidth * 0.045),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Align(
                                alignment: Alignment.bottomRight,
                                child: network == 'Visa' ? Image.asset('assets/Visa.png', height: cardWidth * 0.09) :
                                       network == 'Mastercard' ? Image.asset('assets/mastercard.png', height: cardWidth * 0.09) :
                                       network == 'RuPay' ? Image.asset('assets/rupay.png', height: cardWidth * 0.09) : const SizedBox(),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: cardWidth,
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: FilledButton.icon(
                  onPressed: () => _copy(widget.card.cvv),
                  icon: const Icon(Icons.copy, size: 18),
                  label: const Text('CVV'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                    foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  onPressed: widget.onPress,
                  icon: const Icon(Icons.history, size: 18),
                  label: const Text('Transactions'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                    foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
