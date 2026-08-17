class Bank {
  final String slug;
  final String name;
  final String logo;
  final String symbol;

  const Bank({
    required this.slug,
    required this.name,
    required this.logo,
    required this.symbol,
  });
}

const List<Bank> banks = [
  Bank(slug: 'airp', name: 'Airtel Payments Bank', logo: 'assets/bank-logos/airp/logo.png', symbol: 'assets/bank-logos/airp/symbol.png'),
  Bank(slug: 'aubl', name: 'AU Small Finance Bank Limited', logo: 'assets/bank-logos/aubl/logo.png', symbol: 'assets/bank-logos/aubl/symbol.png'),
  Bank(slug: 'barb', name: 'Bank of Baroda', logo: 'assets/bank-logos/barb/logo.png', symbol: 'assets/bank-logos/barb/symbol.png'),
  Bank(slug: 'bdbl', name: 'Bandhan Bank', logo: 'assets/bank-logos/bdbl/logo.png', symbol: 'assets/bank-logos/bdbl/symbol.png'),
  Bank(slug: 'bkid', name: 'Bank of India', logo: 'assets/bank-logos/bkid/logo.png', symbol: 'assets/bank-logos/bkid/symbol.png'),
  Bank(slug: 'cbin', name: 'Central Bank of India', logo: 'assets/bank-logos/cbin/logo.png', symbol: 'assets/bank-logos/cbin/symbol.png'),
  Bank(slug: 'ciub', name: 'City Union Bank', logo: 'assets/bank-logos/ciub/logo.png', symbol: 'assets/bank-logos/ciub/symbol.png'),
  Bank(slug: 'cnrb', name: 'Canara Bank', logo: 'assets/bank-logos/cnrb/logo.png', symbol: 'assets/bank-logos/cnrb/symbol.png'),
  Bank(slug: 'csbk', name: 'CSB Bank Limited', logo: 'assets/bank-logos/csbk/logo.png', symbol: 'assets/bank-logos/csbk/symbol.png'),
  Bank(slug: 'dcbl', name: 'DCB Bank Limited', logo: 'assets/bank-logos/dcbl/logo.png', symbol: 'assets/bank-logos/dcbl/symbol.png'),
  Bank(slug: 'dlxb', name: 'Dhanalakshmi Bank', logo: 'assets/bank-logos/dlxb/logo.png', symbol: 'assets/bank-logos/dlxb/symbol.png'),
  Bank(slug: 'esmf', name: 'ESAF Small Finance Bank', logo: 'assets/bank-logos/esmf/logo.png', symbol: 'assets/bank-logos/esmf/symbol.png'),
  Bank(slug: 'fdrl', name: 'Federal Bank', logo: 'assets/bank-logos/fdrl/logo.png', symbol: 'assets/bank-logos/fdrl/symbol.png'),
  Bank(slug: 'hdfc', name: 'HDFC Bank', logo: 'assets/bank-logos/hdfc/logo.png', symbol: 'assets/bank-logos/hdfc/symbol.png'),
  Bank(slug: 'ibkl', name: 'IDBI Bank', logo: 'assets/bank-logos/ibkl/logo.png', symbol: 'assets/bank-logos/ibkl/symbol.png'),
  Bank(slug: 'icic', name: 'ICICI Bank Limited', logo: 'assets/bank-logos/icic/logo.png', symbol: 'assets/bank-logos/icic/symbol.png'),
  Bank(slug: 'idfb', name: 'IDFC First Bank Limited', logo: 'assets/bank-logos/idfb/logo.png', symbol: 'assets/bank-logos/idfb/symbol.png'),
  Bank(slug: 'idib', name: 'Indian Bank', logo: 'assets/bank-logos/idib/logo.png', symbol: 'assets/bank-logos/idib/symbol.png'),
  Bank(slug: 'indb', name: 'IndusInd Bank', logo: 'assets/bank-logos/indb/logo.png', symbol: 'assets/bank-logos/indb/symbol.png'),
  Bank(slug: 'ioba', name: 'Indian Overseas Bank', logo: 'assets/bank-logos/ioba/logo.png', symbol: 'assets/bank-logos/ioba/symbol.png'),
  Bank(slug: 'jaka', name: 'Jammu and Kashmir Bank', logo: 'assets/bank-logos/jaka/logo.png', symbol: 'assets/bank-logos/jaka/symbol.png'),
  Bank(slug: 'jiop', name: 'Jio Payments Bank', logo: 'assets/bank-logos/jiop/logo.png', symbol: 'assets/bank-logos/jiop/symbol.png'),
  Bank(slug: 'karb', name: 'Karnataka Bank Limited', logo: 'assets/bank-logos/karb/logo.png', symbol: 'assets/bank-logos/karb/symbol.png'),
  Bank(slug: 'kkbk', name: 'Kotak Mahindra Bank Limited', logo: 'assets/bank-logos/kkbk/logo.png', symbol: 'assets/bank-logos/kkbk/symbol.png'),
  Bank(slug: 'kvbl', name: 'Karur Vysya Bank', logo: 'assets/bank-logos/kvbl/logo.png', symbol: 'assets/bank-logos/kvbl/symbol.png'),
  Bank(slug: 'mahb', name: 'Bank of Maharashtra', logo: 'assets/bank-logos/mahb/logo.png', symbol: 'assets/bank-logos/mahb/symbol.png'),
  Bank(slug: 'ntbl', name: 'The Nainital Bank Limited', logo: 'assets/bank-logos/ntbl/logo.png', symbol: 'assets/bank-logos/ntbl/symbol.png'),
  Bank(slug: 'psib', name: 'Punjab and Sind Bank', logo: 'assets/bank-logos/psib/logo.png', symbol: 'assets/bank-logos/psib/symbol.png'),
  Bank(slug: 'punb', name: 'Punjab National Bank', logo: 'assets/bank-logos/punb/logo.png', symbol: 'assets/bank-logos/punb/symbol.png'),
  Bank(slug: 'pytm', name: 'Paytm Payments Bank', logo: 'assets/bank-logos/pytm/logo.png', symbol: 'assets/bank-logos/pytm/symbol.png'),
  Bank(slug: 'ratn', name: 'RBL Bank Limited', logo: 'assets/bank-logos/ratn/logo.png', symbol: 'assets/bank-logos/ratn/symbol.png'),
  Bank(slug: 'sbin', name: 'State Bank of India', logo: 'assets/bank-logos/sbin/logo.png', symbol: 'assets/bank-logos/sbin/symbol.png'),
  Bank(slug: 'scbl', name: 'Standard Chartered Bank', logo: 'assets/bank-logos/scbl/logo.png', symbol: 'assets/bank-logos/scbl/symbol.png'),
  Bank(slug: 'sibl', name: 'South Indian Bank', logo: 'assets/bank-logos/sibl/logo.png', symbol: 'assets/bank-logos/sibl/symbol.png'),
  Bank(slug: 'slice', name: 'Slice SF Bank', logo: 'assets/bank-logos/slice/logo.png', symbol: 'assets/bank-logos/slice/symbol.png'),
  Bank(slug: 'tmbl', name: 'Tamilnad Mercantile Bank Limited', logo: 'assets/bank-logos/tmbl/logo.png', symbol: 'assets/bank-logos/tmbl/symbol.png'),
  Bank(slug: 'ubin', name: 'Union Bank of India', logo: 'assets/bank-logos/ubin/logo.png', symbol: 'assets/bank-logos/ubin/symbol.png'),
  Bank(slug: 'ucba', name: 'UCO Bank', logo: 'assets/bank-logos/ucba/logo.png', symbol: 'assets/bank-logos/ucba/symbol.png'),
  Bank(slug: 'ujvn', name: 'Ujjivan Small Finance Bank Ltd', logo: 'assets/bank-logos/ujvn/logo.png', symbol: 'assets/bank-logos/ujvn/symbol.png'),
  Bank(slug: 'utib', name: 'Axis Bank', logo: 'assets/bank-logos/utib/logo.png', symbol: 'assets/bank-logos/utib/symbol.png'),
  Bank(slug: 'yesb', name: 'Yes Bank', logo: 'assets/bank-logos/yesb/logo.png', symbol: 'assets/bank-logos/yesb/symbol.png'),
];

Bank? findBankByName(String? bankName) {
  if (bankName == null || bankName.isEmpty) return null;
  final normalized = bankName.toLowerCase().replaceAll(RegExp(r'\blimited\b'), '').trim();

  // 1. Try exact match first
  for (final bank in banks) {
    final normalizedBank = bank.name.toLowerCase().replaceAll(RegExp(r'\blimited\b'), '').trim();
    if (normalizedBank == normalized) return bank;
  }

  // 2. Try fuzzy match (inclusion)
  for (final bank in banks) {
    final normalizedBank = bank.name.toLowerCase().replaceAll(RegExp(r'\blimited\b'), '').trim();
    if (normalizedBank.contains(normalized) || normalized.contains(normalizedBank)) return bank;
  }

  return null;
}
