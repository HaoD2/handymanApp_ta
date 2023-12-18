import 'package:flutter/material.dart';

class navBarItems extends StatelessWidget {
  final String titles;
  const navBarItems(this.titles);

  @override
  Widget build(BuildContext context) {
    return Text(
      titles,
      style: TextStyle(fontSize: 18),
    );
  }
}
