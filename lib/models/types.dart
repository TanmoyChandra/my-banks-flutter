class QREntry {
  final String id;
  final String name;
  final String bankName;
  final String upiId;
  final String qrValue;
  final String mobileNumber;
  final String address;
  final String notes;

  QREntry({
    required this.id,
    required this.name,
    required this.bankName,
    required this.upiId,
    required this.qrValue,
    required this.mobileNumber,
    required this.address,
    required this.notes,
  });

  factory QREntry.fromJson(Map<String, dynamic> json) => QREntry(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        bankName: json['bankName'] ?? '',
        upiId: json['upiId'] ?? '',
        qrValue: json['qrValue'] ?? '',
        mobileNumber: json['mobileNumber'] ?? '',
        address: json['address'] ?? '',
        notes: json['notes'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'bankName': bankName,
        'upiId': upiId,
        'qrValue': qrValue,
        'mobileNumber': mobileNumber,
        'address': address,
        'notes': notes,
      };
}

class CardEntry {
  final String id;
  final String type; // 'Credit' | 'Debit'
  final String? network; // 'Visa' | 'Mastercard' | 'RuPay'
  final String bankName;
  final String holderName;
  final String cardNumber;
  final String expiry;
  final String cvv;
  final String nickname;
  final String? color;
  final int? billingDate;
  final int? dueDaysAfterBilling;

  CardEntry({
    required this.id,
    required this.type,
    this.network,
    required this.bankName,
    required this.holderName,
    required this.cardNumber,
    required this.expiry,
    required this.cvv,
    required this.nickname,
    this.color,
    this.billingDate,
    this.dueDaysAfterBilling,
  });

  factory CardEntry.fromJson(Map<String, dynamic> json) => CardEntry(
        id: json['id'] ?? '',
        type: json['type'] ?? 'Debit',
        network: json['network'],
        bankName: json['bankName'] ?? '',
        holderName: json['holderName'] ?? '',
        cardNumber: json['cardNumber'] ?? '',
        expiry: json['expiry'] ?? '',
        cvv: json['cvv'] ?? '',
        nickname: json['nickname'] ?? '',
        color: json['color'],
        billingDate: json['billingDate'],
        dueDaysAfterBilling: json['dueDaysAfterBilling'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'network': network,
        'bankName': bankName,
        'holderName': holderName,
        'cardNumber': cardNumber,
        'expiry': expiry,
        'cvv': cvv,
        'nickname': nickname,
        'color': color,
        'billingDate': billingDate,
        'dueDaysAfterBilling': dueDaysAfterBilling,
      };
}

class BillingCycle {
  final String id;
  final String cardId;
  final String name;
  final String startDate;
  final String? billingDate;
  final bool isClosed;

  BillingCycle({
    required this.id,
    required this.cardId,
    required this.name,
    required this.startDate,
    this.billingDate,
    required this.isClosed,
  });

  factory BillingCycle.fromJson(Map<String, dynamic> json) => BillingCycle(
        id: json['id'] ?? '',
        cardId: json['cardId'] ?? '',
        name: json['name'] ?? '',
        startDate: json['startDate'] ?? '',
        billingDate: json['billingDate'],
        isClosed: json['isClosed'] ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'cardId': cardId,
        'name': name,
        'startDate': startDate,
        'billingDate': billingDate,
        'isClosed': isClosed,
      };
}

class BankAccount {
  final String id;
  final String bankName;
  final String accountHolder;
  final String accountNumber;
  final String ifsc;
  final String accountType; // 'Savings' | 'Current' | 'Loan'
  final String branchName;
  final String? color;

  BankAccount({
    required this.id,
    required this.bankName,
    required this.accountHolder,
    required this.accountNumber,
    required this.ifsc,
    required this.accountType,
    required this.branchName,
    this.color,
  });

  factory BankAccount.fromJson(Map<String, dynamic> json) => BankAccount(
        id: json['id'] ?? '',
        bankName: json['bankName'] ?? '',
        accountHolder: json['accountHolder'] ?? '',
        accountNumber: json['accountNumber'] ?? '',
        ifsc: json['ifsc'] ?? '',
        accountType: json['accountType'] ?? 'Savings',
        branchName: json['branchName'] ?? '',
        color: json['color'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'bankName': bankName,
        'accountHolder': accountHolder,
        'accountNumber': accountNumber,
        'ifsc': ifsc,
        'accountType': accountType,
        'branchName': branchName,
        'color': color,
      };
}

class CardTransaction {
  final String id;
  final String cardId;
  final String type; // 'debit' | 'credit'
  final double amount;
  final String description;
  final String date;
  final String? payee;
  final bool? isFlagged;
  final String? billingCycleId;

  CardTransaction({
    required this.id,
    required this.cardId,
    required this.type,
    required this.amount,
    required this.description,
    required this.date,
    this.payee,
    this.isFlagged,
    this.billingCycleId,
  });

  factory CardTransaction.fromJson(Map<String, dynamic> json) => CardTransaction(
        id: json['id'] ?? '',
        cardId: json['cardId'] ?? '',
        type: json['type'] ?? 'debit',
        amount: (json['amount'] ?? 0).toDouble(),
        description: json['description'] ?? '',
        date: json['date'] ?? '',
        payee: json['payee'],
        isFlagged: json['isFlagged'],
        billingCycleId: json['billingCycleId'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'cardId': cardId,
        'type': type,
        'amount': amount,
        'description': description,
        'date': date,
        'payee': payee,
        'isFlagged': isFlagged,
        'billingCycleId': billingCycleId,
      };
}

class MerchantQR {
  final String id;
  final String name;
  final String? category;
  final String? upiId;
  final String? qrValue;
  final String? imageUri;
  final String? notes;

  MerchantQR({
    required this.id,
    required this.name,
    this.category,
    this.upiId,
    this.qrValue,
    this.imageUri,
    this.notes,
  });

  factory MerchantQR.fromJson(Map<String, dynamic> json) => MerchantQR(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        category: json['category'],
        upiId: json['upiId'],
        qrValue: json['qrValue'],
        imageUri: json['imageUri'],
        notes: json['notes'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'upiId': upiId,
        'qrValue': qrValue,
        'imageUri': imageUri,
        'notes': notes,
      };
}
