import 'dart:async';

import 'package:advance_pos_app/features/login/data/models/login_model.dart';
import 'package:advance_pos_app/features/login/data/repositories/login_repository.dart';

const validUsername = 'cashier';
const validPassword = 'secret';
const wrongCredentialsMessage = 'Invalid username or password';
const loginBranchId = 3;

/// POST /login against one known user. [gate] holds the next call;
/// [nextError] throws on the next call only.
class FakeLoginRepository implements LoginRepository {
  final List<({String username, String password, String? clientToken})>
  calls = [];
  Object? nextError;
  Completer<void>? gate;

  @override
  Future<LoginModel> login({
    required String username,
    required String password,
  }) =>
      _respond(username, password, null);

  @override
  Future<LoginModel> loginWithClientToken({
    required String username,
    required String password,
    required String clientToken,
  }) =>
      _respond(username, password, clientToken);

  Future<LoginModel> _respond(
      String username,
      String password,
      String? clientToken,
      ) async {
    calls.add((
    username: username,
    password: password,
    clientToken: clientToken,
    ));
    final g = gate;
    if (g != null) {
      gate = null;
      await g.future;
    } else {
      await Future<void>.delayed(Duration.zero);
    }
    final error = nextError;
    if (error != null) {
      nextError = null;
      throw error;
    }

    if (username != validUsername || password != validPassword) {
      return LoginModel.fromJson({
        'success': false,
        'message': wrongCredentialsMessage,
      });
    }
    return LoginModel.fromJson({
      'success': true,
      'message': 'Logged in',
      'data': {
        'user_config': {
          'user_id': 7,
          'full_name': 'Rahim Cashier',
          'company_id': 1,
          'company_type': 1,
          'branch_id': loginBranchId,
          'branch_name': 'Dhanmondi',
          'employee_no': 'E-7',
          'emp_id': 7,
        },
        'historys_id': 99,
        'last_login_ip': null,
        'last_login_time': null,
      },
    });
  }
}