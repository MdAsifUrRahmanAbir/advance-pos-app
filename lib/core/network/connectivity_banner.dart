import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template_test/core/constants/app_colors.dart';
import 'package:template_test/core/constants/app_sizes.dart';
import 'package:template_test/core/constants/app_strings.dart';

import 'connectivity_provider.dart';

/// Floating rounded "toast" pinned near the bottom of the screen, shown on
/// every screen in the app whenever [connectivityStatusProvider] is
/// false, and automatically dismissed the moment connectivity returns.
/// Mounted once in [PosApp]'s `builder`, so no per-screen wiring is needed.
class ConnectivityBanner extends ConsumerWidget {
  const ConnectivityBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isConnected = ref.watch(connectivityStatusProvider);
    final bottomInset = MediaQuery.paddingOf(context).bottom + 20;

    return Positioned(
      bottom: bottomInset + AppSizes.xxl,
      left: AppSizes.lg,
      right: AppSizes.lg,
      child: IgnorePointer(
        ignoring: isConnected,
        child: AnimatedSlide(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          offset: isConnected ? const Offset(0, 1.5) : Offset.zero,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 250),
            opacity: isConnected ? 0 : 1,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.sm + AppSizes.xs / 2),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.error.withValues(alpha: 0.35),
                      blurRadius: AppSizes.md,
                      offset: const Offset(0, AppSizes.xs),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.wifi_off_rounded, size: AppSizes.iconSm, color: AppColors.textWhite),
                    SizedBox(width: AppSizes.sm),
                    Flexible(
                      child: Text(
                        AppStrings.noInternetBannerMessage,
                        style: TextStyle(
                          color: AppColors.textWhite,
                          fontSize: AppSizes.fontSm,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.none,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}