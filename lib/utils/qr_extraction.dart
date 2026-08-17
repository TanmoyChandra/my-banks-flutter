Map<String, String> extractQRData(String code, dynamic options) {
  String name = '';
  String upiId = '';

  try {
    if (code.startsWith('upi://')) {
      final uri = Uri.parse(code);
      upiId = uri.queryParameters['pa'] ?? '';
      name = uri.queryParameters['pn'] ?? '';
    } else {
      upiId = code;
    }
  } catch (e) {
    upiId = code;
  }

  return {
    'name': name.replaceAll('+', ' '),
    'upiId': upiId,
    'raw': code,
  };
}
