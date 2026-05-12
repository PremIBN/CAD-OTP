import 'package:cadashboard/core/common/common_function.dart';
import 'package:cadashboard/core/model/client/std_code_model.dart';
import 'package:cadashboard/core/repository/login_repository.dart';
import 'package:cadashboard/core/utils/colors.dart';
import 'package:cadashboard/core/utils/iso_country_dial_fallback.dart';
import 'package:cadashboard/ui/screen/otp_login/otp_verify_screen.dart';
import 'package:cadashboard/ui/widget/custom_btn.dart';
import 'package:cadashboard/ui/widget/custom_navigate.dart';
import 'package:flutter/material.dart';

class OtpPhoneScreen extends StatefulWidget {
  const OtpPhoneScreen({super.key});

  @override
  State<OtpPhoneScreen> createState() => _OtpPhoneScreenState();
}

class _OtpPhoneScreenState extends State<OtpPhoneScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final ValueNotifier<bool> _loading = ValueNotifier(false);
  final LoginRepo _loginRepo = LoginRepo();

  List<StdCodeModel> _countries = [];
  int _selectedCountryIndex = 0;
  bool _countriesLoading = true;

  static StdCodeModel _fallbackIndia() {
    return StdCodeModel(
      stdCode: '91',
      countryCode: 'IN',
      codeValue: 91,
      codeId: 0,
      codeName: 'India',
      codeGroup: null,
      validationErrors: const [],
    );
  }

  /// Digits-only from API `STDCode` (matches web ddl value derived from `field.STDCode`).
  static String _stdDigitsOnly(StdCodeModel e) =>
      (e.stdCode ?? '').replaceAll(RegExp(r'[^0-9]'), '');

  StdCodeModel get _selectedCountry {
    if (_countries.isEmpty) return _fallbackIndia();
    final i = _selectedCountryIndex.clamp(0, _countries.length - 1);
    return _countries[i];
  }

  String get _dialDisplay => '+${_stdDigitsOnly(_selectedCountry)}';

  String get _countrySTDCode => _stdDigitsOnly(_selectedCountry);

  /// ISO 3166-1 alpha-2 for flag emoji: prefer API `CountryCode`, else infer from dial digits.
  static String? _iso2ForCountry(StdCodeModel e, String dialDigits) {
    final cc = (e.countryCode ?? '').trim().toUpperCase();
    if (cc.length == 2 && RegExp(r'^[A-Z]{2}$').hasMatch(cc)) return cc;
    if (dialDigits.isEmpty) return null;
    final matches = <String>[];
    for (final entry in kIso2ToDialDigits.entries) {
      if (entry.value == dialDigits) matches.add(entry.key);
    }
    if (matches.isEmpty) return null;
    if (matches.length == 1) return matches.first;
    final name = (e.codeName ?? '').toLowerCase();
    for (final m in matches) {
      if (m == 'US' && (name.contains('united state') || name.contains('usa'))) return 'US';
      if (m == 'CA' && name.contains('canada')) return 'CA';
      if (m == 'RU' && (name.contains('russia') || name.contains('россия'))) return 'RU';
      if (m == 'KZ' && (name.contains('kazakh') || name.contains('қаза'))) return 'KZ';
    }
    return matches.first;
  }

  /// Regional-indicator flag emoji; neutral glyph when unknown.
  static String _flagEmoji(String? iso2) {
    if (iso2 == null || iso2.length != 2) return '🌐';
    final a = iso2.codeUnitAt(0);
    final b = iso2.codeUnitAt(1);
    if (a < 0x41 || a > 0x5A || b < 0x41 || b > 0x5A) return '🌐';
    const base = 0x1F1E6;
    return String.fromCharCode(base + a - 0x41) + String.fromCharCode(base + b - 0x41);
  }

  static Widget _flagLeading(StdCodeModel e, String dialDigits, {required bool selected}) {
    final iso = _iso2ForCountry(e, dialDigits);
    final emoji = _flagEmoji(iso);
    return SizedBox(
      width: 36,
      child: Center(
        child: Text(
          emoji,
          style: TextStyle(
            fontSize: 24,
            height: 1,
            shadows: selected
                ? [Shadow(color: AppColor.background.withValues(alpha: 0.25), blurRadius: 2)]
                : null,
          ),
        ),
      ),
    );
  }

  /// Normalizes user input to "local digits only" expected by backend OTP login.
  ///
  /// Example (India):
  /// - Input: `+917507167775` or `917507167775` -> `7507167775`
  /// - Input: `07507167775` -> `7507167775`
  static String _normalizeMobileLocal({
    required String raw,
    required String countryStdDigits,
  }) {
    var digits = raw.trim().replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return digits;

    final std = countryStdDigits.trim();
    if (std.isNotEmpty) {
      if (digits.startsWith('00$std') && digits.length > ('00$std').length + 5) {
        digits = digits.substring(('00$std').length);
      } else if (digits.startsWith(std) && digits.length > std.length + 5) {
        // If user pasted country code into the number field, strip it.
        digits = digits.substring(std.length);
      }
    }

    // India-specific cleanup: backend expects 10 digits local mobile.
    if (std == '91') {
      if (digits.length == 11 && digits.startsWith('0')) {
        digits = digits.substring(1);
      }
      if (digits.length > 10) {
        // If still longer (e.g. leading country code not caught), keep last 10 digits.
        digits = digits.substring(digits.length - 10);
      }
    }

    return digits;
  }

  @override
  void initState() {
    super.initState();
    _loadCountries();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _loading.dispose();
    super.dispose();
  }

  Future<void> _loadCountries() async {
    setState(() => _countriesLoading = true);
    await _loginRepo.getAllCountryForLogin(
      success: (list) {
        if (!mounted) return;
        var idx = list.indexWhere((e) => _stdDigitsOnly(e) == '91');
        if (idx < 0) idx = 0;
        setState(() {
          _countries = list;
          _selectedCountryIndex = idx;
          _countriesLoading = false;
        });
      },
      failed: (message) {
        if (!mounted) return;
        setState(() {
          _countries = [_fallbackIndia()];
          _selectedCountryIndex = 0;
          _countriesLoading = false;
        });
        CommonFunction.showSnackBarLoginPageOnly(
          context: context,
          isError: true,
          message: '$message Using default country.',
        );
      },
    );
  }

  Future<void> _goToOtp() async {
    if (!_formKey.currentState!.validate()) return;

    final std = _countrySTDCode;
    final digitsOnly = _normalizeMobileLocal(raw: _phoneController.text, countryStdDigits: std);
    if (std.isEmpty) {
      CommonFunction.showSnackBarLoginPageOnly(
        context: context,
        isError: true,
        message: 'Please select a country / STD code.',
      );
      return;
    }

    // Keep UI consistent (avoid showing +91 + 91xxxxxxxxxx on next screen).
    _phoneController.text = digitsOnly;

    _loading.value = true;
    try {
      if (!mounted) return;
      await _loginRepo.generateLoginOtp(
        mobile: digitsOnly,
        countrySTDCode: std,
        success: (message) {
          if (!mounted) return;
          CommonFunction.showSnackBarLoginPageOnly(
            context: context,
            isError: false,
            message: message,
          );
          Navigator.push(
            context,
            cusNavigate(
              OtpVerifyScreen(
                contactNo: digitsOnly,
                dialCode: _dialDisplay,
                countrySTDCode: std,
              ),
            ),
          );
        },
        failed: (message) {
          if (!mounted) return;
          CommonFunction.showSnackBarLoginPageOnly(
            context: context,
            isError: true,
            message: message,
          );
        },
      );
    } catch (e) {
      if (!mounted) return;
      CommonFunction.showSnackBarLoginPageOnly(
        context: context,
        isError: true,
        message: 'Could not start OTP. Please try again.',
      );
    } finally {
      _loading.value = false;
    }
  }

  Future<void> _showCountryPicker() async {
    if (_countriesLoading || _countries.isEmpty) return;

    final picked = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.5,
          minChildSize: 0.28,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Material(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              color: Theme.of(context).colorScheme.surface,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Text(
                      'Select country',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.grey.shade900,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Scrollbar(
                      thumbVisibility: true,
                      thickness: 6,
                      radius: const Radius.circular(8),
                      controller: scrollController,
                      child: ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.only(bottom: 12),
                        itemCount: _countries.length,
                        itemBuilder: (context, i) {
                          final e = _countries[i];
                          final raw = (e.stdCode ?? '').trim();
                          final label = '$raw ( ${e.codeName ?? ''} )';
                          final dial = _stdDigitsOnly(e);
                          final selected =
                              i == _selectedCountryIndex.clamp(0, _countries.length - 1);
                          return ListTile(
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            leading: _flagLeading(e, dial, selected: selected),
                            title: Text(
                              label,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                                fontSize: 14,
                                color: selected ? AppColor.background : Colors.black87,
                                height: 1.25,
                              ),
                            ),
                            subtitle: Text(
                              '+$dial',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            trailing: selected
                                ? Icon(Icons.check_circle, color: AppColor.background, size: 22)
                                : null,
                            onTap: () => Navigator.pop(modalContext, i),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (picked != null && mounted) {
      setState(() => _selectedCountryIndex = picked);
    }
  }

  Widget _countrySelector() {
    if (_countriesLoading && _countries.isEmpty) {
      return const SizedBox(
        width: 72,
        height: 24,
        child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
      );
    }

    if (_countries.isEmpty) {
      return Text(_dialDisplay, style: const TextStyle(fontWeight: FontWeight.w700));
    }

    final dial = _stdDigitsOnly(_selectedCountry);

    return InkWell(
      onTap: _countriesLoading ? null : _showCountryPicker,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _flagEmoji(_iso2ForCountry(_selectedCountry, dial)),
              style: const TextStyle(fontSize: 20, height: 1),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                '+$dial',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
            ),
            Icon(Icons.arrow_drop_down, size: 22, color: Colors.grey.shade700),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Column(
                  children: [
                    SizedBox(height: size.height * 0.07),
                    const Text(
                      'Login with OTP',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColor.background,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Enter your mobile number and\nwe'll send you an OTP",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    SizedBox(height: size.height * 0.02),
                    SizedBox(
                      height: 190,
                      child: Center(
                        child: Image.asset(
                          'assets/images/otp_illustration.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Form(
                      key: _formKey,
                      child: Container(
                        height: 54,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          children: [
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 132),
                              child: _countrySelector(),
                            ),
                            const SizedBox(width: 4),
                            Container(
                              width: 1,
                              height: 28,
                              color: Colors.grey.shade300,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Enter Mobile Number',
                                  hintStyle: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                validator: (_) {
                                  final digits = _normalizeMobileLocal(
                                    raw: _phoneController.text,
                                    countryStdDigits: _countrySTDCode,
                                  );
                                  if (digits.isEmpty) return 'Please enter mobile number.';
                                  if (_countrySTDCode == '91' && digits.length != 10) {
                                    return 'Enter 10-digit mobile number.';
                                  }
                                  if (_countrySTDCode != '91' && digits.length < 6) {
                                    return 'Enter a valid mobile number.';
                                  }
                                  if (_countrySTDCode != '91' && digits.length > 15) {
                                    return 'Enter a valid mobile number.';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    ValueListenableBuilder<bool>(
                      valueListenable: _loading,
                      builder: (context, isLoading, child) {
                        return CusBtn(
                          btnName: 'Send OTP to What''s app',
                          loading: isLoading,
                          localizeText: false,
                          onTap: _goToOtp,
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.verified_user, size: 18, color: AppColor.logoColor.withValues(alpha: 0.9)),
                        const SizedBox(width: 8),
                        Text(
                          'Your number is safe with us',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Back to Login page',
                        style: TextStyle(
                          color: AppColor.background,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 4,
              left: 4,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                color: AppColor.background,
                tooltip: 'Back',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
