import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

import '../../providers/wallet_provider.dart';
import '../../providers/ui_provider.dart';
import '../../models/types.dart';

class SetupBackupScreen extends StatefulWidget {
  const SetupBackupScreen({super.key});

  @override
  State<SetupBackupScreen> createState() => _SetupBackupScreenState();
}

class _SetupBackupScreenState extends State<SetupBackupScreen> {
  String _statusMessage = '';
  bool _isError = false;
  Map<String, dynamic>? _pendingPayload;

  Future<void> _handleExport(WalletProvider wallet, UiProvider ui) async {
    setState(() {
      _statusMessage = 'Exporting...';
      _isError = false;
    });

    try {
      final payload = {
        'magic': 'MYBANKS_BACKUP',
        'version': 1,
        'exportedAt': DateTime.now().toIso8601String(),
        'wallet': {
          'upis': wallet.upis.map((e) => e.toJson()).toList(),
          'cards': wallet.cards.map((e) => e.toJson()).toList(),
          'accounts': wallet.accounts.map((e) => e.toJson()).toList(),
          'transactions': wallet.transactions.map((e) => e.toJson()).toList(),
          'merchantQRs': wallet.merchantQRs.map((e) => e.toJson()).toList(),
          'payees': wallet.payees,
        },
        'preferences': {'userName': ui.userName, 'isDark': ui.isDark},
      };

      final String jsonString = jsonEncode(payload);
      final String base64Data = base64Encode(utf8.encode(jsonString));
      const secretKey = "MB_SECURE_STORAGE_KEY_2026";
      final buffer = StringBuffer();
      for (int i = 0; i < base64Data.length; i++) {
        final xored =
            base64Data.codeUnitAt(i) ^
            secretKey.codeUnitAt(i % secretKey.length);
        buffer.write(xored.toRadixString(16).padLeft(2, '0'));
      }
      final finalData = 'MYBANKS_ENCRYPTED_V4::${buffer.toString()}';

      final directory = await getApplicationDocumentsDirectory();
      final dateStr = DateTime.now()
          .toIso8601String()
          .replaceAll(':', '-')
          .split('.')[0];
      final file = File('${directory.path}/mybanks_backup_$dateStr.mbk');
      await file.writeAsString(finalData);

      setState(() {
        _statusMessage = 'Saved successfully. Share to keep it safe.';
        _isError = false;
      });

      await Share.shareXFiles([XFile(file.path)], text: 'MyBanks Backup');
    } catch (e) {
      setState(() {
        _statusMessage = 'Export failed: $e';
        _isError = true;
      });
    }

    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) setState(() => _statusMessage = '');
    });
  }

  Future<void> _handleImport() async {
    setState(() {
      _statusMessage = 'Importing...';
      _isError = false;
    });

    try {
      var result = await FilePicker.pickFiles(type: FileType.any);

      if (result.isNotEmpty && result.first.path != null) {
        File file = File(result.first.path!);
        String contents = await file.readAsString();
        String base64Data = '';
        const secretKey = "MB_SECURE_STORAGE_KEY_2026";

        if (contents.startsWith('MYBANKS_ENCRYPTED_V4::')) {
          final encrypted = contents.replaceAll('MYBANKS_ENCRYPTED_V4::', '');
          final buffer = StringBuffer();
          for (int i = 0; i < encrypted.length; i += 2) {
            final hexByte = int.parse(encrypted.substring(i, i + 2), radix: 16);
            final keyChar = secretKey.codeUnitAt((i ~/ 2) % secretKey.length);
            buffer.writeCharCode(hexByte ^ keyChar);
          }
          base64Data = buffer.toString();
        } else if (contents.startsWith('MYBANKS_ENCRYPTED_V3::')) {
          final encrypted = contents.replaceAll('MYBANKS_ENCRYPTED_V3::', '');
          final buffer = StringBuffer();
          for (int i = 0; i < encrypted.length; i++) {
            final charCode = encrypted.codeUnitAt(i);
            final keyChar = secretKey.codeUnitAt(i % secretKey.length);
            buffer.writeCharCode(charCode ^ keyChar);
          }
          base64Data = buffer.toString();
        } else if (contents.startsWith('MYBANKS_SECURE_V2::')) {
          base64Data = contents.replaceAll('MYBANKS_SECURE_V2::', '');
        } else if (contents.trim().startsWith('{')) {
          base64Data = ''; // Unencrypted JSON
        } else {
          throw Exception('Unsupported or corrupted backup format.');
        }

        String jsonString = contents;
        if (base64Data.isNotEmpty) {
          jsonString = utf8.decode(base64Decode(base64Data));
        }

        final payload = jsonDecode(jsonString);

        if (payload['magic'] != 'MYBANKS_BACKUP') {
          throw Exception('Invalid backup file');
        }

        setState(() {
          _pendingPayload = payload;
          _statusMessage = '';
        });
      } else {
        setState(() {
          _statusMessage = 'Import cancelled';
          _isError = false;
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Import failed: $e';
        _isError = true;
      });
    }

    if (_pendingPayload == null) {
      Future.delayed(const Duration(seconds: 4), () {
        if (mounted) setState(() => _statusMessage = '');
      });
    }
  }

  void _confirmRestore(WalletProvider wallet, UiProvider ui) async {
    if (_pendingPayload == null) return;

    try {
      final pWallet = _pendingPayload!['wallet'];

      // Parse QREntries
      final upis =
          (pWallet['upis'] as List?)
              ?.map((e) => QREntry.fromJson(e))
              .toList() ??
          [];
      final cards =
          (pWallet['cards'] as List?)
              ?.map((e) => CardEntry.fromJson(e))
              .toList() ??
          [];
      final accounts =
          (pWallet['accounts'] as List?)
              ?.map((e) => BankAccount.fromJson(e))
              .toList() ??
          [];
      final transactions =
          (pWallet['transactions'] as List?)
              ?.map((e) => CardTransaction.fromJson(e))
              .toList() ??
          [];
      final merchantQrs =
          (pWallet['merchantQRs'] as List?)
              ?.map((e) => MerchantQR.fromJson(e))
              .toList() ??
          [];
      final payees =
          (pWallet['payees'] as List?)?.cast<String>().toList() ?? ['Me'];

      wallet.setAllState({
        'upis': upis.map((e) => e.toJson()).toList(),
        'cards': cards.map((e) => e.toJson()).toList(),
        'accounts': accounts.map((e) => e.toJson()).toList(),
        'transactions': transactions.map((e) => e.toJson()).toList(),
        'merchantQRs': merchantQrs.map((e) => e.toJson()).toList(),
        'payees': payees,
        'billingCycles': pWallet['billingCycles'] ?? [],
      });

      final prefs = _pendingPayload!['preferences'];
      if (prefs != null) {
        if (prefs['userName'] != null) ui.setUserName(prefs['userName']);
        if (prefs['isDark'] != null) {
          if (ui.isDark != prefs['isDark']) {
            ui.toggleTheme();
          }
        }
      }

      setState(() {
        _pendingPayload = null;
        _statusMessage = 'Backup restored successfully!';
        _isError = false;
      });
    } catch (e) {
      setState(() {
        _pendingPayload = null;
        _statusMessage = 'Restore failed: $e';
        _isError = true;
      });
    }

    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) setState(() => _statusMessage = '');
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final wallet = context.watch<WalletProvider>();
    final ui = context.watch<UiProvider>();
    final totalItems =
        wallet.upis.length +
        wallet.cards.length +
        wallet.accounts.length +
        wallet.merchantQRs.length;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Backup & Restore',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        backgroundColor: theme.colorScheme.surface,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: _pendingPayload != null
          ? _buildConfirmDialog(theme, wallet, ui)
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '🔐  Encrypted Backup',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Your data is saved in a JSON format. The backup file (.mbk) can be restored via this app. Store it in a safe location.',
                          style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFFAAEF00,
                            ).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '$totalItems items in current data',
                            style: const TextStyle(
                              color: Color(0xFFAAEF00),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_statusMessage.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: _isError
                            ? theme.colorScheme.errorContainer
                            : const Color(0xFFAAEF00).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Text(
                            _isError ? '❌ ' : '✅ ',
                            style: const TextStyle(fontSize: 16),
                          ),
                          Expanded(
                            child: Text(
                              _statusMessage,
                              style: TextStyle(
                                color: _isError
                                    ? theme.colorScheme.onErrorContainer
                                    : const Color(0xFFAAEF00),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFAAEF00),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              '📤',
                              style: TextStyle(fontSize: 24),
                            ),
                          ),
                          title: Text(
                            'Export Backup',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          subtitle: Text(
                            'Save an encrypted .mbk file to share or store',
                            style: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _handleExport(wallet, ui),
                        ),
                        Divider(
                          height: 1,
                          color: theme.colorScheme.outlineVariant,
                        ),
                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              '📥',
                              style: TextStyle(fontSize: 24),
                            ),
                          ),
                          title: Text(
                            'Import Backup',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          subtitle: Text(
                            'Restore from a previously exported .mbk file',
                            style: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: _handleImport,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildConfirmDialog(
    ThemeData theme,
    WalletProvider wallet,
    UiProvider ui,
  ) {
    final payload = _pendingPayload!;
    final dateStr = DateTime.parse(payload['exportedAt']).toLocal().toString();

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Restore Backup?',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '⚠️ This will replace ALL current data. This action cannot be undone.',
              style: TextStyle(color: theme.colorScheme.onErrorContainer),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Backup from $dateStr',
            style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => _pendingPayload = null),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFAAEF00),
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () => _confirmRestore(wallet, ui),
                  child: const Text(
                    'Restore Now',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
