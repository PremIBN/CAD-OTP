import 'package:cadashboard/core/utils/colors.dart';
import 'package:cadashboard/core/services/api_text_localizer.dart';
import 'package:flutter/material.dart';

class CusBtn extends StatelessWidget {

  final String btnName;
  final bool loading;
  final bool? btnColor;
  final Color? bGColor;
  final Color? textColor;
  final bool localizeText;
  final VoidCallback onTap;

  const CusBtn({
    super.key,
    required this.btnName,
    required this.onTap,
    this.loading = false,
    this.btnColor = false,
    this.bGColor,
    this.textColor,
    this.localizeText = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),

        child: Container(
          height: 50,width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: bGColor ?? (btnColor == true ? Colors.white : AppColor.background),
            borderRadius: BorderRadius.circular(25),
            boxShadow: const [BoxShadow(blurStyle: BlurStyle.outer)]
          ),
          child: loading == true
              ? const Center(child: CircularProgressIndicator(color: Colors.white,))
              : Text(
                  localizeText
                      ? ApiTextLocalizer.localize(btnName, locale: Localizations.localeOf(context))
                      : btnName,
                  style: TextStyle(
                    color: textColor ?? (btnColor == true ? AppColor.background : Colors.white),
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                  ),
                ),
        ),
      ),
    );
  }
}
