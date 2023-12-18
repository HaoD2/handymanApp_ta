import 'package:admin_flutter/call_to_action/call_action.dart';
import 'package:admin_flutter/widget/content_detail/detail.dart';
import 'package:flutter/material.dart';

class HomeContentDekstop extends StatelessWidget {
  const HomeContentDekstop({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: <Widget>[
          detail(),
          Expanded(child: Center(child: callAction('Coba 1')))
        ],
      ),
    );
  }
}
