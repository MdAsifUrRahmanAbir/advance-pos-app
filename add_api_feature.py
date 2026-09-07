#!/usr/bin/env python3
import os
import re
import sys

def prompt(question, default=None):
    if default:
        res = input(f"{question} [{default}]: ").strip()
        return res if res else default
    else:
        while True:
            res = input(f"{question}: ").strip()
            if res:
                return res
            print("⚠️ This field is required.")

def to_snake_case(name):
    s1 = re.sub('(.)([A-Z][a-z]+)', r'\1_\2', name)
    return re.sub('([a-z0-9])([A-Z])', r'\1_\2', s1).lower()

def to_camel(name):
    return name[0].lower() + name[1:] if name else name


# =====================================================
# State-file patcher — inserts a data field + loading flag
# into an EXISTING state class without touching anything else.
# =====================================================
def patch_state_file(state_path, state_class_name, model_name, field_name, loading_field, add_field=True):
    if not os.path.exists(state_path):
        print(f"\n⚠️  WARNING: {state_path} does not exist.")
        print(f"   Skipping state patch — this script never creates or overwrites state files.")
        print(f"   Add these manually to {state_class_name}:")
        if add_field:
            print(f"     final {model_name}? {field_name};")
        print(f"     final bool {loading_field};")
        return

    with open(state_path, "r", encoding="utf-8") as f:
        content = f.read()

    already_has_field = add_field and re.search(rf"\bfinal\s+{re.escape(model_name)}\?\s+{re.escape(field_name)}\s*;", content)
    already_has_loading = re.search(rf"\bfinal\s+bool\s+{re.escape(loading_field)}\s*;", content)

    if already_has_field and already_has_loading:
        print(f"⚠️ Notice: '{field_name}' and '{loading_field}' already exist in {os.path.basename(state_path)} — skipping state patch.")
        return
    if already_has_loading and not add_field:
        print(f"⚠️ Notice: '{loading_field}' already exists in {os.path.basename(state_path)} — skipping state patch.")
        return

    original_content = content

    # ---- 1. Ensure model import exists (only if a field is being added) ----
    if add_field:
        model_file = to_snake_case(model_name)
        import_line = f"import '../../data/models/{model_file}.dart';"
        if import_line not in content:
            content = import_line + "\n" + content

    # ---- 2. Field declarations inside the class body ----
    field_decl_lines = ""
    if add_field and not already_has_field:
        field_decl_lines += f"  final {model_name}? {field_name};\n"
    if not already_has_loading:
        field_decl_lines += f"  final bool {loading_field};\n"

    if field_decl_lines:
        class_fields_pattern = re.compile(
            rf"(class {re.escape(state_class_name)}\s*\{{)(.*?)(\n\s*const {re.escape(state_class_name)}\()",
            re.S,
        )
        match = class_fields_pattern.search(content)
        if match:
            content = (
                content[: match.end(2)]
                + "\n" + field_decl_lines.rstrip("\n")
                + content[match.end(2):]
            )
        else:
            print(f"❌ Could not locate class body for {state_class_name} — field declarations not inserted.")

    # ---- 3. Constructor parameter list: const XState({ ... }); ----
    ctor_param_lines = ""
    if add_field and not already_has_field:
        ctor_param_lines += f"    this.{field_name},\n"
    if not already_has_loading:
        ctor_param_lines += f"    this.{loading_field} = false,\n"

    if ctor_param_lines:
        ctor_pattern = re.compile(
            rf"(const {re.escape(state_class_name)}\(\{{)(.*?)(\}}\);)",
            re.S,
        )
        match = ctor_pattern.search(content)
        if match:
            insert_at = match.end(2)
            content = content[:insert_at] + ctor_param_lines + content[insert_at:]
        else:
            print(f"❌ Could not locate constructor for {state_class_name} — constructor params not inserted.")

    # ---- 4. copyWith(...) signature ----
    copy_sig_lines = ""
    if add_field and not already_has_field:
        copy_sig_lines += f"    {model_name}? {field_name},\n"
    if not already_has_loading:
        copy_sig_lines += f"    bool? {loading_field},\n"

    if copy_sig_lines:
        copy_sig_pattern = re.compile(
            rf"({re.escape(state_class_name)} copyWith\(\{{)(.*?)(\}}\)\s*\{{)",
            re.S,
        )
        match = copy_sig_pattern.search(content)
        if match:
            insert_at = match.end(2)
            content = content[:insert_at] + copy_sig_lines + content[insert_at:]
        else:
            print(f"❌ Could not locate copyWith signature for {state_class_name} — params not inserted.")

    # ---- 5. copyWith(...) return body ----
    return_body_lines = ""
    if add_field and not already_has_field:
        return_body_lines += f"      {field_name}: {field_name} ?? this.{field_name},\n"
    if not already_has_loading:
        return_body_lines += f"      {loading_field}: {loading_field} ?? this.{loading_field},\n"

    if return_body_lines:
        return_pattern = re.compile(
            rf"(return {re.escape(state_class_name)}\()(.*?)(\);)",
            re.S,
        )
        match = return_pattern.search(content)
        if match:
            insert_at = match.end(2)
            content = content[:insert_at] + return_body_lines + content[insert_at:]
        else:
            print(f"❌ Could not locate return statement in copyWith for {state_class_name} — values not inserted.")

    if content == original_content:
        print(f"ℹ️  No changes made to {state_path} (already up to date).")
        return

    with open(state_path, "w", encoding="utf-8") as f:
        f.write(content)
    print(f"✅ Patched state file (added fields only, nothing removed): {state_path}")


