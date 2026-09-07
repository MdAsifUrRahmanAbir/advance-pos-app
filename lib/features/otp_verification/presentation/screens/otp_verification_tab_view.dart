import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/common/custom_app_bar.dart';
import '../../../../core/widgets/utility/custom_snackbar.dart';
import '../../../../routes/route_names.dart';
import '../widgets/otp_header.dart';
import '../widgets/otp_form.dart';

class OtpVerificationTabView extends ConsumerWidget {
  const OtpVerificationTabView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Column(
        children: [
          const CustomAppBar(title: AppStrings.identityVerification),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSizes.xl),
                  child: Column(
                    children: [
                      const SizedBox(height: AppSizes.md),
                      const OtpHeader(),
                      const SizedBox(height: AppSizes.xl),
                      OtpForm(
                        onVerify: (code) {
                          // TODO: wire to otpControllerProvider.verify(code)
                          context.go(RouteNames.mainShell);
                        },
                        onResend: () => CustomSnackbar.show(context, 'OTP resent'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}