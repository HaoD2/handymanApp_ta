import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class handymanHome extends StatefulWidget {
  static const routeName = '/handyman/homeHandyman';
  final email;
  const handymanHome({super.key, this.email});

  @override
  State<handymanHome> createState() => _handymanHomeState();
}

class _handymanHomeState extends State<handymanHome> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
