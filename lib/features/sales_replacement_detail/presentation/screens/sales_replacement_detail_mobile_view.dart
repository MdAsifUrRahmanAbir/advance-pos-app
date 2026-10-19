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
import '../controllers/sales_replacement_detail_controller.dart';
import '../states/sales_replacement_detail_format.dart';
import '../states/sales_replacement_detail_skeleton_data.dart';
import '../widgets/sales_replacement_detail_actions.dart';
import '../widgets/sales_replacement_info_card.dart';
import '../widgets/sales_replacement_payment_card.dart';
import '../widgets/sales_replacement_replacement_products_card.dart';
import '../widgets/sales_replacement_returned_products_card.dart';

class SalesReplacementDetailMobileView extends ConsumerWidget {
  final String returnBillNo;

  const SalesReplacementDetailMobileView({super.key, required this.returnBillNo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = salesReplacementDetailControllerProvider(returnBillNo);
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
          ref.read(provider).errorMessage ?? AppStrings.repdLoadFailed,
          error: true,
        );
      }
    }

    void share(Rect? origin) {
      if (data == null) return;
      SharePlus.instance.share(
        ShareParams(
          text: SalesReplacementDetailFormat.shareText(data),
          subject: AppStrings.repdShareSubject(
            data.resultDataReturn.returnBillNo,
          ),
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
              CustomSnackbar.show(context, AppStrings.technicalDetailsCopied);
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
                child: const Text(AppStrings.viewTechnicalDetails),
              ),
            ),
        ],
      );
    } else {
      final shown = data ?? SalesReplacementDetailSkeletonData.data;
      body = CustomRefreshWrapper(
        onRefresh: refresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSizes.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SalesReplacementInfoCard(data: shown),
              const SizedBox(height: AppSizes.md),
              SalesReplacementReturnedProductsCard(data: shown),
              const SizedBox(height: AppSizes.md),
              SalesReplacementReplacementProductsCard(data: shown),
              const SizedBox(height: AppSizes.md),
              SalesReplacementPaymentCard(data: shown),
            ],
          ).skeletonizer(enabled: isSkeleton),
        ),
      );
    }

    return Column(
      children: [
        CustomAppBar(
          title: AppStrings.repdTitle,
          onBackTap: () => context.pop(),
        ),
        Expanded(child: body),
        if (data != null) SalesReplacementDetailActions(onShare: share),
      ],
    );
  }
}