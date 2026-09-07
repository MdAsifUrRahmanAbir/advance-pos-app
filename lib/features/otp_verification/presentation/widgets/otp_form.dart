import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/widgets/common/otp_input_field.dart';
import '../../../../core/widgets/common/primary_button.dart';
import '../../../../core/widgets/common/link_button.dart';

/// OTP boxes + resend countdown + Verify button + "Didn't receive code?"
/// prompt — bundled together because the countdown is shared state
/// between the "Resend OTP in mm:ss" line and the bottom resend link.
///
/// Purely presentational/UI-state only (digits typed, seconds left).
/// The real verify/resend calls are supplied by the caller via
/// [onVerify] / [onResend].
class OtpForm extends StatefulWidget {
  final bool loading;
  final int resendSeconds;
  final ValueChanged<String> onVerify;
  final VoidCallback? onResend;

  const OtpForm({
    super.key,
    required this.onVerify,
    this.onResend,
    this.loading = false,
    this.resendSeconds = 59,
  });

  @override
  State<OtpForm> createState() => _OtpFormState();
}

class _OtpFormState extends State<OtpForm> {
  String _code = '';
  Timer? _timer;
  late int _secondsLeft;

  @override
  void initState() {
    super.initState();
    _secondsLeft = widget.resendSeconds;
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft <= 0) {
        timer.cancel();
        return;
      }
      setState(() => _secondsLeft--);
    });
  }

  String get _formattedTime {
    final minutes = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _handleResend() {
    if (_secondsLeft > 0) return;
    widget.onResend?.call();
    setState(() => _secondsLeft = widget.resendSeconds);
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    final canResend = _secondsLeft <= 0;

    return Column(
      children: [
        OtpInputField(
          length: 6,
          onChanged: (value) => setState(() => _code = value),
        ),
        const SizedBox(height: AppSizes.lg),
        if (!canResend)
          RichText(
            text: TextSpan(
              style: TextStyle(fontSize: AppSizes.fontMd, color: context.appColors.textSecondary),
              children: [
                const TextSpan(text: AppStrings.resendOtpInPrefix),
                TextSpan(
                  text: _formattedTime,
                  style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        const SizedBox(height: AppSizes.xl),
        PrimaryButton(
          label: AppStrings.verifyAndProceed,
          loading: widget.loading,
          onPressed: _code.length == 6 ? () => widget.onVerify(_code) : null,
        ),
        const SizedBox(height: AppSizes.lg),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             Text(
              AppStrings.didntReceiveCode,
              style: TextStyle(fontSize: AppSizes.fontSm, color: context.appColors.textSecondary),
            ),
            LinkButton(
              label: AppStrings.resendOtp,
              fontSize: AppSizes.fontSm,
              color: canResend ? AppColors.primary : context.appColors.textHint,
              onPressed: canResend ? _handleResend : null,
            ),
          ],
        ),
      ],
    );
  }
}