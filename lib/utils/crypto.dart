const _secretLocalKey = "MB_LOCAL_PERSIST_KEY_998877";

/// Encrypts a string by XORing with a key and converting to Hex.
/// Safe for all character ranges.
String encryptLocal(String text) {
  if (text.isEmpty) return "";
  StringBuffer result = StringBuffer();
  for (int i = 0; i < text.length; i++) {
    int charCode = text.codeUnitAt(i);
    int keyChar = _secretLocalKey.codeUnitAt(i % _secretLocalKey.length);
    int xor = charCode ^ keyChar;
    // Convert to 4-digit hex
    result.write(xor.toRadixString(16).padLeft(4, '0'));
  }
  return result.toString();
}

/// Decrypts a Hex string back to the original string.
String decryptLocal(String cipher) {
  if (cipher.isEmpty) return "";
  try {
    StringBuffer result = StringBuffer();
    for (int i = 0; i < cipher.length; i += 4) {
      if (i + 4 > cipher.length) break;
      String hex = cipher.substring(i, i + 4);
      int xor = int.parse(hex, radix: 16);
      int keyChar = _secretLocalKey.codeUnitAt((i ~/ 4) % _secretLocalKey.length);
      result.writeCharCode(xor ^ keyChar);
    }
    return result.toString();
  } catch (e) {
    // print("Failed to decrypt local data: $e");
    return "";
  }
}
