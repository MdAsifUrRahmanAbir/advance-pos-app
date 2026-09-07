import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/onboarding_model.dart';

/// Onboarding slide content. Update titles/descriptions/imagePaths here
/// to change what appears in the carousel — the UI widgets just render
/// whatever this list provides.
class OnboardingController extends Notifier<List<OnboardingModel>> {
  @override
  List<OnboardingModel> build() {
    return const [
      OnboardingModel(
        title: 'Analyze Your Performance',
        description:
        'High-density data metrics and operational insights tailored specifically for growing global enterprises.',
        imagePath: 'assets/images/onboarding_analytics.png',
      ),
      OnboardingModel(
        title: 'Manage Inventory in Real Time',
        description: 'Track stock levels, transfers, and reorder points across every warehouse from one screen.',
        imagePath: 'assets/images/onboarding_inventory.png',
      ),
      OnboardingModel(
        title: 'Move Faster, Every Day',
        description: 'Streamlined workflows help your whole team close orders and tasks without the busywork.',
        imagePath: 'assets/images/onboarding_speed.png',
      ),
    ];
  }
}

final onboardingControllerProvider =
NotifierProvider<OnboardingController, List<OnboardingModel>>(OnboardingController.new);