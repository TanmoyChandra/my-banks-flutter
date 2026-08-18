import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../providers/wallet_provider.dart';
import '../../models/types.dart';
import '../../constants/banks.dart';
import '../../utils/qr_extraction.dart';
import '../../widgets/bank_picker.dart';

class SetupQRScreen extends StatefulWidget {
  const SetupQRScreen({super.key});

  @override
  State<SetupQRScreen> createState() => _SetupQRScreenState();
}

class _SetupQRScreenState extends State<SetupQRScreen> {
  bool _showForm = false;
  bool _isLoading = false;
  String? _editId;

  final TextEditingController _nameController = TextEditingController();
  String _bankName = '';
  final TextEditingController _upiIdController = TextEditingController();
  final TextEditingController _qrValueController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();
  String _notes = '';

  @override
  void dispose() {
    _nameController.dispose();
    _upiIdController.dispose();
    _qrValueController.dispose();
    _mobileNumberController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _nameController.clear();
    _bankName = '';
    _upiIdController.clear();
    _qrValueController.clear();
    _mobileNumberController.clear();
    _notes = '';
    setState(() {
      _showForm = false;
      _editId = null;
    });
  }

  void _handleEdit(QREntry entry) {
    _nameController.text = entry.name;
    _bankName = entry.bankName;
    _upiIdController.text = entry.upiId;
    _qrValueController.text = entry.qrValue;
    _mobileNumberController.text = entry.mobileNumber;
    _notes = entry.notes;
    setState(() {
      _editId = entry.id;
      _showForm = true;
    });
  }

  void _handleSave(WalletProvider provider) {
    if (_upiIdController.text.trim().isEmpty &&
        _qrValueController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a UPI ID or scan a QR code.'),
        ),
      );
      return;
    }

    final qrValue = _qrValueController.text.trim().isNotEmpty
        ? _qrValueController.text.trim()
        : 'upi://pay?pa=${Uri.encodeComponent(_upiIdController.text.trim())}&pn=${Uri.encodeComponent(_nameController.text.trim().isNotEmpty ? _nameController.text.trim() : _bankName.trim())}&cu=INR';

    final newEntry = QREntry(
      id: _editId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      bankName: _bankName,
      upiId: _upiIdController.text.trim(),
      qrValue: qrValue,
      mobileNumber: _mobileNumberController.text.trim(),
      address: '',
      notes: _notes,
    );

    if (_editId != null) {
      provider.updateUpi(_editId!, newEntry);
    } else {
      provider.addUpi(newEntry);
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
      final BarcodeCapture? capture = await controller.analyzeImage(
        pickedFile.path,
      );

      if (capture != null && capture.barcodes.isNotEmpty) {
        final code = capture.barcodes.first.rawValue;
        if (code != null && code.isNotEmpty) {
          final extracted = extractQRData(code, null);
          setState(() {
            _nameController.text = extracted['name'] ?? _nameController.text;
            _bankName = extracted['bankName'] ?? _bankName;
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
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
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
    final entries = walletProvider.upis;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Setup QR Code',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        backgroundColor: theme.colorScheme.surface,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _showForm
          ? SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _editId != null ? 'Edit UPI Entry' : 'New UPI Entry',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                      ),
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: _showBankPicker,
                      child: AbsorbPointer(
                        child: TextField(
                          controller: TextEditingController(text: _bankName),
                          decoration: const InputDecoration(
                            labelText: 'Bank Name',
                            suffixIcon: Icon(Icons.keyboard_arrow_down),
                          ),
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _upiIdController,
                      decoration: const InputDecoration(
                        labelText: 'UPI ID',
                      ),
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _qrValueController,
                      decoration: const InputDecoration(
                        labelText: 'QR Value',
                      ),
                      maxLines: 3,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _mobileNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Mobile Number',
                      ),
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 20),
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
                if (entries.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 60, bottom: 20),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor:
                              theme.colorScheme.surfaceContainerHighest,
                          child: Icon(
                            Icons.qr_code,
                            size: 32,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No UPI entries added yet.',
                          style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ...entries.map((entry) {
                    final bank = findBankByName(entry.bankName);
                    return Dismissible(
                      key: Key(entry.id),
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
                      onDismissed: (_) => walletProvider.deleteUpi(entry.id),
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: bank != null
                              ? Image.asset(bank.symbol, width: 40, height: 40)
                              : const Icon(Icons.qr_code, size: 40),
                          title: Text(
                            entry.name.isNotEmpty
                                ? entry.name
                                : (entry.bankName.isNotEmpty
                                      ? entry.bankName
                                      : entry.upiId),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            entry.upiId.isNotEmpty
                                ? entry.upiId
                                : entry.qrValue,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _handleEdit(entry),
                          ),
                        ),
                      ),
                    );
                  }),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Card(
                        child: InkWell(
                          onTap: _pickAndScan,
                          borderRadius: BorderRadius.circular(12),
                          child: SizedBox(
                            height: 100,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.image,
                                  size: 36,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Scan from Gallery',
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
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Card(
                        child: InkWell(
                          onTap: () => setState(() => _showForm = true),
                          borderRadius: BorderRadius.circular(12),
                          child: SizedBox(
                            height: 100,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.edit,
                                  size: 36,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Manual Entry',
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
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}
