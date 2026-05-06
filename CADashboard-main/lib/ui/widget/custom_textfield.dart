import 'package:cadashboard/core/utils/colors.dart';
import 'package:cadashboard/core/services/api_text_localizer.dart';
import 'package:cadashboard/core/services/app_locale_controller.dart';
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
    final locale = Localizations.localeOf(context);
    final localizedHint = ApiTextLocalizer.localize(hint, locale: locale);

    return TextFormField(
      controller: controller,
      hintLocales: AppLocaleController.inputHintLocales(context),
      readOnly: readOnly == null ? false : readOnly!,
      style: const TextStyle(
        fontSize: 15,fontWeight: FontWeight.w600
      ),
      obscureText: visible == null ? false : visible!,
      cursorColor: Colors.black,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.all(15),
        hintText: localizedHint,
        labelText: localizedHint,
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
      validator: (value) {
        final res = onValidator?.call(value);
        if (res == null) return null;
        return res.toString();
      },
    );
  }
}


