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
        final l10n = AppLocalizations.of(context)!;
        setState(() {
          _isVerifying = false;
          _error = l10n.signInFailedRetry;
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
      backgroundColor: c.background,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(32, 48, 32, 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 393),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: c.primaryGhost,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.mail_outline, size: 36, color: c.primary),
                  ),
                  const SizedBox(height: AppSpacingTokens.sm + 4),
                  Text(
                    l10n.enterVerificationCode,
                    style: AppSemanticTextStyles.headingH1.copyWith(
                      color: c.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacingTokens.sm),
                  SizedBox(
                    width: 280,
                    child: Text.rich(
                      TextSpan(
                        style: AppSemanticTextStyles.labelLRegular.copyWith(
                          color: c.textSecondary,
                        ),
                        children: [
                          TextSpan(text: l10n.enterTheCodeSentToLead),
                          TextSpan(
                            text: widget.email,
                            style: AppSemanticTextStyles.labelLBold.copyWith(
                              color: c.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: AppSpacingTokens.pcXl),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(6, (index) {
                      return SizedBox(
                        width: 44,
                        height: 54,
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
                            // counterText: '' alone still reserves the
                            // subtext row's layout height, shrinking the
                            // usable vertical space in this fixed 54px box
                            // and making the digit look smaller/off-center
                            // than the Figma spec. buildCounter fully drops
                            // the reserved space.
                            buildCounter: (
                              context, {
                              required currentLength,
                              required isFocused,
                              maxLength,
                            }) =>
                                null,
                            style: AppSemanticTextStyles.headingH2.copyWith(
                              color: c.textPrimary,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: c.surface,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                              // DS text inputs are borderless on idle —
                              // this OTP box is a distinct fixed-size
                              // component (not the shared labeled-field
                              // pattern), so it keeps its own decoration
                              // but drops the idle divider border.
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  AppRadiiTokens.pcField,
                                ),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  AppRadiiTokens.pcField,
                                ),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  AppRadiiTokens.pcField,
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
                      );
                    }),
                  ),
                  const SizedBox(height: AppSpacingTokens.pcXl),
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
                    PrimaryButton(
                      label: l10n.verifyCode,
                      onPressed: _otpCode.length == 6 ? _verifyOtp : null,
                    ),
                  const SizedBox(height: AppSpacingTokens.md + 4),
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
                          style: AppSemanticTextStyles.labelMSemibold.copyWith(
                            color: c.primary,
                          ),
                        ),
                      ),
                    )
                  else
                    Text(
                      l10n.resendCodeInSeconds(_resendCooldown),
                      style: AppSemanticTextStyles.pcLabelMuted.copyWith(
                        color: c.textTertiary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  const SizedBox(height: AppSpacingTokens.sm + 4),
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
                        style: AppSemanticTextStyles.labelMSemibold.copyWith(
                          color: c.primary,
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
