import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';

import '../providers/ui_provider.dart';

class CalculatorSection extends StatefulWidget {
  const CalculatorSection({super.key});

  @override
  State<CalculatorSection> createState() => _CalculatorSectionState();
}

class _CalculatorSectionState extends State<CalculatorSection> {
  // State for Calculator 1
  final TextEditingController _c1x = TextEditingController();
  final TextEditingController _c1y = TextEditingController();
  String _c1Res = '';

  // State for Calculator 2
  final TextEditingController _c2x = TextEditingController();
  final TextEditingController _c2y = TextEditingController();
  String _c2Res = '';

  // State for Calculator 3
  final TextEditingController _c3x = TextEditingController();
  final TextEditingController _c3y = TextEditingController();
  String _c3Res = '';

  @override
  void dispose() {
    _c1x.dispose(); _c1y.dispose();
    _c2x.dispose(); _c2y.dispose();
    _c3x.dispose(); _c3y.dispose();
    super.dispose();
  }

  void _handleCalc1() {
    final x = double.tryParse(_c1x.text);
    final y = double.tryParse(_c1y.text);
    if (x != null && y != null) {
      setState(() => _c1Res = ((x / 100) * y).toStringAsFixed(3).replaceAll(RegExp(r'\.?0*$'), ''));
    } else {
      setState(() => _c1Res = '');
    }
  }

  void _handleCalc2() {
    final x = double.tryParse(_c2x.text);
    final y = double.tryParse(_c2y.text);
    if (x != null && y != null && y != 0) {
      setState(() => _c2Res = ((x / y) * 100).toStringAsFixed(3).replaceAll(RegExp(r'\.?0*$'), ''));
    } else {
      setState(() => _c2Res = '');
    }
  }

  void _handleCalc3() {
    final x = double.tryParse(_c3x.text);
    final y = double.tryParse(_c3y.text);
    if (x != null && y != null && x != 0) {
      final diff = y - x;
      setState(() => _c3Res = '${((diff / x.abs()) * 100).toStringAsFixed(3).replaceAll(RegExp(r'\.?0*$'), '')}%');
    } else {
      setState(() => _c3Res = '');
    }
  }

  Future<void> _copyToClipboard(String text) async {
    if (text.isNotEmpty) {
      await Clipboard.setData(ClipboardData(text: text));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied to clipboard'), duration: Duration(seconds: 1)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final uiProvider = context.watch<UiProvider>();
    final isDark = theme.brightness == Brightness.dark;
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
                        'Calculator',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Quickly calculate percentages with ease.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDark ? const Color(0xFFA1A1AA) : const Color(0xFF52525B),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                CircleAvatar(
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
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16).copyWith(bottom: 96),
              children: [
                _CalcCard(
                  icon: Icons.percent,
                  title: 'What is X% of Y?',
                  xPlaceholder: 'Enter %',
                  yPlaceholder: 'Enter value',
                  separator: '% of',
                  xController: _c1x,
                  yController: _c1y,
                  resultValue: _c1Res,
                  onCalculate: _handleCalc1,
                  onCopy: () => _copyToClipboard(_c1Res),
                ),
                _CalcCard(
                  icon: Icons.pie_chart,
                  title: 'X is what percent of Y?',
                  xPlaceholder: 'Enter value',
                  yPlaceholder: 'Enter value',
                  separator: 'is what % of',
                  xController: _c2x,
                  yController: _c2y,
                  resultValue: _c2Res,
                  onCalculate: _handleCalc2,
                  onCopy: () => _copyToClipboard(_c2Res),
                ),
                _CalcCard(
                  icon: Icons.trending_up,
                  title: 'Percentage Increase / Decrease',
                  xPlaceholder: 'old value',
                  yPlaceholder: 'new value',
                  separator: 'to',
                  prefixText: 'from',
                  xController: _c3x,
                  yController: _c3y,
                  resultValue: _c3Res,
                  onCalculate: _handleCalc3,
                  onCopy: () => _copyToClipboard(_c3Res),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF161616) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E5EA)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 34, height: 34,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0x14AAEF00) : const Color(0x33AAEF00),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.lightbulb_outline, color: Color(0xFFAAEF00), size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('How it works', style: TextStyle(color: Color(0xFFAAEF00), fontWeight: FontWeight.w700, fontSize: 14)),
                            const SizedBox(height: 4),
                            Text(
                              'Enter the required values in the fields above and tap Calculate to get the result instantly.',
                              style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12, height: 1.5),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CalcCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? prefixText;
  final String xPlaceholder;
  final String yPlaceholder;
  final String separator;
  final TextEditingController xController;
  final TextEditingController yController;
  final String resultValue;
  final VoidCallback onCalculate;
  final VoidCallback onCopy;

  const _CalcCard({
    required this.icon,
    required this.title,
    this.prefixText,
    required this.xPlaceholder,
    required this.yPlaceholder,
    required this.separator,
    required this.xController,
    required this.yController,
    required this.resultValue,
    required this.onCalculate,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = const Color(0xFFAAEF00);
    final cardBg = isDark ? const Color(0xFF161616) : Colors.white;
    final borderColor = isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E5EA);
    final inputBg = isDark ? const Color(0xFF101010) : const Color(0xFFF2F2F7);
    final inputBorderColor = isDark ? const Color(0xFF242424) : const Color(0xFFD1D1D6);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 34, height: 34,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0x14AAEF00) : const Color(0x33AAEF00),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: accentColor, size: 18),
              ),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              if (prefixText != null) ...[
                Text(prefixText!, style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 13)),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: _StyledTextField(
                  controller: xController,
                  placeholder: xPlaceholder,
                  inputBg: inputBg,
                  borderColor: inputBorderColor,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(separator, style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 13)),
              ),
              Expanded(
                child: _StyledTextField(
                  controller: yController,
                  placeholder: yPlaceholder,
                  inputBg: inputBg,
                  borderColor: inputBorderColor,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text('=', style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 45,
                child: SizedBox(
                  height: 44,
                  child: FilledButton(
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      onCalculate();
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Calculate', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 55,
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: inputBg,
                    border: Border.all(color: inputBorderColor),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.only(left: 12, right: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          resultValue.isNotEmpty ? resultValue : 'Result',
                          style: TextStyle(
                            color: resultValue.isNotEmpty ? theme.colorScheme.onSurface : const Color(0xFF6A6A6C),
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy, size: 18),
                        color: const Color(0xFF6A6A6C),
                        onPressed: onCopy,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      )
                    ],
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}

class _StyledTextField extends StatelessWidget {
  final TextEditingController controller;
  final String placeholder;
  final Color inputBg;
  final Color borderColor;

  const _StyledTextField({
    required this.controller,
    required this.placeholder,
    required this.inputBg,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          hintText: placeholder,
          hintStyle: const TextStyle(color: Color(0xFF6A6A6C), fontSize: 13),
          filled: true,
          fillColor: inputBg,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
          ),
        ),
      ),
    );
  }
}
