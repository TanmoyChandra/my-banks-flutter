import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';

import '../providers/ui_provider.dart';
import '../providers/wallet_provider.dart';
import '../models/types.dart';
import '../constants/banks.dart';
import '../constants/card_colors.dart';

class BankAccountsSection extends StatelessWidget {
  const BankAccountsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final uiProvider = context.watch<UiProvider>();
    final walletProvider = context.watch<WalletProvider>();
    final accounts = walletProvider.accounts;
    final initials = uiProvider.userName.isNotEmpty
        ? uiProvider.userName[0].toUpperCase()
        : '?';

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
                        'Bank accounts',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Keep IFSC and account details easy to find.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                CircleAvatar(
                  radius: 20,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  backgroundImage: uiProvider.userImage != null
                      ? FileImage(File(uiProvider.userImage!))
                      : null,
                  child: uiProvider.userImage == null
                      ? Text(
                          initials,
                          style: TextStyle(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w700,
                          ),
                        )
                      : null,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 96, top: 16),
              itemCount: accounts.length + 1,
              itemBuilder: (context, index) {
                if (index == accounts.length) {
                  return Card(
                    child: InkWell(
                      onTap: () => context.push('/main/setup-accounts'),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        height: 120,
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: Colors.transparent,
                              child: Icon(
                                Icons.add,
                                size: 32,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Add bank account',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return _AccountItem(account: accounts[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountItem extends StatefulWidget {
  final BankAccount account;

  const _AccountItem({required this.account});

  @override
  State<_AccountItem> createState() => _AccountItemState();
}

class _AccountItemState extends State<_AccountItem>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;

  Future<void> _handleCopy(String text) async {
    if (text.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Copied to clipboard'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  Future<void> _handleShare() async {
    final message =
        'Bank Account Details\nBank: ${widget.account.bankName}\nHolder: ${widget.account.accountHolder}\nA/C: ${widget.account.accountNumber}\nIFSC: ${widget.account.ifsc}\nType: ${widget.account.accountType}\nBranch: ${widget.account.branchName}';
    try {
      await Share.share(message);
    } catch (e) {
      //
    }
  }

  String _formatAccountNumber(String num) {
    return num.replaceAllMapped(RegExp(r'.{4}'), (m) => '${m[0]} ').trim();
  }

  @override
  Widget build(BuildContext context) {
    final bank = findBankByName(widget.account.bankName);
    final palette = getCardColors(widget.account.color);
    final cardBg = palette.base(context);
    final textCol = palette.onBase(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GestureDetector(
        onTap: () => setState(() => _expanded = !_expanded),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.all(20),
          child: Stack(
            children: [
              Positioned(
                right: -35,
                top: -35,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: textCol.withValues(alpha: 0.07),
                  ),
                ),
              ),
              Positioned(
                right: 50,
                top: 15,
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: textCol.withValues(alpha: 0.05),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: textCol.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        margin: const EdgeInsets.only(right: 12),
                        child: bank != null
                            ? Image.asset(
                                bank.symbol,
                                width: 28,
                                height: 28,
                                fit: BoxFit.contain,
                              )
                            : Text(
                                widget.account.bankName
                                    .substring(0, 2)
                                    .toUpperCase(),
                                style: TextStyle(
                                  color: textCol,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14,
                                ),
                              ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.account.bankName,
                              style: TextStyle(
                                color: textCol,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: textCol.withValues(alpha: 0.25),
                                border: Border.all(
                                  color: textCol.withValues(alpha: 0.5),
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                '${widget.account.accountType.toUpperCase()} ACCOUNT',
                                style: TextStyle(
                                  color: textCol,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 10,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.share_outlined),
                        color: textCol.withValues(alpha: 0.54),
                        onPressed: _handleShare,
                      ),
                    ],
                  ),

                  AnimatedCrossFade(
                    duration: const Duration(milliseconds: 320),
                    crossFadeState: _expanded
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    firstChild: Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Account Number',
                            style: TextStyle(
                              color: textCol.withValues(alpha: 0.54),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            _formatAccountNumber(widget.account.accountNumber),
                            style: TextStyle(
                              color: textCol,
                              fontSize: 19,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    secondChild: Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 1,
                            color: textCol.withValues(alpha: 0.12),
                            margin: const EdgeInsets.only(bottom: 16),
                          ),
                          _buildInfoRow(
                            'ACCOUNT HOLDER',
                            widget.account.accountHolder,
                            () => _handleCopy(widget.account.accountHolder),
                            textCol,
                          ),
                          _buildInfoRow(
                            'ACCOUNT NUMBER',
                            _formatAccountNumber(widget.account.accountNumber),
                            () => _handleCopy(widget.account.accountNumber),
                            textCol,
                          ),
                          _buildInfoRow(
                            'IFSC CODE',
                            widget.account.ifsc.toUpperCase(),
                            () => _handleCopy(widget.account.ifsc),
                            textCol,
                          ),
                          _buildInfoRow(
                            'BRANCH',
                            widget.account.branchName,
                            () => _handleCopy(widget.account.branchName),
                            textCol,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, VoidCallback onCopy, Color textCol) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onCopy,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: textCol.withValues(alpha: 0.54),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value.isNotEmpty ? value : 'Not provided',
              style: TextStyle(
                color: textCol,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
