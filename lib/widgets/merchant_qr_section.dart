import 'package:flutter/material.dart';

class MerchantQRSection extends StatelessWidget {
  final bool hideHeader;

  const MerchantQRSection({super.key, this.hideHeader = false});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Merchant QR Section'));
  }
}
