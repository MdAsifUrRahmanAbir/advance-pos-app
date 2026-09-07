import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template_test/core/utils/responsive.dart';
import 'otp_verification_mobile_view.dart';
import 'otp_verification_tab_view.dart';

class OtpVerificationScreen extends ConsumerWidget {
  const OtpVerificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Responsive(
        mobile: const OtpVerificationMobileView(),
        tablet: const OtpVerificationTabView(),
      ),
    );
  }
}
