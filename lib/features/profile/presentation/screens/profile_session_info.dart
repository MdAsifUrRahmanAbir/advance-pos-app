import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/session/api_params.dart';
import '../../../../core/session/auth_session_controller.dart';
import '../../../../core/session/client_profile.dart';
import '../../../../core/session/client_session_controller.dart';
import '../../../../core/session/session_profile.dart';

/// What the Profile shows about the bound company and the signed-in
/// employee, gathered from the session providers.
typedef ProfileSessionInfo = ({
  ClientProfile? company,
  SessionProfile? employee,
  int? branchId,
  int? employeeId,
});

/// Watches the company, session and request-param providers. Employee ID
/// prefers the saved login value and falls back to the request params,
/// ignoring their "unknown employee" placeholder.
ProfileSessionInfo watchProfileSessionInfo(WidgetRef ref) {
  final company = ref.watch(clientSessionControllerProvider);
  final employee = ref.watch(sessionProfileProvider);
  final params = ref.watch(apiParamsControllerProvider);
  final paramsEmployeeId = params?.employeeId;

  return (
    company: company,
    employee: employee,
    branchId: params?.branchId,
    employeeId: employee?.employeeId ??
        (paramsEmployeeId == ApiParamDefaults.unknownEmployeeId
            ? null
            : paramsEmployeeId),
  );
}
