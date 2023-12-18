import 'package:admin_flutter/call_to_action/call_action.dart';
import 'package:admin_flutter/widget/content_detail/detail.dart';
import 'package:flutter/material.dart';

class HomeContentMobile extends StatelessWidget {
  const HomeContentMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        detail(),
        SizedBox(
          height: 100,
        ),
        callAction('coba 1')
      ],
    );
  }
}
