import 'package:admin_flutter/views/home_content_desktop.dart';
import 'package:admin_flutter/views/home_content_mobile.dart';
import 'package:admin_flutter/widget/Center_view/centered_view.dart';
import 'package:admin_flutter/widget/content_detail/detail.dart';
import 'package:admin_flutter/widget/navigation_bar/nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';

class home_view extends StatelessWidget {
  const home_view({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      body: centered_view(
          child: Column(children: <Widget>[
        nav_bar(),
        Expanded(
            child: ScreenTypeLayout(
          mobile: HomeContentMobile(),
          desktop: HomeContentDekstop(),
        ))
      ])),
    );
  }
}
