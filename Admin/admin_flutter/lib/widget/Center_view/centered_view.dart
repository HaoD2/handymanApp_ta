import 'package:admin_flutter/widget/navigation_bar/nav_bar.dart';
import 'package:flutter/material.dart';

class centered_view extends StatelessWidget {
  final Widget child;
  const centered_view({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 70, vertical: 20),
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 1200),
        child: child,
      ),
    );
  }
}
