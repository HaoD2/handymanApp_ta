import 'package:flutter/material.dart';

class InsertOptionDekstop extends StatefulWidget {
  final layanan;
  const InsertOptionDekstop({super.key, this.layanan});

  @override
  State<InsertOptionDekstop> createState() => _InsertOptionDekstopState();
}

class _InsertOptionDekstopState extends State<InsertOptionDekstop> {
  @override
  Widget build(BuildContext context) {
    print(this.widget.layanan);
    return const Placeholder();
  }
}
