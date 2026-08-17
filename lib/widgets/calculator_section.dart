import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
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
    _c1x.dispose();
    _c1y.dispose();
    _c2x.dispose();
    _c2y.dispose();
    _c3x.dispose();
    _c3y.dispose();
    super.dispose();
  }

  void _handleCalc1() {
    final x = double.tryParse(_c1x.text);
    final y = double.tryParse(_c1y.text);
    if (x != null && y != null) {
      setState(
        () => _c1Res = ((x / 100) * y)
            .toStringAsFixed(3)
            .replaceAll(RegExp(r'\.?0*$'), ''),
      );
    } else {
      setState(() => _c1Res = '');
    }
  }

  void _handleCalc2() {
    final x = double.tryParse(_c2x.text);
    final y = double.tryParse(_c2y.text);
    if (x != null && y != null && y != 0) {
      setState(
        () => _c2Res = ((x / y) * 100)
            .toStringAsFixed(3)
            .replaceAll(RegExp(r'\.?0*$'), ''),
      );
    } else {
      setState(() => _c2Res = '');
    }
  }

  void _handleCalc3() {
    final x = double.tryParse(_c3x.text);
    final y = double.tryParse(_c3y.text);
    if (x != null && y != null && x != 0) {
      final diff = y - x;
      setState(
        () => _c3Res =
            '${((diff / x.abs()) * 100).toStringAsFixed(3).replaceAll(RegExp(r'\.?0*$'), '')}%',
      );
    } else {
      setState(() => _c3Res = '');
    }
  }

  Future<void> _copyToClipboard(String text) async {
    if (text.isNotEmpty) {
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
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final uiProvider = context.watch<UiProvider>();
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
            child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ).copyWith(bottom: 96),
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
                Card(
                  margin: const EdgeInsets.only(top: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.lightbulb_outline,
                          color: theme.colorScheme.onPrimaryContainer,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'How it works',
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Enter the required values in the fields above and tap Calculate to get the result instantly.',
                              style: TextStyle(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontSize: 12,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: theme.colorScheme.onPrimaryContainer, size: 18),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              if (prefixText != null) ...[
                Text(
                  prefixText!,
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: _StyledTextField(
                  controller: xController,
                  placeholder: xPlaceholder,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  separator,
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
              ),
              Expanded(
                child: _StyledTextField(
                  controller: yController,
                  placeholder: yPlaceholder,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  '=',
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
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
                    child: const Text('Calculate'),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 55,
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    border: Border.all(color: theme.colorScheme.outlineVariant),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.only(left: 12, right: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          resultValue.isNotEmpty ? resultValue : 'Result',
                          style: TextStyle(
                            color: resultValue.isNotEmpty
                                ? theme.colorScheme.onSurface
                                : theme.colorScheme.onSurfaceVariant,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy, size: 18),
                        color: theme.colorScheme.onSurfaceVariant,
                        onPressed: onCopy,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
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
    );
  }
}

class _StyledTextField extends StatelessWidget {
  final TextEditingController controller;
  final String placeholder;

  const _StyledTextField({
    required this.controller,
    required this.placeholder,
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        ),
      ),
    );
  }
}
