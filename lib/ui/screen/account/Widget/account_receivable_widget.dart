import 'package:cadashboard/core/utils/colors.dart';
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
            Text(title,style: const TextStyle(color: AppColor.background,fontWeight: FontWeight.bold,fontSize: 15)),
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
  return Text(text,style: TextStyle(fontWeight: FontWeight.bold, color: color),);
}

// ignore: non_constant_identifier_names
Widget ValueText(String value, {Color? color}){
  return Text(value, style: TextStyle(color: color),);
}