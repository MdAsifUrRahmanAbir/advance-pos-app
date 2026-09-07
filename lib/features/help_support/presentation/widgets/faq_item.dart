import 'package:flutter/material.dart';
import '../../../../core/widgets/common/faq_accordion_item.dart';

/// Single FAQ entry in the Help & Support screen. Thin wrapper over
/// [FaqAccordionItem] so the feature layer owns its own data shape
/// (question/answer pairs) without the core widget knowing about it.
class FaqItem extends StatelessWidget {
  final String question;
  final String answer;
  final bool initiallyExpanded;

  const FaqItem({
    super.key,
    required this.question,
    required this.answer,
    this.initiallyExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    return FaqAccordionItem(
      question: question,
      answer: answer,
      initiallyExpanded: initiallyExpanded,
    );
  }
}