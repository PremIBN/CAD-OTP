import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Decorative skyline-style art per app locale (not geographically exact).
class LanguageRegionArt extends StatelessWidget {
  const LanguageRegionArt({
    super.key,
    required this.languageCode,
    required this.selected,
    required this.accent,
  });

  final String languageCode;
  final bool selected;
  final Color accent;

  static const _assetByLanguage = <String, String>{
    'en': 'assets/images/language/en_skyline.png',
    'gu': 'assets/images/language/gu_icon.png',
    'hi': 'assets/images/language/hi_icon.png',
    'kn': 'assets/images/language/kn_icon.png',
    'mr': 'assets/images/language/mr_icon.png',
    'ta': 'assets/images/language/ta_icon.png',
    'te': 'assets/images/language/te_icon.png',
  };

  @override
  Widget build(BuildContext context) {
    final assetPath = _assetByLanguage[languageCode];
    if (assetPath != null) {
      return SizedBox(
        width: 120,
        height: 72,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Image.asset(
            assetPath,
            fit: BoxFit.contain,
            alignment: Alignment.center,
            errorBuilder: (context, error, _) => CustomPaint(
              painter: _RegionPainter(code: languageCode, selected: selected, accent: accent),
              size: const Size(120, 72),
            ),
          ),
        ),
      );
    }
    return CustomPaint(
      painter: _RegionPainter(
        code: languageCode,
        selected: selected,
        accent: accent,
      ),
      size: const Size(120, 72),
    );
  }
}

class _RegionPainter extends CustomPainter {
  _RegionPainter({
    required this.code,
    required this.selected,
    required this.accent,
  });

  final String code;
  final bool selected;
  final Color accent;

  Color get _ink => selected ? const Color(0xFF1A237E) : const Color(0xFF424242);
  Color get _fill2 => selected ? const Color(0xFFE53935) : _ink.withValues(alpha: 0.35);
  Color get _fill3 => selected ? const Color(0xFFFFC107) : _ink.withValues(alpha: 0.25);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final baseY = h * 0.88;

    void ground() {
      final p = Paint()
        ..color = _ink.withValues(alpha: 0.15)
        ..strokeWidth = 1.2;
      canvas.drawLine(Offset(0, baseY), Offset(w, baseY), p);
    }

    ground();

