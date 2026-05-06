import 'package:cadashboard/core/services/api_text_localizer.dart';
import 'package:cadashboard/core/utils/colors.dart';
import 'package:flutter/material.dart';

class CusBtn extends StatefulWidget {
  final String btnName;
  final bool loading;
  final bool? btnColor;
  final Color? bGColor;
  final Color? textColor;
  final Color? flashColor;
  final int flashDurationMs;
  final double borderRadius;
  final bool Function()? shouldFlash;
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
    this.flashColor,
    this.flashDurationMs = 170,
    this.borderRadius = 30,
    this.shouldFlash,
    this.localizeText = true,
  });

  @override
  State<CusBtn> createState() => _CusBtnState();
}

class _CusBtnState extends State<CusBtn> {
  bool _flashActive = false;

  Future<void> _handleTap() async {
    if (widget.loading) return;
    final bool canFlash = widget.shouldFlash?.call() ?? true;
    if (widget.flashColor != null && canFlash) {
      setState(() {
        _flashActive = true;
      });
      await Future.delayed(Duration(milliseconds: widget.flashDurationMs));
      if (!mounted) return;
      setState(() {
        _flashActive = false;
      });
    }
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final Color baseColor = widget.bGColor ?? (widget.btnColor == true ? Colors.white : AppColor.background);
    final Color currentColor = _flashActive ? (widget.flashColor ?? baseColor) : baseColor;

    return GestureDetector(
      onTap: _handleTap,
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
        child: Container(
          height: 50,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: currentColor,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: const [BoxShadow(blurStyle: BlurStyle.outer)],
          ),
          child: widget.loading == true
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : Text(
                  widget.localizeText
                      ? ApiTextLocalizer.localize(widget.btnName, locale: Localizations.localeOf(context))
                      : widget.btnName,
                  style: TextStyle(
                    color: widget.textColor ?? (widget.btnColor == true ? AppColor.background : Colors.white),
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                  ),
                ),
        ),
      ),
    );
  }
}
