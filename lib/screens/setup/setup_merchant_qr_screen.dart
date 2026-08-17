import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../providers/wallet_provider.dart';
import '../../models/types.dart';
import '../../utils/qr_extraction.dart';

class SetupMerchantQRScreen extends StatefulWidget {
  const SetupMerchantQRScreen({super.key});

  @override
  State<SetupMerchantQRScreen> createState() => _SetupMerchantQRScreenState();
}

class _SetupMerchantQRScreenState extends State<SetupMerchantQRScreen> {
  bool _showForm = false;
  bool _isLoading = false;
  String? _editId;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _upiIdController = TextEditingController();
  final TextEditingController _qrValueController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _upiIdController.dispose();
    _qrValueController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _nameController.clear();
    _categoryController.clear();
    _upiIdController.clear();
    _qrValueController.clear();
    setState(() {
      _showForm = false;
      _editId = null;
    });
  }

  void _handleEdit(MerchantQR m) {
    _nameController.text = m.name;
    _categoryController.text = m.category ?? '';
    _upiIdController.text = m.upiId ?? '';
    _qrValueController.text = m.qrValue ?? '';
    setState(() {
      _editId = m.id;
      _showForm = true;
    });
  }

  void _handleSave(WalletProvider provider) {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a merchant name.')));
      return;
    }
    if (_upiIdController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a UPI ID. This is mandatory for merchants.')));
      return;
    }

    final newMerchant = MerchantQR(
      id: _editId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      category: _categoryController.text.trim().isNotEmpty ? _categoryController.text.trim() : null,
      upiId: _upiIdController.text.trim(),
      qrValue: _qrValueController.text.trim().isNotEmpty ? _qrValueController.text.trim() : null,
    );

    if (_editId != null) {
      provider.updateMerchantQR(_editId!, newMerchant);
    } else {
      provider.addMerchantQR(newMerchant);
    }
    _resetForm();
  }

  Future<void> _pickAndScan() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    setState(() => _isLoading = true);

    try {
      final MobileScannerController controller = MobileScannerController();
      final BarcodeCapture? capture = await controller.analyzeImage(pickedFile.path);

      if (capture != null && capture.barcodes.isNotEmpty) {
        final code = capture.barcodes.first.rawValue;
        if (code != null && code.isNotEmpty) {
          final extracted = extractQRData(code, null);
          setState(() {
            _nameController.text = extracted['name'] ?? _nameController.text;
            _upiIdController.text = extracted['upiId'] ?? _upiIdController.text;
            _qrValueController.text = extracted['qrValue'] ?? code;
            _showForm = true;
          });
        } else {
          _showError('No QR code found in the image.');
        }
      } else {
        _showError('No QR code found in the image.');
      }
      controller.dispose();
    } catch (e) {
      _showError('Failed to analyze image: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final walletProvider = context.watch<WalletProvider>();
    final merchants = walletProvider.merchantQRs;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(_showForm ? (_editId != null ? 'Edit Merchant QR' : 'Add Merchant QR') : 'Merchant QR Codes', style: const TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: theme.colorScheme.surface,
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => _showForm ? _resetForm() : context.pop()),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _showForm
              ? SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Merchant Name *', border: OutlineInputBorder()), style: const TextStyle(fontSize: 14)),
                        const SizedBox(height: 12),
                        TextField(controller: _categoryController, decoration: const InputDecoration(labelText: 'Category (e.g. Food, Fuel)', border: OutlineInputBorder()), style: const TextStyle(fontSize: 14)),
                        const SizedBox(height: 12),
                        TextField(controller: _upiIdController, decoration: const InputDecoration(labelText: 'UPI ID *', border: OutlineInputBorder()), keyboardType: TextInputType.emailAddress, style: const TextStyle(fontSize: 14)),
                        const SizedBox(height: 12),
                        TextField(controller: _qrValueController, decoration: const InputDecoration(labelText: 'QR Value (optional)', border: OutlineInputBorder()), maxLines: 3, style: const TextStyle(fontSize: 14)),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: FilledButton(
                            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFAAEF00), foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                            onPressed: () => _handleSave(walletProvider),
                            child: Text(_editId != null ? 'Update' : 'Save Merchant QR', style: const TextStyle(fontWeight: FontWeight.w700)),
                          ),
                        )
                      ],
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (merchants.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 60, bottom: 20),
                        child: Column(
                          children: [
                            CircleAvatar(radius: 36, backgroundColor: theme.colorScheme.surfaceVariant, child: Icon(Icons.storefront, size: 36, color: theme.colorScheme.onSurfaceVariant)),
                            const SizedBox(height: 12),
                            Text('No merchant QRs yet', style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 20, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text('Add your first one below', style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 14)),
                          ],
                        ),
                      )
                    else
                      ...merchants.map((m) {
                        return Dismissible(
                          key: Key(m.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            color: theme.colorScheme.error,
                            child: Icon(Icons.delete, color: theme.colorScheme.onError),
                          ),
                          onDismissed: (_) => walletProvider.deleteMerchantQR(m.id),
                          child: Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 1,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              leading: CircleAvatar(backgroundColor: theme.colorScheme.surfaceVariant, child: const Icon(Icons.storefront)),
                              title: Text(m.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(m.category ?? m.upiId ?? 'No details'),
                              trailing: IconButton(icon: const Icon(Icons.edit), onPressed: () => _handleEdit(m)),
                            ),
                          ),
                        );
                      }),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: _pickAndScan,
                            child: Container(
                              height: 100,
                              decoration: BoxDecoration(color: isDark ? const Color(0xFF2A2A2A) : Colors.white, borderRadius: BorderRadius.circular(12)),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.image, size: 36, color: theme.colorScheme.onSurfaceVariant),
                                  const SizedBox(height: 8),
                                  Text('Scan from Gallery', style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _showForm = true),
                            child: Container(
                              height: 100,
                              decoration: BoxDecoration(color: isDark ? const Color(0xFF2A2A2A) : Colors.white, borderRadius: BorderRadius.circular(12)),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.edit, size: 36, color: theme.colorScheme.onSurfaceVariant),
                                  const SizedBox(height: 8),
                                  Text('Manual Entry', style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
    );
  }
}
