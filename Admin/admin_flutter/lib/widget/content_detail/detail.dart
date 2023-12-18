import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';

class detail extends StatelessWidget {
  const detail({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(builder: (context, sizinginformation) {
      var textAlignment =
          sizinginformation.deviceScreenType == DeviceScreenType.desktop
              ? TextAlign.left
              : TextAlign.center;
      double titleSize =
          sizinginformation.deviceScreenType == DeviceScreenType.mobile
              ? 50
              : 80;

      double desc =
          sizinginformation.deviceScreenType == DeviceScreenType.mobile
              ? 16
              : 21;

      return Container(
        width: 600,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed tempor metus eu quam lobortis, sit amet dignissim lorem laoreet.Vivamus vitae neque eget tortor eleifend ullamcorper nec vel justo.Integer aliquet leo at purus suscipit, ut dictum mi molestie.Phasellus feugiat libero eu convallis auctor.Cras euismod odio vel nibh consectetur, in placerat velit volutpat',
              style: TextStyle(fontSize: desc),
              textAlign: textAlignment,
            )
          ],
        ),
      );
    });
  }
}
