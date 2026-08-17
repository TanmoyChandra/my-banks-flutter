import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/types.dart';
import '../utils/crypto.dart';

class WalletProvider extends ChangeNotifier {
  final _uuid = const Uuid();

  List<QREntry> _upis = [];
  List<CardEntry> _cards = [];
  List<BankAccount> _accounts = [];
  List<CardTransaction> _transactions = [];
  List<MerchantQR> _merchantQRs = [];
  List<String> _payees = ['Me'];
  List<BillingCycle> _billingCycles = [];

  List<QREntry> get upis => _upis;
  List<CardEntry> get cards => _cards;
  List<BankAccount> get accounts => _accounts;
  List<CardTransaction> get transactions => _transactions;
  List<MerchantQR> get merchantQRs => _merchantQRs;
  List<String> get payees => _payees;
  List<BillingCycle> get billingCycles => _billingCycles;

  WalletProvider() {
    _loadFromPrefs();
  }

  String _generateId() => "${DateTime.now().millisecondsSinceEpoch}-${_uuid.v4().substring(0, 8)}";

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final encryptedData = prefs.getString('mybanks-wallet');
    if (encryptedData != null) {
      try {
        final decryptedData = decryptLocal(encryptedData);
        final Map<String, dynamic> data = jsonDecode(decryptedData);
        if (data.containsKey('state')) {
          final state = data['state'];
          _upis = (state['upis'] as List?)?.map((e) => QREntry.fromJson(e)).toList() ?? [];
          _cards = (state['cards'] as List?)?.map((e) => CardEntry.fromJson(e)).toList() ?? [];
          _accounts = (state['accounts'] as List?)?.map((e) => BankAccount.fromJson(e)).toList() ?? [];
          _transactions = (state['transactions'] as List?)?.map((e) => CardTransaction.fromJson(e)).toList() ?? [];
          _merchantQRs = (state['merchantQRs'] as List?)?.map((e) => MerchantQR.fromJson(e)).toList() ?? [];
          _payees = (state['payees'] as List?)?.map((e) => e.toString()).toList() ?? ['Me'];
          _billingCycles = (state['billingCycles'] as List?)?.map((e) => BillingCycle.fromJson(e)).toList() ?? [];
          notifyListeners();
        }
      } catch (e) {
        // print("Failed to parse wallet state");
      }
    }
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final state = {
      'upis': _upis.map((e) => e.toJson()).toList(),
      'cards': _cards.map((e) => e.toJson()).toList(),
      'accounts': _accounts.map((e) => e.toJson()).toList(),
      'transactions': _transactions.map((e) => e.toJson()).toList(),
      'merchantQRs': _merchantQRs.map((e) => e.toJson()).toList(),
      'payees': _payees,
      'billingCycles': _billingCycles.map((e) => e.toJson()).toList(),
    };
    final dataString = jsonEncode({'state': state, 'version': 0});
    await prefs.setString('mybanks-wallet', encryptLocal(dataString));
  }

  // UPI CRUD
  void addUpi(QREntry entry) {
    _upis.add(QREntry(
      id: _generateId(),
      name: entry.name,
      bankName: entry.bankName,
      upiId: entry.upiId,
      qrValue: entry.qrValue,
      mobileNumber: entry.mobileNumber,
      address: entry.address,
      notes: entry.notes,
    ));
    _saveToPrefs();
    notifyListeners();
  }

  void updateUpi(String id, QREntry entry) {
    final index = _upis.indexWhere((e) => e.id == id);
    if (index != -1) {
      _upis[index] = QREntry(
        id: id,
        name: entry.name,
        bankName: entry.bankName,
        upiId: entry.upiId,
        qrValue: entry.qrValue,
        mobileNumber: entry.mobileNumber,
        address: entry.address,
        notes: entry.notes,
      );
      _saveToPrefs();
      notifyListeners();
    }
  }

  void deleteUpi(String id) {
    _upis.removeWhere((e) => e.id == id);
    _saveToPrefs();
    notifyListeners();
  }

  // Card CRUD
  void addCard(CardEntry card) {
    _cards.add(CardEntry(
      id: _generateId(),
      type: card.type,
      network: card.network,
      bankName: card.bankName,
      holderName: card.holderName,
      cardNumber: card.cardNumber,
      expiry: card.expiry,
      cvv: card.cvv,
      nickname: card.nickname,
      color: card.color,
      billingDate: card.billingDate,
      dueDaysAfterBilling: card.dueDaysAfterBilling,
    ));
    _saveToPrefs();
    notifyListeners();
  }

  void updateCard(String id, CardEntry card) {
    final index = _cards.indexWhere((c) => c.id == id);
    if (index != -1) {
      _cards[index] = CardEntry(
        id: id,
        type: card.type,
        network: card.network,
        bankName: card.bankName,
        holderName: card.holderName,
        cardNumber: card.cardNumber,
        expiry: card.expiry,
        cvv: card.cvv,
        nickname: card.nickname,
        color: card.color,
        billingDate: card.billingDate,
        dueDaysAfterBilling: card.dueDaysAfterBilling,
      );
      _saveToPrefs();
      notifyListeners();
    }
  }

  void deleteCard(String id) {
    _cards.removeWhere((c) => c.id == id);
    _transactions.removeWhere((t) => t.cardId == id);
    _billingCycles.removeWhere((b) => b.cardId == id);
    _saveToPrefs();
    notifyListeners();
  }

  void reorderCards(List<String> orderedIds) {
    _cards.sort((a, b) {
      int indexA = orderedIds.indexOf(a.id);
      int indexB = orderedIds.indexOf(b.id);
      if (indexA == -1) return 1;
      if (indexB == -1) return -1;
      return indexA.compareTo(indexB);
    });
    _saveToPrefs();
    notifyListeners();
  }

  // Account CRUD
  void addAccount(BankAccount account) {
    _accounts.add(BankAccount(
      id: _generateId(),
      bankName: account.bankName,
      accountHolder: account.accountHolder,
      accountNumber: account.accountNumber,
      ifsc: account.ifsc,
      accountType: account.accountType,
      branchName: account.branchName,
      color: account.color,
    ));
    _saveToPrefs();
    notifyListeners();
  }

  void updateAccount(String id, BankAccount account) {
    final index = _accounts.indexWhere((a) => a.id == id);
    if (index != -1) {
      _accounts[index] = BankAccount(
        id: id,
        bankName: account.bankName,
        accountHolder: account.accountHolder,
        accountNumber: account.accountNumber,
        ifsc: account.ifsc,
        accountType: account.accountType,
        branchName: account.branchName,
        color: account.color,
      );
      _saveToPrefs();
      notifyListeners();
    }
  }

  void deleteAccount(String id) {
    _accounts.removeWhere((a) => a.id == id);
    _saveToPrefs();
    notifyListeners();
  }

  // Transaction CRUD
  void addTransaction(CardTransaction tx) {
    _transactions.insert(0, CardTransaction(
      id: _generateId(),
      cardId: tx.cardId,
      type: tx.type,
      amount: tx.amount,
      description: tx.description,
      date: tx.date,
      payee: tx.payee,
      isFlagged: tx.isFlagged,
      billingCycleId: tx.billingCycleId,
    ));
    _saveToPrefs();
    notifyListeners();
  }

  void updateTransaction(String id, CardTransaction tx) {
    final index = _transactions.indexWhere((t) => t.id == id);
    if (index != -1) {
      _transactions[index] = CardTransaction(
        id: id,
        cardId: tx.cardId,
        type: tx.type,
        amount: tx.amount,
        description: tx.description,
        date: tx.date,
        payee: tx.payee,
        isFlagged: tx.isFlagged,
        billingCycleId: tx.billingCycleId,
      );
      _saveToPrefs();
      notifyListeners();
    }
  }

  void deleteTransaction(String id) {
    _transactions.removeWhere((t) => t.id == id);
    _saveToPrefs();
    notifyListeners();
  }

  List<CardTransaction> getTransactionsForCard(String cardId) {
    return _transactions.where((t) => t.cardId == cardId).toList();
  }

  void migrateLegacyTransactionsForCard(String cardId) {
    final cardTxs = _transactions.where((t) => t.cardId == cardId).toList();
    final legacyTxs = cardTxs.where((t) => t.billingCycleId == null).toList();
    if (legacyTxs.isEmpty) return;

    final newCycle = BillingCycle(
      id: _generateId(),
      cardId: cardId,
      name: 'Initial Cycle',
      startDate: DateTime.now().toIso8601String(),
      isClosed: false,
    );
    _billingCycles.add(newCycle);

    for (var i = 0; i < _transactions.length; i++) {
      if (_transactions[i].cardId == cardId && _transactions[i].billingCycleId == null) {
        _transactions[i] = CardTransaction(
          id: _transactions[i].id,
          cardId: _transactions[i].cardId,
          type: _transactions[i].type,
          amount: _transactions[i].amount,
          description: _transactions[i].description,
          date: _transactions[i].date,
          payee: _transactions[i].payee,
          isFlagged: _transactions[i].isFlagged,
          billingCycleId: newCycle.id,
        );
      }
    }
    _saveToPrefs();
    notifyListeners();
  }

  // Billing Cycle CRUD
  void addBillingCycle(BillingCycle cycle) {
    _billingCycles.insert(0, BillingCycle(
      id: _generateId(),
      cardId: cycle.cardId,
      name: cycle.name,
      startDate: cycle.startDate,
      billingDate: cycle.billingDate,
      isClosed: cycle.isClosed,
    ));
    _saveToPrefs();
    notifyListeners();
  }

  void updateBillingCycle(String id, BillingCycle cycle) {
    final index = _billingCycles.indexWhere((b) => b.id == id);
    if (index != -1) {
      _billingCycles[index] = BillingCycle(
        id: id,
        cardId: cycle.cardId,
        name: cycle.name,
        startDate: cycle.startDate,
        billingDate: cycle.billingDate,
        isClosed: cycle.isClosed,
      );
      _saveToPrefs();
      notifyListeners();
    }
  }

  void deleteBillingCycle(String id) {
    _billingCycles.removeWhere((b) => b.id == id);
    _transactions.removeWhere((t) => t.billingCycleId == id);
    _saveToPrefs();
    notifyListeners();
  }

  // Merchant QR CRUD
  void addMerchantQR(MerchantQR entry) {
    _merchantQRs.add(MerchantQR(
      id: _generateId(),
      name: entry.name,
      category: entry.category,
      upiId: entry.upiId,
      qrValue: entry.qrValue,
      imageUri: entry.imageUri,
      notes: entry.notes,
    ));
    _saveToPrefs();
    notifyListeners();
  }

  void updateMerchantQR(String id, MerchantQR entry) {
    final index = _merchantQRs.indexWhere((m) => m.id == id);
    if (index != -1) {
      _merchantQRs[index] = MerchantQR(
        id: id,
        name: entry.name,
        category: entry.category,
        upiId: entry.upiId,
        qrValue: entry.qrValue,
        imageUri: entry.imageUri,
        notes: entry.notes,
      );
      _saveToPrefs();
      notifyListeners();
    }
  }

  void deleteMerchantQR(String id) {
    _merchantQRs.removeWhere((m) => m.id == id);
    _saveToPrefs();
    notifyListeners();
  }

  // Payees
  void addPayee(String name) {
    if (!_payees.contains(name)) {
      _payees.add(name);
      _saveToPrefs();
      notifyListeners();
    }
  }

  void removePayee(String name) {
    _payees.remove(name);
    _saveToPrefs();
    notifyListeners();
  }

  void setAllState(Map<String, dynamic> state) {
    _upis = (state['upis'] as List?)?.map((e) => QREntry.fromJson(e)).toList() ?? [];
    _cards = (state['cards'] as List?)?.map((e) => CardEntry.fromJson(e)).toList() ?? [];
    _accounts = (state['accounts'] as List?)?.map((e) => BankAccount.fromJson(e)).toList() ?? [];
    _transactions = (state['transactions'] as List?)?.map((e) => CardTransaction.fromJson(e)).toList() ?? [];
    _merchantQRs = (state['merchantQRs'] as List?)?.map((e) => MerchantQR.fromJson(e)).toList() ?? [];
    _payees = (state['payees'] as List?)?.map((e) => e.toString()).toList() ?? ['Me'];
    _billingCycles = (state['billingCycles'] as List?)?.map((e) => BillingCycle.fromJson(e)).toList() ?? [];
    _saveToPrefs();
    notifyListeners();
  }
}
