import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuditLogController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }
}

final auditLogControllerProvider = NotifierProvider<AuditLogController, AsyncValue<void>>(AuditLogController.new);
