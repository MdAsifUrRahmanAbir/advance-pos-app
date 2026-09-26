import '../../../../core/widgets/common/status_badge.dart';

/// Maps the raw `customer_type` int from the API to a display label and
/// badge color, matching the admin panel's "Customer Type" dropdown
/// (All / Retail Sales / Credit Sales / Online Sale). Update this map
/// if the backend adds more types later.
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