import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import '../providers/ui_provider.dart';
import '../providers/wallet_provider.dart';
import '../models/types.dart';
import '../constants/banks.dart';
import 'merchant_qr_section.dart';

class QRSection extends StatefulWidget {
  const QRSection({super.key});

  @override
  State<QRSection> createState() => _QRSectionState();
}

class _QRSectionState extends State<QRSection>
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
    final uiProvider = context.watch<UiProvider>();
    final walletProvider = context.watch<WalletProvider>();
    final entries = walletProvider.upis;

    final String initials = uiProvider.userName.isNotEmpty
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
                        'UPI / QR Codes',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Easily share your QR codes to receive payments from any UPI app.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: () {
                    // Navigate to settings (handled by MainScreen bottom nav in RN, but here it's an avatar tap? RN navigation.navigate('Settings'))
                    // Wait, in RN bottom nav, settings is a tab. We can switch tabs using a provider or just let it be handled.
                  },
                  child: CircleAvatar(
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
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(4),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.shadow.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: theme.colorScheme.onSurface,
                unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                labelStyle: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                unselectedLabelStyle: theme.textTheme.labelLarge,
                tabs: const [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.qr_code, size: 16),
                        SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            'My UPI/QRs',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.storefront_outlined, size: 16),
                        SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            'Merchant QRs',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _MyQRCodes(entries: entries),
                const MerchantQRSection(hideHeader: true),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MyQRCodes extends StatelessWidget {
  final List<QREntry> entries;

  const _MyQRCodes({required this.entries});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth - 48 - 12).clamp(0.0, 450.0);

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(left: 24, right: 12),
      itemCount: entries.length + 1,
      itemBuilder: (context, index) {
        if (index == entries.length) {
          // Add new placeholder
          return SizedBox(
            width: cardWidth,
            child: Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: Card(
                margin: EdgeInsets.zero,
                child: InkWell(
                  onTap: () => context.push('/main/setup-qr'),
                  borderRadius: BorderRadius.circular(16),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: Colors.transparent,
                          child: Icon(
                            Icons.add,
                            size: 32,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Add new QR code',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.only(right: 12.0),
          child: _QRPayCard(entry: entries[index], width: cardWidth),
        );
      },
    );
  }
}

class _QRPayCard extends StatefulWidget {
  final QREntry entry;
  final double width;

  const _QRPayCard({required this.entry, required this.width});

  @override
  State<_QRPayCard> createState() => _QRPayCardState();
}

class _QRPayCardState extends State<_QRPayCard> {
  final GlobalKey _qrKey = GlobalKey();

  Future<void> _handleCopyUPI() async {
    if (widget.entry.upiId.isNotEmpty) {
      await Clipboard.setData(ClipboardData(text: widget.entry.upiId));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('UPI ID copied to clipboard'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    }
  }

  Future<void> _handleShare() async {
    try {
      final boundary =
          _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/qr_code.png').create();
      await file.writeAsBytes(pngBytes);

      final title = widget.entry.name.isNotEmpty
          ? widget.entry.name
          : (widget.entry.bankName.isNotEmpty
                ? widget.entry.bankName
                : widget.entry.upiId);

      await Share.shareXFiles([
        XFile(file.path),
      ], subject: 'Share $title QR Code');
    } catch (e) {
      // print('Error sharing QR: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = widget.entry.name.isNotEmpty
        ? widget.entry.name
        : (widget.entry.bankName.isNotEmpty
              ? widget.entry.bankName
              : widget.entry.upiId);
    final upiLink = widget.entry.qrValue.isNotEmpty
        ? widget.entry.qrValue
        : 'upi://pay?pa=${widget.entry.upiId}&pn=${Uri.encodeComponent(title)}&cu=INR';
    final qrSize = (widget.width - 92).clamp(0.0, 180.0);
    final bank = findBankByName(widget.entry.bankName);

    return SizedBox(
      width: widget.width,
      child: Column(
        children: [
          RepaintBoundary(
            key: _qrKey,
            child: Card(
              margin: EdgeInsets.zero,
              color: theme.colorScheme.surfaceContainerHighest,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
              child: SizedBox(
                width: widget.width,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
                  child: Column(
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 20),
                  QrImageView(
                    data: upiLink,
                    size: qrSize,
                    backgroundColor: Colors.transparent,
                    foregroundColor: theme.colorScheme.onSurface,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Scan to pay with any UPI app',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 44,
                        height: 25,
                        margin: const EdgeInsets.only(right: 6),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: theme.colorScheme.outlineVariant),
                        ),
                        alignment: Alignment.center,
                        child: bank != null
                            ? Image.asset(
                                bank.symbol,
                                height: 22,
                                fit: BoxFit.contain,
                              )
                            : Text(
                                (widget.entry.bankName.isNotEmpty
                                        ? widget.entry.bankName
                                        : title)
                                    .substring(0, 2)
                                    .toUpperCase(),
                                style: TextStyle(
                                  color: theme.colorScheme.onSurface,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                ),
                              ),
                      ),
                      Flexible(
                        child: Text(
                          widget.entry.bankName.isNotEmpty
                              ? widget.entry.bankName
                              : 'Bank not detected',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: theme.colorScheme.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 23),
                  GestureDetector(
                    onTap: _handleCopyUPI,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'UPI ID:',
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.entry.upiId.isNotEmpty
                              ? widget.entry.upiId
                              : 'Not found',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: widget.width,
            child: FilledButton.tonalIcon(
              onPressed: _handleShare,
              icon: const Icon(Icons.share_outlined),
              label: const Text('Share QR code'),
            ),
          ),
        ],
      ),
    );
  }
}
