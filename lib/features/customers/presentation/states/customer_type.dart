import '../../../../core/widgets/common/status_badge.dart';

String customerTypeLabel(int type) {
  switch (type) {
    case 1:
      return 'Retail Sales';
    case 2:
      return 'Credit Sales';
    case 3:
      return 'Online Sale';
    default:
      return 'Type $type';
  }
}

StatusBadgeType customerTypeBadgeType(int type) {
  switch (type) {
    case 1:
      return StatusBadgeType.primary;
    case 2:
      return StatusBadgeType.warning;
    case 3:
      return StatusBadgeType.info;
    default:
      return StatusBadgeType.neutral;
  }
}