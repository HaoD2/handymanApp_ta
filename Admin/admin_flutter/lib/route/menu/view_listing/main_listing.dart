import 'package:admin_flutter/responsive.dart';
import 'package:admin_flutter/route/menu/view_listing/listing_Dekstop.dart';
import 'package:admin_flutter/route/menu/view_listing/listing_Mobile.dart';
import 'package:admin_flutter/route/menu/view_listing/listing_Tablet.dart';
import 'package:flutter/material.dart';

class ListingView extends StatelessWidget {
  const ListingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Responsive(
      mobile: ListingMobile(),
      tablet: ListingTablet(),
      desktop: ListingDekstop(),
    );
  }
}