    switch (code) {
      case 'en':
        _paintEnglish(canvas, w, h, baseY);
        break;
      case 'hi':
        _paintHindi(canvas, w, h, baseY);
        break;
      case 'mr':
        _paintMarathi(canvas, w, h, baseY);
        break;
      case 'gu':
        _paintGujarati(canvas, w, h, baseY);
        break;
      case 'kn':
        _paintKannada(canvas, w, h, baseY);
        break;
      case 'ta':
        _paintTamil(canvas, w, h, baseY);
        break;
      case 'te':
        _paintTelugu(canvas, w, h, baseY);
        break;
      default:
        _paintGeneric(canvas, w, h, baseY);
    }
  }

  void _paintEnglish(Canvas canvas, double w, double h, double baseY) {
    final tower = Path()
      ..moveTo(w * 0.72, baseY)
      ..lineTo(w * 0.72, h * 0.12)
      ..lineTo(w * 0.78, h * 0.18)
      ..lineTo(w * 0.78, baseY)
      ..close();
    canvas.drawPath(tower, Paint()..color = _fill2);

    final wheel = Paint()
      ..color = accent.withValues(alpha: selected ? 0.9 : 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(Offset(w * 0.35, h * 0.42), h * 0.22, wheel);
    for (var i = 0; i < 8; i++) {
      final a = i * 3.14159 / 4;
      canvas.drawLine(
        Offset(w * 0.35, h * 0.42),
        Offset(w * 0.35 + h * 0.2 * math.cos(a), h * 0.42 + h * 0.2 * math.sin(a)),
        wheel,
      );
    }

    final bridge = Paint()..color = _ink.withValues(alpha: selected ? 0.85 : 0.45);
    canvas.drawRect(Rect.fromLTWH(w * 0.08, baseY - h * 0.08, w * 0.22, h * 0.08), bridge);
    canvas.drawRect(Rect.fromLTWH(w * 0.52, baseY - h * 0.08, w * 0.18, h * 0.08), bridge);
  }

  void _paintHindi(Canvas canvas, double w, double h, double baseY) {
    final arch = Path()
      ..moveTo(w * 0.2, baseY)
      ..quadraticBezierTo(w * 0.42, h * 0.25, w * 0.64, baseY);
    canvas.drawPath(
      arch,
      Paint()
        ..color = _ink.withValues(alpha: selected ? 0.9 : 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5,
    );

    canvas.drawRect(Rect.fromLTWH(w * 0.38, h * 0.35, w * 0.08, baseY - h * 0.35), Paint()..color = _fill2);
    canvas.drawRect(Rect.fromLTWH(w * 0.12, h * 0.5, w * 0.06, baseY - h * 0.5), Paint()..color = _fill3);
    canvas.drawRect(Rect.fromLTWH(w * 0.78, h * 0.48, w * 0.08, baseY - h * 0.48), Paint()..color = _ink.withValues(alpha: 0.5));
  }

  void _paintMarathi(Canvas canvas, double w, double h, double baseY) {
    final arch = Path()
      ..moveTo(w * 0.18, baseY)
      ..quadraticBezierTo(w * 0.48, h * 0.18, w * 0.82, baseY);
    canvas.drawPath(
      arch,
      Paint()
        ..color = accent.withValues(alpha: selected ? 0.85 : 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );
    canvas.drawCircle(Offset(w * 0.48, h * 0.52), h * 0.06, Paint()..color = _fill2);
  }

  void _paintGujarati(Canvas canvas, double w, double h, double baseY) {
    for (var i = 0; i < 5; i++) {
      final left = w * 0.15 + i * w * 0.14;
      final stepH = h * (0.25 + i * 0.1);
      canvas.drawRect(
        Rect.fromLTWH(left, baseY - stepH, w * 0.1, stepH),
        Paint()..color = i.isEven ? _fill3 : _ink.withValues(alpha: selected ? 0.7 : 0.35),
      );
    }
  }

  void _paintKannada(Canvas canvas, double w, double h, double baseY) {
    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.12, h * 0.32, w * 0.76, baseY - h * 0.32),
      const Radius.circular(3),
    );
    canvas.drawRRect(body, Paint()..color = accent.withValues(alpha: selected ? 0.35 : 0.2));

    for (var i = 0; i < 7; i++) {
      final x = w * 0.16 + i * w * 0.095;
      canvas.drawRect(Rect.fromLTWH(x, h * 0.22, w * 0.05, h * 0.12), Paint()..color = _ink.withValues(alpha: 0.55));
    }
    canvas.drawRect(Rect.fromLTWH(w * 0.4, h * 0.12, w * 0.2, h * 0.14), Paint()..color = _fill2.withValues(alpha: selected ? 1 : 0.4));
  }

  void _paintTamil(Canvas canvas, double w, double h, double baseY) {
    final tiers = 5;
    for (var i = 0; i < tiers; i++) {
      final tw = w * (0.35 + i * 0.1);
      final left = w * 0.5 - tw / 2;
      final top = h * (0.15 + i * 0.1);
      canvas.drawRect(
        Rect.fromLTWH(left, top, tw, baseY - top),
        Paint()..color = i == 0 ? _fill2 : _ink.withValues(alpha: selected ? 0.75 - i * 0.1 : 0.35),
      );
    }
  }

  void _paintTelugu(Canvas canvas, double w, double h, double baseY) {
    final sq = Rect.fromCenter(center: Offset(w * 0.5, h * 0.58), width: w * 0.38, height: h * 0.38);
    canvas.drawRect(sq, Paint()..color = _fill3.withValues(alpha: selected ? 0.9 : 0.35));

    for (final ox in [-1, 1]) {
      for (final oy in [-1, 1]) {
        final c = Offset(w * 0.5 + ox * w * 0.22, h * 0.58 + oy * h * 0.18);
        canvas.drawRect(
          Rect.fromCenter(center: c, width: w * 0.07, height: baseY - c.dy),
          Paint()..color = _fill2.withValues(alpha: selected ? 1 : 0.4),
        );
      }
    }
  }

  void _paintGeneric(Canvas canvas, double w, double h, double baseY) {
    canvas.drawCircle(Offset(w * 0.5, h * 0.45), h * 0.25, Paint()..color = accent.withValues(alpha: 0.25));
    canvas.drawRect(Rect.fromLTWH(w * 0.35, h * 0.45, w * 0.3, baseY - h * 0.45), Paint()..color = _ink.withValues(alpha: 0.4));
  }

  @override
  bool shouldRepaint(covariant _RegionPainter oldDelegate) {
    return oldDelegate.code != code || oldDelegate.selected != selected || oldDelegate.accent != accent;
  }
}
