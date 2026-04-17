import 'package:cadashboard/core/services/api_text_localizer.dart';
import 'package:cadashboard/core/services/app_locale_controller.dart';
import 'package:cadashboard/core/services/app_locale_service.dart';
import 'package:cadashboard/l10n/app_localizations.dart';
import 'package:cadashboard/ui/widget/language_region_art.dart';
import 'package:flutter/material.dart';

class LanguageSelectionSheet {
  static Future<void> show(BuildContext context, {bool dismissible = true}) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: dismissible,
      enableDrag: dismissible,
      showDragHandle: dismissible,
      backgroundColor: const Color(0xFFF2F4F7),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _LanguageSelectionBody(requireContinue: !dismissible),
    );
  }

  static Future<void> showIfNeeded(BuildContext context) async {
    final code = await AppLocaleService.loadLanguageCode();
    if (code != null) return;
    if (!context.mounted) return;
    await show(context, dismissible: false);
  }
}

class _LanguageOption {
  const _LanguageOption(this.code, this.label);
  final String code;
  final String label;
}

class _LanguageSelectionBody extends StatefulWidget {
  const _LanguageSelectionBody({required this.requireContinue});

  /// When true (first-launch flow), user must tap Continue. When false, tap applies and closes.
  final bool requireContinue;

  @override
  State<_LanguageSelectionBody> createState() => _LanguageSelectionBodyState();
}

class _LanguageSelectionBodyState extends State<_LanguageSelectionBody> {
  String? _selected;

  static const _options = <_LanguageOption>[
    _LanguageOption('en', 'English'),
    _LanguageOption('hi', 'हिंदी (Hindi)'),
    _LanguageOption('mr', 'मराठी (Marathi)'),
    _LanguageOption('gu', 'ગુજરાતી (Gujarati)'),
    _LanguageOption('kn', 'ಕನ್ನಡ (Kannada)'),
    _LanguageOption('ta', 'தமிழ் (Tamil)'),
    _LanguageOption('te', 'తెలుగు (Telugu)'),
  ];

  static const _grayscaleMatrix = <double>[
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0, 0, 0, 1, 0,
  ];

  @override
  void initState() {
    super.initState();
    _selected = AppLocaleController.locale.value?.languageCode ?? 'en';
  }

  Future<void> _applyAndClose(String code) async {
    ApiTextLocalizer.clearCache();
    await AppLocaleController.setLanguageCode(code);
    if (!context.mounted) return;
    Navigator.pop(context);
  }

  Future<void> _onSelect(String code) async {
    setState(() => _selected = code);
    if (!widget.requireContinue) {
      await _applyAndClose(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final accent = scheme.primary;

    const selectedFill = Color(0xFFE8F4FC);
    const selectedBorder = Color(0xFF1E88E5);
    const cardMuted = Color(0xFFE4E7EC);

    return SafeArea(
      child: FractionallySizedBox(
        heightFactor: widget.requireContinue ? 0.9 : 0.85,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n?.languageSelectionTitle ?? 'Select Language',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF111418),
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Choose your preferred language',
                style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.35,
                  color: const Color(0xFF5C6370),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: _options.length,
                  itemBuilder: (context, i) {
                    final opt = _options[i];
                    final selected = _selected == opt.code;
                    return Padding(
                      padding: EdgeInsets.only(bottom: i == _options.length - 1 ? 0 : 8),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => _onSelect(opt.code),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            curve: Curves.easeOutCubic,
                            height: 82,
                            padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
                            decoration: BoxDecoration(
                              color: selected ? selectedFill : cardMuted,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: selected ? selectedBorder : Colors.transparent,
                                width: 1.5,
                              ),
                              boxShadow: selected
                                  ? [
                                      BoxShadow(
                                        color: selectedBorder.withValues(alpha: 0.12),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              children: [
                                _SelectionDot(
                                  selected: selected,
                                  activeColor: const Color(0xFFE53935),
                                  inactiveColor: const Color(0xFF9AA0A6),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    opt.label,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF1B1F24),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 108,
                                  height: 68,
                                  child: ClipRect(
                                    clipBehavior: Clip.hardEdge,
                                    child: OverflowBox(
                                      maxWidth: 130,
                                      alignment: Alignment.centerRight,
                                      child: Transform.translate(
                                        offset: const Offset(12, 0),
                                        child: selected
                                            ? LanguageRegionArt(
                                                languageCode: opt.code,
                                                selected: true,
                                                accent: accent,
                                              )
                                            : ColorFiltered(
                                                colorFilter: const ColorFilter.matrix(_grayscaleMatrix),
                                                child: LanguageRegionArt(
                                                  languageCode: opt.code,
                                                  selected: false,
                                                  accent: accent,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (widget.requireContinue) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: _selected == null
                        ? null
                        : () async {
                            ApiTextLocalizer.clearCache();
                            await AppLocaleController.setLanguageCode(_selected);
                            if (!context.mounted) return;
                            Navigator.pop(context);
                          },
                    child: Text(l10n?.continueText ?? 'Continue'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectionDot extends StatelessWidget {
  const _SelectionDot({
    required this.selected,
    required this.activeColor,
    required this.inactiveColor,
  });

  final bool selected;
  final Color activeColor;
  final Color inactiveColor;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? activeColor : inactiveColor,
          width: selected ? 2.2 : 2,
        ),
        color: selected ? activeColor.withValues(alpha: 0.12) : Colors.transparent,
      ),
      child: selected
          ? Center(
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: activeColor,
                ),
              ),
            )
          : null,
    );
  }
}
