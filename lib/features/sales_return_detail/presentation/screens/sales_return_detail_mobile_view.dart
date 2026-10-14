import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/technical_error_screen.dart';
import '../../../../core/widgets/common/custom_app_bar.dart';
import '../../../../core/widgets/utility/custom_refresh_wrapper.dart';
import '../../../../core/widgets/utility/custom_snackbar.dart';
import '../../../../core/widgets/utility/error_state.dart';
import '../../../../core/widgets/utility/shimmer_extension.dart';
import '../controllers/sales_return_detail_controller.dart';
import '../states/sales_return_detail_format.dart';
import '../states/sales_return_detail_skeleton_data.dart';
import '../widgets/sales_return_detail_actions.dart';
import '../widgets/sales_return_info_card.dart';
import '../widgets/sales_return_products_card.dart';

class SalesReturnDetailMobileView extends ConsumerWidget {
  final String returnBillNo;

  const SalesReturnDetailMobileView({super.key, required this.returnBillNo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = salesReturnDetailControllerProvider(returnBillNo);
    final state = ref.watch(provider);
    final controller = ref.read(provider.notifier);

    final data = state.detail?.resultData;
    final isSkeleton = data == null && state.isLoading;
    final hasError =
        data == null && !state.isLoading && state.errorMessage != null;

    Future<void> refresh() async {
      final ok = await controller.refresh();
      if (!ok && context.mounted) {
        CustomSnackbar.show(
          context,
          ref.read(provider).errorMessage ?? AppStrings.srdLoadFailed,
          error: true,
        );
      }
    }

    void share(Rect? origin) {
      if (data == null) return;
      SharePlus.instance.share(
        ShareParams(
          text: SalesReturnDetailFormat.shareText(data),
          subject: AppStrings.srdShareSubject(data.returnInfo.returnBillNo),
          sharePositionOrigin: origin,
        ),
      );
    }

    void viewTechnicalDetails() {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => TechnicalErrorScreen(
            errorDetails: state.technicalDetails ?? '',
            onRetry: () {
              Navigator.of(context).pop();
              controller.load();
            },
            onReportIssue: () {
              Clipboard.setData(
                ClipboardData(text: state.technicalDetails ?? ''),
              );
              CustomSnackbar.show(context, AppStrings.srdTechnicalCopied);
            },
          ),
        ),
      );
    }

    final Widget body;
    if (hasError) {
      body = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: ErrorState(
              message: state.errorMessage!,
              onRetry: controller.load,
            ),
          ),
          if (state.technicalDetails != null)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.md),
              child: TextButton(
                onPressed: viewTechnicalDetails,
                child: const Text(AppStrings.srdViewTechnicalDetails),
              ),
            ),
        ],
      );
    } else {
      final shown = data ?? SalesReturnDetailSkeletonData.data;
      body = CustomRefreshWrapper(
        onRefresh: refresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSizes.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SalesReturnInfoCard(data: shown),
              const SizedBox(height: AppSizes.md),
              SalesReturnProductsCard(data: shown),
            ],
          ).skeletonizer(enabled: isSkeleton),
        ),
      );
    }

    return Column(
      children: [
        CustomAppBar(
          title: AppStrings.srdTitle,
          onBackTap: () => context.pop(),
        ),
        Expanded(child: body),
        if (data != null) SalesReturnDetailActions(onShare: share),
      ],
    );
  }
}