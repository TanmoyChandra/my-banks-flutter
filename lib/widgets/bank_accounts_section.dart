import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../providers/ui_provider.dart';
import '../providers/wallet_provider.dart';
import '../models/types.dart';
import '../constants/banks.dart';


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

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        titleSpacing: 24,
        toolbarHeight: 90,
        title: Column(
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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 24.0),
            child: CircleAvatar(
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
          ),
        ],
      ),
      body: ListView.builder(
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
    );
  }
}

class _AccountItem extends StatefulWidget {
  final BankAccount account;

  const _AccountItem({required this.account});

  @override
  State<_AccountItem> createState() => _AccountItemState();
}

class _AccountItemState extends State<_AccountItem> {
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
    final theme = Theme.of(context);
    final bank = findBankByName(widget.account.bankName);

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest,
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        shape: const Border(),
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.surface,
          child: bank != null
              ? Image.asset(bank.symbol, width: 24, height: 24)
              : Text(
                  widget.account.bankName.substring(0, 2).toUpperCase(),
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
        title: Text(
          widget.account.bankName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${widget.account.accountType.toUpperCase()} • ${_formatAccountNumber(widget.account.accountNumber)}',
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('ACCOUNT HOLDER', widget.account.accountHolder, () => _handleCopy(widget.account.accountHolder), theme),
                _buildInfoRow('ACCOUNT NUMBER', _formatAccountNumber(widget.account.accountNumber), () => _handleCopy(widget.account.accountNumber), theme),
                _buildInfoRow('IFSC CODE', widget.account.ifsc.toUpperCase(), () => _handleCopy(widget.account.ifsc), theme),
                _buildInfoRow('BRANCH', widget.account.branchName, () => _handleCopy(widget.account.branchName), theme),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.tonalIcon(
                    onPressed: _handleShare,
                    icon: const Icon(Icons.share_outlined, size: 18),
                    label: const Text('Share Details'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, VoidCallback onCopy, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onCopy,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value.isNotEmpty ? value : 'Not provided',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.copy, size: 16, color: theme.colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
