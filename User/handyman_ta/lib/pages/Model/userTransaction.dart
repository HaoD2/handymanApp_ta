import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';

class UserTransaction {
  final String username;
  final String transactionDate;
  final double amount;
  final Map<String, dynamic> xenditPaymentDetails;

  UserTransaction({
    required this.username,
    required this.transactionDate,
    required this.amount,
    required this.xenditPaymentDetails,
  });
}
