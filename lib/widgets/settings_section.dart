import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:local_auth/local_auth.dart';
import 'dart:io';

import '../providers/ui_provider.dart';
import '../providers/wallet_provider.dart';

class SettingsSection extends StatefulWidget {
  const SettingsSection({super.key});

  @override
  State<SettingsSection> createState() => _SettingsSectionState();
}

class _SettingsSectionState extends State<SettingsSection> with SingleTickerProviderStateMixin {
  late AnimationController _rotateAnim;

  @override
  void initState() {
    super.initState();
    _rotateAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _rotateAnim.dispose();
    super.dispose();
  }

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null && context.mounted) {
      context.read<UiProvider>().setUserImage(pickedFile.path);
    }
  }

  Future<void> _toggleAppLock(BuildContext context, UiProvider uiProvider) async {
    if (uiProvider.isAppLockEnabled) {
      uiProvider.setAppLockEnabled(false);
    } else {
      final localAuth = LocalAuthentication();
      final canCheckBiometrics = await localAuth.canCheckBiometrics;
      final isDeviceSupported = await localAuth.isDeviceSupported();

      if (!canCheckBiometrics || !isDeviceSupported) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Your device doesn't support or have biometrics/PIN setup.")));
        }
        return;
      }

      try {
        final didAuthenticate = await localAuth.authenticate(
          localizedReason: 'Authenticate to enable App Lock',
        );
        if (didAuthenticate) {
          uiProvider.setAppLockEnabled(true);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Authentication failed: $e')));
        }
      }
    }
  }

  void _showProfileModal(BuildContext context, UiProvider uiProvider) {
    final textController = TextEditingController(text: uiProvider.userName);
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          title: Text('Edit Profile', style: TextStyle(color: theme.colorScheme.onSurface)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () async {
                  await _pickImage(context);
                  if (context.mounted) Navigator.of(context).pop();
                },
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: theme.colorScheme.primaryContainer,
                      backgroundImage: uiProvider.userImage != null ? FileImage(File(uiProvider.userImage!)) : null,
                      child: uiProvider.userImage == null
                          ? Icon(Icons.person, size: 50, color: theme.colorScheme.onPrimaryContainer)
                          : null,
                    ),
                    Positioned(
                      bottom: 0, right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(color: const Color(0xFFAAEF00), borderRadius: BorderRadius.circular(15)),
                        child: const Icon(Icons.camera_alt, size: 20, color: Colors.black),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text('Tap to change picture', style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12)),
              const SizedBox(height: 20),
              TextField(
                controller: textController,
                decoration: InputDecoration(
                  labelText: 'Your Name',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              )
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
            ),
            TextButton(
              onPressed: () {
                if (textController.text.trim().isNotEmpty) {
                  uiProvider.setUserName(textController.text.trim());
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save', style: TextStyle(color: Color(0xFFAAEF00))),
            ),
          ],
        );
      }
    );
  }

  void _showPayeesModal(BuildContext context, WalletProvider walletProvider) {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          title: Text('Payees Master List', style: TextStyle(color: theme.colorScheme.onSurface, fontFamily: 'SpaceGrotesk', fontWeight: FontWeight.w900, fontSize: 24)),
          content: StatefulBuilder(
            builder: (context, setStateModal) {
              return SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Add people you frequently share expenses with. They will appear in your transaction drop-downs.', style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 14)),
                    const SizedBox(height: 20),
                    TextField(
                      controller: textController,
                      onChanged: (_) => setStateModal(() {}),
                      decoration: InputDecoration(
                        labelText: 'New Payee Name',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.add_circle),
                          color: textController.text.trim().isNotEmpty ? const Color(0xFFAAEF00) : theme.colorScheme.onSurfaceVariant,
                          onPressed: () {
                            final name = textController.text.trim();
                            if (name.isNotEmpty && !walletProvider.payees.contains(name)) {
                              walletProvider.addPayee(name);
                              textController.clear();
                              setStateModal(() {});
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      height: 240,
                      decoration: BoxDecoration(color: theme.colorScheme.surfaceVariant, borderRadius: BorderRadius.circular(16)),
                      child: ListView.separated(
                        itemCount: walletProvider.payees.length,
                        separatorBuilder: (context, index) => Divider(height: 1, color: theme.colorScheme.outlineVariant),
                        itemBuilder: (context, index) {
                          final p = walletProvider.payees[index];
                          final isMe = p == 'Me';
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isMe ? const Color(0xFFAAEF00) : theme.colorScheme.primaryContainer,
                              child: Text(
                                p[0].toUpperCase(),
                                style: TextStyle(color: isMe ? Colors.black : theme.colorScheme.onPrimaryContainer, fontWeight: FontWeight.w700),
                              ),
                            ),
                            title: Text(p, style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: isMe ? FontWeight.w800 : FontWeight.w600)),
                            trailing: isMe
                                ? Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(color: const Color(0x33AAEF00), borderRadius: BorderRadius.circular(12)),
                                    child: const Text('DEFAULT', style: TextStyle(color: Color(0xFFAAEF00), fontSize: 11, fontWeight: FontWeight.w800)),
                                  )
                                : IconButton(
                                    icon: Icon(Icons.remove_circle_outline, color: theme.colorScheme.error),
                                    onPressed: () {
                                      walletProvider.removePayee(p);
                                      setStateModal(() {});
                                    },
                                  ),
                          );
                        },
                      ),
                    )
                  ],
                ),
              );
            }
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFFAAEF00), foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('Done', style: TextStyle(fontWeight: FontWeight.w800)),
            )
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final uiProvider = context.watch<UiProvider>();
    final walletProvider = context.watch<WalletProvider>();
    final isDark = theme.brightness == Brightness.dark;
    
    if (isDark) {
      _rotateAnim.forward();
    } else {
      _rotateAnim.reverse();
    }

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
                        'Settings',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                      ),
                      if (uiProvider.userName.isNotEmpty)
                        Text(
                          'Hi, ${uiProvider.userName}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Row(
                  children: [
                    RotationTransition(
                      turns: Tween(begin: 0.0, end: 0.5).animate(_rotateAnim),
                      child: IconButton(
                        icon: Icon(isDark ? Icons.wb_sunny : Icons.nightlight_round, color: isDark ? Colors.black : Colors.white),
                        style: IconButton.styleFrom(backgroundColor: isDark ? const Color(0xFFAAEF00) : const Color(0xFF1C1C1C)),
                        onPressed: uiProvider.toggleTheme,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _showProfileModal(context, uiProvider),
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: theme.colorScheme.primaryContainer,
                        backgroundImage: uiProvider.userImage != null ? FileImage(File(uiProvider.userImage!)) : null,
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
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16).copyWith(bottom: 96),
              children: [
                _SectionLabel(label: 'PROFILE'),
                _SetupCard(
                  icon: Icons.account_circle,
                  title: 'Profile',
                  subtitle: 'Update your name and profile picture',
                  onPress: () => _showProfileModal(context, uiProvider),
                ),

                const SizedBox(height: 12),
                _SectionLabel(label: 'DATA SETUP'),
                _SetupCard(
                  icon: Icons.group,
                  title: 'Payees Master List',
                  subtitle: 'Manage people you share expenses with',
                  onPress: () => _showPayeesModal(context, walletProvider),
                ),
                _SetupCard(
                  icon: Icons.qr_code,
                  title: 'UPI / QR Codes',
                  subtitle: 'Add and manage your UPI IDs and QR codes',
                  onPress: () => context.push('/main/setup-qr'),
                ),
                _SetupCard(
                  icon: Icons.credit_card,
                  title: 'Debit / Credit Cards',
                  subtitle: 'Save card numbers, expiry dates and CVV',
                  onPress: () => context.push('/main/setup-cards'),
                ),
                _SetupCard(
                  icon: Icons.storefront,
                  title: 'Merchant QR Codes',
                  subtitle: 'Add frequently-used merchant QR codes from your gallery',
                  onPress: () => context.push('/main/setup-merchant-qr'),
                ),
                _SetupCard(
                  icon: Icons.account_balance,
                  title: 'Bank Accounts',
                  subtitle: 'Store IFSC, account number and branch details',
                  onPress: () => context.push('/main/setup-accounts'),
                ),

                const SizedBox(height: 12),
                _SectionLabel(label: 'BACKUP & RESTORE'),
                _SetupCard(
                  icon: Icons.save_alt,
                  title: 'Export / Import Data',
                  subtitle: 'Save an encrypted backup or restore all your data',
                  onPress: () => context.push('/main/setup-backup'),
                ),

                const SizedBox(height: 12),
                _SectionLabel(label: 'SECURITY'),
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(color: theme.colorScheme.surfaceVariant, borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    leading: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(color: const Color(0xFFAAEF00), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.fingerprint, color: Colors.black),
                    ),
                    title: const Text('App Lock', style: TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: const Text('Require fingerprint or PIN to open', style: TextStyle(fontSize: 12)),
                    trailing: Switch(
                      value: uiProvider.isAppLockEnabled,
                      onChanged: (val) => _toggleAppLock(context, uiProvider),
                      activeColor: const Color(0xFFAAEF00),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: theme.colorScheme.surfaceVariant, borderRadius: BorderRadius.circular(24), border: Border.all(color: theme.colorScheme.outlineVariant)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('MyBanks Security', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                      const SizedBox(height: 16),
                      RichText(
                        text: TextSpan(
                          style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 14, height: 1.5),
                          children: const [
                            TextSpan(text: 'Your data is '),
                            TextSpan(text: '100% unbreakable', style: TextStyle(fontWeight: FontWeight.w700)),
                            TextSpan(text: '. All information is encrypted and stored locally on your mobile phone for ultimate privacy.'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('No accounts, no trackers, no cloud sync. Everything stays on your device, exactly where it belongs.', style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12)),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _SecurityFeature(icon: Icons.cloud_off, label: 'Offline Only'),
                          _SecurityFeature(icon: Icons.security, label: 'AES-XOR'),
                          _SecurityFeature(icon: Icons.fingerprint, label: 'Biometric'),
                        ],
                      )
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                Text('Made with ❤️ by Tanmoy Chandra', textAlign: TextAlign.center, style: TextStyle(color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5), fontSize: 13)),
                const SizedBox(height: 12),
                Text('Version 1.0.0', textAlign: TextAlign.center, style: TextStyle(color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4), fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
    );
  }
}

class _SetupCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onPress;

  const _SetupCard({required this.icon, required this.title, required this.subtitle, required this.onPress});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceVariant, borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        onTap: onPress,
        leading: Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: const Color(0xFFAAEF00), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: Colors.black),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
    );
  }
}

class _SecurityFeature extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SecurityFeature({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurfaceVariant)),
      ],
    );
  }
}
