import '../../../../core/widgets/common/status_badge.dart';

/// Maps the raw `customer_type` int from the API to a display label and
/// badge color. Only 1 (Regular) and 2 (Special) are confirmed today —
/// anything else falls back to a generic "Type N" label so a new type
/// added on the backend doesn't break the UI. Update this map once more
/// types are confirmed.
String customerTypeLabel(int type) {
  switch (type) {
    case 1:
      return 'Regular';
    case 2:
      return 'Special';
    default:
      return 'Type $type';
  }
}

StatusBadgeType customerTypeBadgeType(int type) {
  switch (type) {
    case 1:
      return StatusBadgeType.success;
    case 2:
      return StatusBadgeType.info;
    default:
      return StatusBadgeType.neutral;
  }
}