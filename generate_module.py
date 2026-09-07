import os
import re

ROOT = os.getcwd()
LIB_PATH = os.path.join(ROOT, "lib")
PACKAGE_NAME = "template_test2"  # 👈 আপনার pubspec.yaml এর package name বসান

def format_class_name(name):
    """Convert snake_case or clean string to PascalCase (e.g., product_list -> ProductList)"""
    words = name.replace("-", "_").split("_")
    return "".join([w.capitalize() for w in words])

def format_snake_case(name):
    """Convert PascalCase or space string to snake_case (e.g., productList -> product_list)"""
    s1 = re.sub('(.)([A-Z][a-z]+)', r'\1_\2', name)
    return re.sub('([a-z0-9])([A-Z])', r'\1_\2', s1).lower()

def format_camel_case(name):
    """Convert snake_case or PascalCase to camelCase (e.g., cart_item -> cartItem)"""
    snake = format_snake_case(name)
    words = snake.split("_")
    if not words:
        return name
    return words[0].lower() + "".join([w.capitalize() for w in words[1:]])

def safe_inject_route_name(file_path, route_name):
    """Inject route name constant safely before the last closing brace of RouteNames class"""
    if not os.path.exists(file_path):
        return
    with open(file_path, "r", encoding="utf-8") as f:
        content = f.read()
    insertion = f"static const String {route_name} = '/{route_name}';"
    if insertion in content: return
    last_brace_index = content.rfind("}")
    if last_brace_index != -1:
        new_content = content[:last_brace_index] + f"  {insertion}\n" + content[last_brace_index:]
        with open(file_path, "w", encoding="utf-8") as f:
            f.write(new_content)

def safe_inject_go_route(file_path, route_code, import_statement):
    """Inject GoRoute and Import statement into app_router.dart safely"""
    if not os.path.exists(file_path): return
    with open(file_path, "r", encoding="utf-8") as f:
        content = f.read()
    if import_statement.strip() not in content:
        content = import_statement + content
    if route_code.strip() in content: return
    target_pattern = "];"
    if target_pattern in content:
        content = content.replace(target_pattern, f"  {route_code}\n    {target_pattern}")
    else:
        last_bracket = content.rfind("]")
        if last_bracket != -1:
            content = content[:last_bracket] + f"  {route_code}\n  " + content[last_bracket:]
    with open(file_path, "w", encoding="utf-8") as f:
        f.write(content)

def create_module(module_raw_name):
    module_snake = format_snake_case(module_raw_name)
    class_prefix = format_class_name(module_snake)
    variable_camel = format_camel_case(module_snake)

    feature_dir = os.path.join(LIB_PATH, "features", module_snake)

    # File Paths
    state_path = os.path.join(feature_dir, "presentation", "states", f"{module_snake}_state.dart")
    repo_path = os.path.join(feature_dir, "data", "repositories", f"{module_snake}_repository.dart")
    controller_path = os.path.join(feature_dir, "presentation", "controllers", f"{module_snake}_controller.dart")
    screen_path = os.path.join(feature_dir, "presentation", "screens", f"{module_snake}_screen.dart")
    mobile_view_path = os.path.join(feature_dir, "presentation", "screens", f"{module_snake}_mobile_view.dart")
    tab_view_path = os.path.join(feature_dir, "presentation", "screens", f"{module_snake}_tab_view.dart")

    # =========================================================
    # Code Templates
    # =========================================================

    state_code = f"""class {class_prefix}State {{
  final bool isInitialLoading;
  final String? errorMessage;

  const {class_prefix}State({{
    this.isInitialLoading = false,
    this.errorMessage,
  }});

  {class_prefix}State copyWith({{
    bool? isInitialLoading,
    String? errorMessage,
  }}) {{
    return {class_prefix}State(
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      errorMessage: errorMessage,
    );
  }}
}}
"""

    repo_code = f"""import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';

final {variable_camel}RepositoryProvider = Provider<{class_prefix}Repository>((ref) {{
  return {class_prefix}Repository(ref.watch(apiClientProvider));
}});

class {class_prefix}Repository {{
  final ApiClient _apiClient;
  {class_prefix}Repository(this._apiClient);


}}
"""

    controller_code = f"""import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/{module_snake}_repository.dart';
import '../states/{module_snake}_state.dart';

final {variable_camel}ControllerProvider = NotifierProvider.autoDispose<{class_prefix}Controller, {class_prefix}State>(
  {class_prefix}Controller.new,
);

class {class_prefix}Controller extends Notifier<{class_prefix}State> {{
  late final TextEditingController nameController;

  {class_prefix}Repository get _repository => ref.read({variable_camel}RepositoryProvider);

  @override
  {class_prefix}State build() {{
    nameController = TextEditingController();
    ref.onDispose(() => nameController.dispose());
    return const {class_prefix}State();
  }}
}}
"""

    screen_code = f"""import 'package:flutter/material.dart';
import '../../../../core/utils/responsive.dart';
import '{module_snake}_mobile_view.dart';
import '{module_snake}_tab_view.dart';

class {class_prefix}Screen extends StatelessWidget {{
  const {class_prefix}Screen({{super.key}});

  @override
  Widget build(BuildContext context) {{
    return const Scaffold(
      body: Responsive(
        mobile: {class_prefix}MobileView(),
        tablet: {class_prefix}TabView(),
      ),
    );
  }}
}}
"""

    view_widget_code = lambda device: f"""import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/{module_snake}_controller.dart';

class {class_prefix}{device}View extends ConsumerWidget {{
  const {class_prefix}{device}View({{super.key}});

  @override
  Widget build(BuildContext context, WidgetRef ref) {{
    // 👈 Accessing State and Controller
    final state = ref.watch({variable_camel}ControllerProvider);
    final controller = ref.read({variable_camel}ControllerProvider.notifier);

    if (state.isInitialLoading) {{
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }}

    return SizedBox();
  }}
}}
"""

    # Create All Files
    files = {
        state_path: state_code,
        repo_path: repo_code,
        controller_path: controller_code,
        screen_path: screen_code,
        mobile_view_path: view_widget_code("Mobile"),
        tab_view_path: view_widget_code("Tab"),
    }

    for path, content in files.items():
        os.makedirs(os.path.dirname(path), exist_ok=True)
        if not os.path.exists(path):
            with open(path, "w", encoding="utf-8") as f: f.write(content)
            print(f"✅ Created: {os.path.relpath(path, ROOT)}")

    # Route Injections
    safe_inject_route_name(os.path.join(LIB_PATH, "routes", "route_names.dart"), module_snake)
    go_route_code = f"GoRoute(path: RouteNames.{module_snake}, builder: (context, state) => const {class_prefix}Screen()),"
    import_stmt = f"import 'package:{PACKAGE_NAME}/features/{module_snake}/presentation/screens/{module_snake}_screen.dart';\n"
    safe_inject_go_route(os.path.join(LIB_PATH, "routes", "app_router.dart"), go_route_code, import_stmt)
    print(f"\n🎉 Module '{class_prefix}' Generated Successfully!")

if __name__ == "__main__":
    module_input = input("Enter new Screen/Feature Name: ").strip()
    if module_input: create_module(module_input)
    else: print("❌ Error: Module name cannot be empty.")
