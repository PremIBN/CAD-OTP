import 'package:cadashboard/core/common/common_function.dart';
import 'package:cadashboard/core/utils/colors.dart';
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
  String _dialCode = '+91';

  @override
  void dispose() {
    _phoneController.dispose();
    _loading.dispose();
    super.dispose();
  }

  String _normalizeToE164India(String input) {
    final digits = input.replaceAll(RegExp(r'[^0-9+]'), '');
    if (digits.startsWith('+')) return digits;
    // Minimal assumption for now: India numbers.
    // You can replace this later with a country picker.
    if (digits.length == 10) return '+91$digits';
    if (digits.startsWith('91') && digits.length == 12) return '+$digits';
    return digits; // fallback; Firebase will error and we'll show message.
  }

  Future<void> _goToOtp() async {
    if (!_formKey.currentState!.validate()) return;

    final digitsOnly = _phoneController.text.trim().replaceAll(RegExp(r'[^0-9]'), '');
    final e164 = _dialCode == '+91'
        ? _normalizeToE164India(digitsOnly)
        : '$_dialCode$digitsOnly';
    _loading.value = true;
    try {
      if (!mounted) return;
      Navigator.push(
        context,
        cusNavigate(OtpVerifyScreen(phoneE164: e164)),
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
                // Extra top space so the title sits lower/more centered
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

                // Illustration
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
                        // Country selector (simple for now; extend later)
                        DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _dialCode,
                            items: const [
                              DropdownMenuItem(
                                value: '+91',
                                child: Row(
                                  children: [
                                    Text('🇮🇳', style: TextStyle(fontSize: 16)),
                                    SizedBox(width: 8),
                                    Text('+91', style: TextStyle(fontWeight: FontWeight.w700)),
                                  ],
                                ),
                              ),
                            ],
                            onChanged: (v) {
                              if (v == null) return;
                              setState(() => _dialCode = v);
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
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
                              final digits = _phoneController.text.trim().replaceAll(RegExp(r'[^0-9]'), '');
                              if (digits.isEmpty) return 'Please enter mobile number.';
                              if (_dialCode == '+91' && digits.length != 10) return 'Enter 10-digit mobile number.';
                              if (digits.length < 6) return 'Enter a valid mobile number.';
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

