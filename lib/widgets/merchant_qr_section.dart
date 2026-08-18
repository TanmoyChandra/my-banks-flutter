import 'package:flutter/material.dart';

class MerchantQRSection extends StatelessWidget {
  final bool hideHeader;

  const MerchantQRSection({super.key, this.hideHeader = false});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
      child: Center(
        child: Text(
          'Merchant QR Section\n(Coming Soon)',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
