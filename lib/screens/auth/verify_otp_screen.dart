import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_circle/app_routes.dart';
import 'package:pet_circle/l10n/app_localizations.dart';
import 'package:pet_circle/services/otp_service.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/semantic/text_theme.dart';
import 'package:pet_circle/theme/tokens/spacing.dart';

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
  final List<FocusNode> _rawFocusNodes = List.generate(6, (_) => FocusNode());

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
    for (final node in _rawFocusNodes) {
      node.dispose();
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

  void _onKeyPressed(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
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
      try {
        await FirebaseAuth.instance.signInWithCustomToken(result.token!);
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _isVerifying = false;
          _error = 'Sign-in failed. Please try again.';
        });
        return;
      }
      if (!mounted) return;
      context.go(AppRoutes.authGate);
    } else {
      setState(() {
        _isVerifying = false;
        _error = result.error ?? AppLocalizations.of(context)!.verificationFailed;
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
      backgroundColor: c.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
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
          padding: const EdgeInsets.symmetric(horizontal: AppSpacingTokens.xl),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 393),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppSpacingTokens.md),
                  Align(
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: c.primaryLightest,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.mail_outline, size: 36, color: c.primary),
                    ),
                  ),
                  const SizedBox(height: AppSpacingTokens.lg),
                  Text(
                    l10n.enterVerificationCode,
                    style: AppSemanticTextStyles.title3.copyWith(
                      color: c.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacingTokens.sm),
                  Text.rich(
                    TextSpan(
                      style: AppSemanticTextStyles.body.copyWith(
                        color: c.textPrimary,
                      ),
                      children: [
                        TextSpan(text: l10n.enterTheCodeSentToLead),
                        TextSpan(
                          text: widget.email,
                          style: AppSemanticTextStyles.body.copyWith(
                            color: c.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacingTokens.xl),
                  if (_error != null) ...[
                    Text(
                      _error!,
                      style: AppSemanticTextStyles.caption.copyWith(
                        color: c.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacingTokens.md),
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(6, (index) {
                      return Padding(
                        padding: EdgeInsets.only(
                          right: index < 5 ? AppSpacingTokens.sm + 4 : 0,
                        ),
                        child: SizedBox(
                          width: 40,
                          height: 40,
                          child: KeyboardListener(
                            focusNode: _rawFocusNodes[index],
                            onKeyEvent: (event) => _onKeyPressed(index, event),
                            child: TextFormField(
                              controller: _controllers[index],
                              focusNode: _focusNodes[index],
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              textAlignVertical: TextAlignVertical.center,
                              maxLength: 1,
                              style: AppSemanticTextStyles.body.copyWith(
                                color: c.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: InputDecoration(
                                counterText: '',
                                filled: true,
                                fillColor: c.surface,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppRadiiTokens.sm,
                                  ),
                                  borderSide: BorderSide(color: c.divider),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppRadiiTokens.sm,
                                  ),
                                  borderSide: BorderSide(color: c.divider),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppRadiiTokens.sm,
                                  ),
                                  borderSide: BorderSide(
                                    color: c.primary,
                                    width: 2,
                                  ),
                                ),
                              ),
                              onChanged: (value) =>
                                  _onDigitChanged(index, value),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: AppSpacingTokens.lg),
                  if (_isVerifying)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacingTokens.sm,
                        ),
                        child: CircularProgressIndicator(color: c.primary),
                      ),
                    )
                  else
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed:
                            _otpCode.length == 6 ? _verifyOtp : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: c.primary,
                          foregroundColor: c.onPrimary,
                          disabledBackgroundColor: c.disabled,
                          disabledForegroundColor: c.textDisabled,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppRadiiTokens.xl,
                            ),
                          ),
                        ),
                        child: Text(
                          l10n.verifyCode,
                          style: AppSemanticTextStyles.button.copyWith(
                            color: c.onPrimary,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: AppSpacingTokens.md),
                  if (_isResending)
                    Center(
                      child: CircularProgressIndicator(color: c.primary),
                    )
                  else if (_canResend)
                    Center(
                      child: TextButton(
                        onPressed: _resendCode,
                        child: Text(
                          l10n.resendCode,
                          style: AppSemanticTextStyles.body.copyWith(
                            color: c.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    )
                  else
                    Text(
                      l10n.resendCodeInSeconds(_resendCooldown),
                      style: AppSemanticTextStyles.body.copyWith(
                        color: c.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  SizedBox(height: MediaQuery.sizeOf(context).height * 0.08),
                  Center(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: c.primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacingTokens.md,
                          vertical: AppSpacingTokens.sm,
                        ),
                        shape: const StadiumBorder(),
                      ),
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go(
                            widget.isSignup ? AppRoutes.signup : AppRoutes.login,
                          );
                        }
                      },
                      child: Text(
                        l10n.useDifferentEmail,
                        style: AppSemanticTextStyles.body.copyWith(
                          color: c.primary,
                          fontWeight: FontWeight.w500,
                        ),
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
