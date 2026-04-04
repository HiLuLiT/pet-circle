import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_circle/l10n/app_localizations.dart';
import 'package:pet_circle/services/otp_service.dart';
import 'package:pet_circle/theme/app_assets.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/semantic/text_theme.dart';
import 'package:pet_circle/theme/tokens/spacing.dart';
import 'package:pet_circle/widgets/primary_button.dart';

class VerifyOtpScreen extends StatefulWidget {
  const VerifyOtpScreen({
    super.key,
    required this.email,
    required this.isSignup,
    this.name,
  });

  final String email;
  final bool isSignup;
  final String? name;

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _isVerifying = false;
  bool _isResending = false;
  bool _canResend = false;
  int _resendCooldown = 60;
  Timer? _cooldownTimer;
  String? _error;

  @override
  void initState() {
    super.initState();
    _startCooldown();
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    _cooldownTimer?.cancel();
    super.dispose();
  }

  String get _otpCode => _controllers.map((c) => c.text).join();

  void _startCooldown() {
    setState(() {
      _canResend = false;
      _resendCooldown = 60;
    });

    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCooldown > 1) {
        setState(() => _resendCooldown--);
      } else {
        timer.cancel();
        setState(() => _canResend = true);
      }
    });
  }

  void _onDigitChanged(int index, String value) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    if (_otpCode.length == 6) {
      _verifyOtp();
    }
  }

  void _onKeyPressed(int index, RawKeyEvent event) {
    if (event is RawKeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _controllers[index - 1].clear();
      _focusNodes[index - 1].requestFocus();
    }
  }

  Future<void> _verifyOtp() async {
    final code = _otpCode;
    if (code.length != 6) return;

    setState(() {
      _isVerifying = true;
      _error = null;
    });

    final result = await OtpService.verifyOtp(
      email: widget.email,
      code: code,
    );

    if (!mounted) return;

    if (result.success && result.token != null) {
      await FirebaseAuth.instance.signInWithCustomToken(result.token!);
      if (!mounted) return;
      // Navigate to auth gate which handles post-auth routing
      context.go('/auth-gate');
    } else {
      setState(() {
        _isVerifying = false;
        _error = result.error ?? 'Verification failed';
        // Clear the code fields on error
        for (final c in _controllers) {
          c.clear();
        }
        _focusNodes[0].requestFocus();
      });
    }
  }

  Future<void> _resendCode() async {
    if (!_canResend) return;

    setState(() {
      _isResending = true;
      _error = null;
    });

    final result = await OtpService.sendOtp(
      email: widget.email,
      name: widget.name,
      isSignup: widget.isSignup,
    );

    if (!mounted) return;

    if (result.success) {
      _startCooldown();
      final l10n = AppLocalizations.of(context)!;
      final c = AppSemanticColors.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.verificationCodeSent),
          backgroundColor: c.info,
        ),
      );
    } else {
      setState(() => _error = result.error);
    }

    setState(() => _isResending = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = AppSemanticColors.of(context);

    return Scaffold(
      backgroundColor: c.primaryLightest,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: c.textPrimary),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacingTokens.lg),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),

                  // Logo
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacingTokens.sm),
                      decoration: BoxDecoration(
                        color: c.primaryLight,
                        shape: BoxShape.circle,
                      ),
                      child: SvgPicture.asset(
                        AppAssets.appLogo,
                        width: 60,
                        height: 60,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacingTokens.xl),

                  // Lock icon
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: c.background,
                        borderRadius: AppRadiiTokens.borderRadiusLg,
                      ),
                      child: Icon(
                        Icons.lock_outline,
                        size: 64,
                        color: c.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacingTokens.xl),

                  // Title
                  Text(
                    l10n.enterVerificationCode,
                    style: AppSemanticTextStyles.title2
                        .copyWith(color: c.textPrimary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacingTokens.md),

                  // Subtitle
                  Text(
                    l10n.weSentCodeTo,
                    style: AppSemanticTextStyles.body
                        .copyWith(color: c.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacingTokens.xs),
                  Text(
                    widget.email,
                    style: AppSemanticTextStyles.body.copyWith(
                      color: c.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacingTokens.xl),

                  // Error message
                  if (_error != null)
                    Container(
                      margin:
                          const EdgeInsets.only(bottom: AppSpacingTokens.md),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: c.error.withValues(alpha: 0.1),
                        borderRadius: AppRadiiTokens.borderRadiusSm,
                        border:
                            Border.all(color: c.error.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        _error!,
                        style:
                            AppSemanticTextStyles.body.copyWith(color: c.error),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  // OTP input fields
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(6, (index) {
                      return Container(
                        width: 48,
                        height: 56,
                        margin: EdgeInsets.only(
                          right: index < 5 ? AppSpacingTokens.sm : 0,
                        ),
                        child: RawKeyboardListener(
                          focusNode: FocusNode(),
                          onKey: (event) => _onKeyPressed(index, event),
                          child: TextFormField(
                            controller: _controllers[index],
                            focusNode: _focusNodes[index],
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            maxLength: 1,
                            style: AppSemanticTextStyles.title3.copyWith(
                              color: c.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: InputDecoration(
                              counterText: '',
                              filled: true,
                              fillColor: c.background,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(color: c.primary, width: 2),
                              ),
                            ),
                            onChanged: (value) =>
                                _onDigitChanged(index, value),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: AppSpacingTokens.xl),

                  // Verify button
                  if (_isVerifying)
                    Center(
                      child: CircularProgressIndicator(color: c.primary),
                    )
                  else
                    PrimaryButton(
                      label: l10n.verifyCode,
                      onPressed:
                          _otpCode.length == 6 ? _verifyOtp : null,
                      backgroundColor: c.primary,
                    ),

                  const SizedBox(height: AppSpacingTokens.lg),

                  // Resend code
                  if (_isResending)
                    Center(
                      child: CircularProgressIndicator(color: c.primary),
                    )
                  else
                    Center(
                      child: TextButton(
                        onPressed: _canResend ? _resendCode : null,
                        child: Text(
                          _canResend
                              ? l10n.resendCode
                              : l10n.resendCodeInSeconds(_resendCooldown),
                          style: AppSemanticTextStyles.body.copyWith(
                            color: _canResend ? c.primary : c.textTertiary,
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: AppSpacingTokens.md),

                  // Use different email
                  Center(
                    child: TextButton(
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go(widget.isSignup ? '/signup' : '/login');
                        }
                      },
                      child: Text(
                        l10n.useDifferentEmail,
                        style: AppSemanticTextStyles.body
                            .copyWith(color: c.textSecondary),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
