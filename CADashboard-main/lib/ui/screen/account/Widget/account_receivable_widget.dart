import 'package:cadashboard/core/utils/colors.dart';
import 'package:cadashboard/core/services/api_text_localizer.dart';
import 'package:flutter/material.dart';

// ignore: non_constant_identifier_names
Widget CustomText({required String title, required String value, required String currency}){
  return Card(
    surfaceTintColor: Colors.white,
    color: Colors.white,
    elevation: 3,
    child: Padding(
      padding: const EdgeInsets.all(8),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            Builder(
              builder: (context) {
                return Text(
                  ApiTextLocalizer.localize(title, locale: Localizations.localeOf(context)),
                  style: const TextStyle(color: AppColor.background,fontWeight: FontWeight.bold,fontSize: 15),
                );
              },
            ),
            const SizedBox(height: 3,),
            Text("$currency : $value"),
          ],
        ),
      ),
    ),
  );
}

// ignore: non_constant_identifier_names
Widget RawDivider(){
  return Container(
    color: Colors.grey.shade400,
    width: 1,height: 40,
  );
}

// ignore: non_constant_identifier_names
Widget TitleText(String text, {Color? color}){
  return Builder(
    builder: (context) {
      return Text(
        ApiTextLocalizer.localize(text, locale: Localizations.localeOf(context)),
        style: TextStyle(fontWeight: FontWeight.bold, color: color),
      );
    },
  );
}

// ignore: non_constant_identifier_names
Widget ValueText(String value, {Color? color}){
  return Text(value, style: TextStyle(color: color),);
}