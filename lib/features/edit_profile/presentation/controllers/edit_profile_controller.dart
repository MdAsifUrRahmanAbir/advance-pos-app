import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';

class EditProfileState {
  const EditProfileState();
}

class EditProfileController extends Notifier<EditProfileState> {
  final formKey = GlobalKey<FormState>();

  late final TextEditingController nameController;
  late final TextEditingController emailController;
  late final TextEditingController phoneController;
  late final TextEditingController designationController;
  late final TextEditingController bioController;

  @override
  EditProfileState build() {
    nameController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();
    designationController = TextEditingController();
    bioController = TextEditingController();
    initialize();
    ref.onDispose(() {
      nameController.dispose();
      emailController.dispose();
      phoneController.dispose();
      designationController.dispose();
      bioController.dispose();
    });

    return const EditProfileState();
  }

  /// Call this when profile data is loaded.
  void initialize({
    String name = 'Alex Johnson',
    String email = 'alex.johnson@enterprise.com',
    String phone = '555-0199',
    String designation = 'Workspace Admin',
    String bio = 'Responsible for managing the enterprise cluster databases, '
        'orchestrating deployments, and setting access token '
        'permissions for the department nodes.',
  }) {
    nameController.text = name;
    emailController.text = email;
    phoneController.text = phone;
    designationController.text = designation;
    bioController.text = bio;
  }

  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.fullNameRequired;
    }

    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.emailRequired;
    }

    if (!value.contains('@')) {
      return AppStrings.emailInvalid;
    }

    return null;
  }

  Map<String, String> get values {
    return {
      'name': nameController.text.trim(),
      'email': emailController.text.trim(),
      'phone': phoneController.text.trim(),
      'designation': designationController.text.trim(),
      'bio': bioController.text.trim(),
    };
  }

  bool validate() {
    return formKey.currentState?.validate() ?? false;
  }

  void submit(
      void Function(Map<String, String> values) onSave,
      ) {
    if (!validate()) {
      return;
    }

    onSave(values);
  }
}

final editProfileControllerProvider =
NotifierProvider.autoDispose<
    EditProfileController,
    EditProfileState>(
  EditProfileController.new,
);