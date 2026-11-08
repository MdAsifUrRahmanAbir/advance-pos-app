
/// API keys used in a sales record's `blocked_actions` array.
/// These are protocol values, not user-facing text.
abstract final class InvoiceBlockedAction {
  static const String edit = 'edit';
  static const String delete = 'delete';
}