// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';

class CusDropDown extends StatelessWidget {

  final String label;
  final String hint;
  final double? radius;
  final dynamic dropDownValue;
  final List<DropdownMenuItem> items;
  final ValueChanged? onChanged;
  final DropdownButtonBuilder? selectedItemBuilder;
  FormFieldValidator? validator;
  VoidCallback? onTap;

  CusDropDown({super.key, required this.label, this.dropDownValue, required this.items, this.onChanged, this.selectedItemBuilder, this.validator, required this.hint, this.onTap, this.radius});

  @override
  Widget build(BuildContext context) {

    OutlineInputBorder inputBorder = OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius ?? 25),
        borderSide: const BorderSide(width: 1)
    );
    OutlineInputBorder errorInputBorder = OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius ?? 25),
        borderSide: const BorderSide(width: 1,color: Colors.red)
    );


    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,style:  const TextStyle(fontWeight: FontWeight.w800,fontSize: 15),),
        const SizedBox(height: 10),
        DropdownButtonFormField(
          isExpanded: true,
          value: dropDownValue,
          borderRadius: BorderRadius.circular(radius ?? 25),
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: Colors.black87,
          ),
          decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(10),
              enabledBorder: inputBorder,
              focusedBorder: inputBorder,
              errorBorder: errorInputBorder,
              focusedErrorBorder: errorInputBorder,
              errorStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              border: const OutlineInputBorder(
                  borderSide: BorderSide.none
              )
          ),
          menuMaxHeight: 400,
          hint: Text(
            hint,
            style: const TextStyle(
              color: Colors.black38,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          items: items,
          onChanged: onChanged,
          selectedItemBuilder: selectedItemBuilder,
          onSaved: (newValue) {},
          validator: validator,
          onTap: onTap,
        ),
        const SizedBox(height: 15)
      ],
    );
  }
}
