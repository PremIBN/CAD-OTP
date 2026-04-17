import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:cadashboard/core/services/api_text_localizer.dart';

// ignore: non_constant_identifier_names
Widget EmptyData({String emptyData = 'No Data Found'}) {
  return Builder(
    builder: (context) {
      return Center(
        child: Text(
          ApiTextLocalizer.localize(emptyData, locale: Localizations.localeOf(context)),
        ),
      );
    },
  );
}
