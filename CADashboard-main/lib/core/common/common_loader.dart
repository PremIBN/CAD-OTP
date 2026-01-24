
import 'package:flutter/material.dart';

// ignore: non_constant_identifier_names
Widget CommonLoader({Color? loaderColor}){
  return Center(child: CircularProgressIndicator(color: loaderColor,));
}