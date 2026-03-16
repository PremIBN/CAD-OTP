import 'package:cadashboard/core/utils/colors.dart';
import 'package:flutter/material.dart';

class CusField extends StatelessWidget {

  final String hint;
  final bool? visible;
  final bool? readOnly;
  final Icon? icon;
  final Widget? prefix;
  final IconButton? suffixIcon;
  final TextInputType? keyboardType;
  final TextEditingController? controller;
  final FormFieldValidator? onValidator;
  final ValueChanged<String>? onChanged;


  const CusField({super.key, required this.hint, this.controller, this.icon, this.suffixIcon, this.keyboardType, this.onValidator, this.onChanged, this.visible, this.prefix, this.readOnly,});

  static InputBorder borders = OutlineInputBorder(
    borderRadius: BorderRadius.circular(25),
    borderSide: const BorderSide(width: 1.5)
  );
  static InputBorder errorBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(25),
    borderSide: const BorderSide(width: 1.5,color: Colors.red)
  );

  @override
  Widget build(BuildContext context) {

    return TextFormField(
      controller: controller,
      readOnly: readOnly == null ? false : readOnly!,
      style: const TextStyle(
        fontSize: 15,fontWeight: FontWeight.w600
      ),
      obscureText: visible == null ? false : visible!,
      cursorColor: Colors.black,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.all(15),
        hintText: hint,
        labelText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        labelStyle: const TextStyle(fontWeight: FontWeight.w100),
        focusedBorder: borders,
        enabledBorder: borders,
        errorBorder: errorBorder,
        focusedErrorBorder: errorBorder,
        prefix: prefix,
        prefixIconConstraints: prefix != null ? const BoxConstraints.tightForFinite() : null,
        prefixIcon: icon,
        suffixIcon: suffixIcon,
        suffixIconColor: AppColor.background
      ),
      onChanged: onChanged,
      onSaved: (newValue) {},
      validator: onValidator,
    );
  }
}