def main():
    print("=" * 60)
    print("🚀 Flutter API Feature Automator (Smart Loading States)")
    print("=" * 60)

    # 1. Streamlined Inputs
    section_name = prompt("Enter section_name (lowercase, e.g. login, edit_profile, home, forget_password)").lower()
    model_name = prompt("Enter model_name (e.g. ProductsModel, LoginModel, EditProfileModel)")
    endpoint = prompt("Enter endpoint (e.g. productsUrl, loginUrl, editProfile)")

    print("\nSelect HTTP Method:")
    print("  1. GET")
    print("  2. POST")
    print("  3. PUT")
    print("  4. DELETE")
    choice = prompt("Select option (1-4)", "1")
    http_methods = {"1": "get", "2": "post", "3": "put", "4": "delete"}
    http_verb = http_methods.get(choice, "get")

    clean_model = model_name.replace("Model", "").strip()
    camel_model = to_camel(clean_model)

    if http_verb == "get":
        method_name = f"get{clean_model}"
    elif http_verb == "post":
        method_name = "login" if "login" in clean_model.lower() else camel_model
    elif http_verb == "put":
        method_name = f"update{clean_model}"
    elif http_verb == "delete":
        method_name = f"delete{clean_model}"
    else:
        method_name = camel_model

    print(f"💡 Automatically derived method name: {method_name}")

    needs_data = http_verb in ["post", "put", "patch"]
    repo_params = "Map<String, dynamic> data" if needs_data else ""
    client_args = f"ApiEndpoints.{endpoint}, data: data" if needs_data else f"ApiEndpoints.{endpoint}"
    repo_call_args = "data: data" if needs_data else ""

    # 2. File paths — state now lives under presentation/states/
    base_dir = os.getcwd()
    repo_path = os.path.join(base_dir, "lib", "features", section_name, "data", "repositories", f"{section_name}_repository.dart")
    state_path = os.path.join(base_dir, "lib", "features", section_name, "presentation", "states", f"{section_name}_state.dart")
    controller_path = os.path.join(base_dir, "lib", "features", section_name, "presentation", "controllers", f"{section_name}_controller.dart")
    error_mapper_path = os.path.join(base_dir, "lib", "core", "utils", "error_mapper.dart")

    print(f"📂 Target Repository: {repo_path}")
    print(f"📂 Target Controller: {controller_path}")
    print(f"📂 Target State (patched, not created): {state_path}")

    repo_class_name = "".join(w.capitalize() for w in section_name.split("_")) + "Repository"
    repo_provider_name = f"{section_name}RepositoryProvider"
    state_class_name = "".join(w.capitalize() for w in section_name.split("_")) + "State"
    class_name = "".join(w.capitalize() for w in section_name.split("_")) + "Controller"
    provider_name = f"{section_name}ControllerProvider"

    # Field + loading flag names, derived from ModelName
    field_name = to_camel(model_name)              # e.g. LoginModel -> loginModel
    loading_field = f"is{clean_model}Loading"       # e.g. LoginModel -> isLoginLoading
    is_delete = http_verb == "delete"

    # =====================================================
    # 3. Repository method (unchanged, append-only)
    # =====================================================
    repo_method_code = f"""
  // AUTO-GENERATED API METHOD
  Future<{model_name}> {method_name}({repo_params}) async {{
    final response = await _apiClient.{http_verb}({client_args});
    return {model_name}.fromJson(response.data);
  }}
"""

    # =====================================================
    # 4. Controller action — uses the model-specific field/loading
    #    names that get patched into the state file.
    # =====================================================
    verb_label = http_verb.upper()
    divider = "// " + "─" * 47

    if is_delete:
        controller_action_code = f"""
  {divider}
  // {verb_label}
  {divider}
  Future<bool> {method_name}({repo_params}) async {{
    state = state.copyWith({loading_field}: true);
    try {{
      await _repository.{method_name}({repo_call_args});
      state = state.copyWith({loading_field}: false);
      return true;
    }} catch (error) {{
      state = state.copyWith(
        {loading_field}: false,
        errorMessage: getErrorMessage(error),
      );
      return false;
    }}
  }}
"""
    else:
        result_var = camel_model if camel_model else "result"
        controller_action_code = f"""
  {divider}
  // {verb_label}
  {divider}
  Future<bool> {method_name}({repo_params}) async {{
    state = state.copyWith({loading_field}: true);
    try {{
      final {result_var} = await _repository.{method_name}({repo_call_args});
      state = state.copyWith(
        {loading_field}: false,
        {field_name}: {result_var},
      );
      return true;
    }} catch (error) {{
      state = state.copyWith(
        {loading_field}: false,
        errorMessage: getErrorMessage(error),
      );
      return false;
    }}
  }}
"""

    # =====================================================
    # 5. Inject into Repository File — append only
    # =====================================================
    os.makedirs(os.path.dirname(repo_path), exist_ok=True)
    if os.path.exists(repo_path):
        with open(repo_path, "r", encoding="utf-8") as f:
            repo_content = f.read()
        if f"Future<{model_name}> {method_name}(" in repo_content:
            print(f"⚠️ Notice: '{method_name}' already exists in {os.path.basename(repo_path)} — skipping repository injection.")
        else:
            last_brace_idx = repo_content.rfind("}")
            if last_brace_idx != -1:
                repo_content = repo_content[:last_brace_idx] + repo_method_code + "\n}\n"
                with open(repo_path, "w", encoding="utf-8") as f:
                    f.write(repo_content)
                print(f"✅ Appended method to repository: {repo_path}")
            else:
                print(f"❌ Could not find closing brace in {repo_path}")
    else:
        print(f"⚠️ Repository file not found. Creating new file...")
        new_repo_content = f"""import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';

final {repo_provider_name} = Provider<{repo_class_name}>((ref) {{
  return {repo_class_name}(ref.watch(apiClientProvider));
}});

class {repo_class_name} {{
  final ApiClient _apiClient;
  {repo_class_name}(this._apiClient);
{repo_method_code}
}}
"""
        with open(repo_path, "w", encoding="utf-8") as f:
            f.write(new_repo_content)
        print(f"✅ Created and populated repository: {repo_path}")

    # =====================================================
    # 6. error_mapper.dart — created once, never rewritten
    # =====================================================
    if not os.path.exists(error_mapper_path):
        os.makedirs(os.path.dirname(error_mapper_path), exist_ok=True)
        error_mapper_content = """import '../network/api_exception.dart';

/// Central place to turn any caught error into a user-facing message.
/// Use this instead of catching ApiException directly in every controller.
String getErrorMessage(Object error) {
  if (error is ApiException) return error.message;
  return 'Something went wrong. Please try again.';
}
"""
        with open(error_mapper_path, "w", encoding="utf-8") as f:
            f.write(error_mapper_content)
        print(f"✅ Created shared error mapper: {error_mapper_path}")
    else:
        print(f"ℹ️  Error mapper already exists, left untouched: {error_mapper_path}")

    # =====================================================
    # 7. Patch state file — adds field + loading flag ONLY.
    #    Never creates the file, never removes existing content.
    # =====================================================
    patch_state_file(
        state_path=state_path,
        state_class_name=state_class_name,
        model_name=model_name,
        field_name=field_name,
        loading_field=loading_field,
        add_field=not is_delete,
    )

    # =====================================================
    # 8. Inject into Controller File — append only
    # =====================================================
    os.makedirs(os.path.dirname(controller_path), exist_ok=True)
    if os.path.exists(controller_path):
        with open(controller_path, "r", encoding="utf-8") as f:
            ctrl_content = f.read()

        if f"Future<bool> {method_name}(" in ctrl_content:
            print(f"⚠️ Notice: '{method_name}' already exists in {os.path.basename(controller_path)} — skipping controller injection.")
        else:
            repo_import = f"import '../../data/repositories/{section_name}_repository.dart';"
            if repo_import not in ctrl_content:
                ctrl_content = repo_import + "\n" + ctrl_content

            state_import = f"import '../states/{section_name}_state.dart';"
            if state_import not in ctrl_content:
                ctrl_content = state_import + "\n" + ctrl_content

            error_import = "import '../../../../core/utils/error_mapper.dart';"
            if error_import not in ctrl_content:
                ctrl_content = error_import + "\n" + ctrl_content

            if "_repository" not in ctrl_content:
                class_brace_idx = ctrl_content.find("{")
                if class_brace_idx != -1:
                    getter_code = f"\n  {repo_class_name} get _repository => ref.read({repo_provider_name});\n"
                    ctrl_content = ctrl_content[:class_brace_idx + 1] + getter_code + ctrl_content[class_brace_idx + 1:]

            last_brace_idx = ctrl_content.rfind("}")
            if last_brace_idx != -1:
                ctrl_content = ctrl_content[:last_brace_idx] + controller_action_code + "\n}\n"
                with open(controller_path, "w", encoding="utf-8") as f:
                    f.write(ctrl_content)
                print(f"✅ Appended action to controller: {controller_path}")
            else:
                print(f"❌ Could not find closing brace in {controller_path}")
    else:
        print(f"⚠️ Controller file not found. Creating new file...")
        print(f"   (Assumes '{state_class_name}' already exists in ../states/{section_name}_state.dart)")
        new_ctrl_content = f"""import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/{section_name}_repository.dart';
import '../../../../core/utils/error_mapper.dart';
import '../states/{section_name}_state.dart';

class {class_name} extends Notifier<{state_class_name}> {{
  {repo_class_name} get _repository => ref.read({repo_provider_name});

  @override
  {state_class_name} build() {{
    return const {state_class_name}();
  }}
{controller_action_code}
}}

final {provider_name} = NotifierProvider<{class_name}, {state_class_name}>({class_name}.new);
"""
        with open(controller_path, "w", encoding="utf-8") as f:
            f.write(new_ctrl_content)
        print(f"✅ Created and populated controller: {controller_path}")

    print("\n🎉 API Feature successfully added with smart loading states!")
    print(f"   State field added: {field_name if not is_delete else '(none — DELETE has no data field)'}")
    print(f"   Loading flag added: {loading_field}")

if __name__ == "__main__":
    main()