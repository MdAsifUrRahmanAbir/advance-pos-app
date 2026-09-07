# Instructions for This Flutter Project

Paste this whole file into any AI agent's system/context before asking it to
turn a Figma export, screenshot, or design description into code for this
project. It captures the architecture, rules, and workflow this codebase
follows so output stays consistent no matter which AI or session produces it.

---

## 1. Project shape

Feature-first Flutter app, **Riverpod** for state, **repository pattern** for
data, **go_router** for navigation, mobile/tablet split via a `Responsive`
widget.

```
lib/
├── main.dart
├── core/
│   ├── constants/
│   │   ├── app_colors.dart      # AppColors — every color in the app
│   │   ├── app_sizes.dart       # AppSizes  — every spacing/radius/font size
│   │   ├── app_strings.dart     # AppStrings — every user-facing string
│   │   └── api_endpoints.dart
│   ├── network/
│   │   ├── api_client.dart
│   │   └── api_exception.dart
│   ├── theme/
│   │   └── app_theme.dart
│   ├── utils/
│   │   └── responsive.dart
│   └── widgets/
│       ├── common/              # reusable UI atoms (buttons, fields, cards...)
│       └── utility/              # reusable stateless helpers (snackbar, dialog...)
├── routes/
│   ├── app_router.dart          # every GoRoute in one place
│   └── route_names.dart         # every route path constant
└── features/
    └── <feature_name>/
        ├── data/
        │   ├── models/
        │   └── repositories/
        └── presentation/
            ├── controllers/      # Riverpod Notifiers (UI state + future business state)
            ├── screens/
            │   ├── <feature>_screen.dart        # Responsive() wrapper — nothing else
            │   ├── <feature>_mobile_view.dart    # layout + wiring for phones
            │   └── <feature>_tab_view.dart       # layout + wiring for tablet/web
            └── widgets/          # small presentational pieces of that screen
```

---

## 2. Hard rules — never break these

1. **Never write code in:**
    - `features/<feature>/data/models/`
    - `features/<feature>/data/repositories/`
    - `features/<feature>/presentation/screens/<feature>_screen.dart`

   `<feature>_screen.dart` must always stay exactly this shape — nothing more:
   ```dart
   class XScreen extends ConsumerWidget {
     const XScreen({super.key});
     @override
     Widget build(BuildContext context, WidgetRef ref) {
       return Scaffold(
         body: Responsive(
           mobile: const XMobileView(),
           tablet: const XTabView(),
         ),
       );
     }
   }
   ```
   If an existing `_screen.dart` was scaffolded with real UI inline (older
   generator output, not yet split), converting it to this thin wrapper is
   allowed — do it once, then treat it as off-limits again.

2. **Write real UI code only in `presentation/widgets/`.** Break each screen
   into small, single-purpose, presentational widgets (header, form, one
   list item, a footer prompt, etc.) — not one giant widget.

3. **Wire everything together in `<feature>_mobile_view.dart` and
   `<feature>_tab_view.dart`.** These two files:
    - Compose the widgets from `presentation/widgets/` into the actual layout.
    - Handle `go_router` navigation (`context.go` / `context.push` / `context.pop`).
    - Contain the only allowed "business logic" placeholder: a `// TODO`
      comment where a repository/controller call will go later (see §6).
    - Mobile view: edge-to-edge with page padding. Tab view: same content
      centered in `ConstrainedBox(maxWidth: 480)` (or similar) instead of
      stretching full width.

4. **`presentation/controllers/` is allowed.** Use it for UI-only state that
   doesn't belong on a widget's own `State` — form `TextEditingController`s,
   `GlobalKey<FormState>`, validation functions, toggles like remember-me —
   modeled as a Riverpod `AutoDisposeNotifier`. Keep this separate from the
   *real* auth/business controller that will call the repository later; name
   them distinctly (e.g. `LoginFormController` for UI state vs. a future
   `AuthController` for the real session state).

5. **Every color and every size must come from `AppColors` / `AppSizes`.**
   No `Colors.blue`, no raw `16.0`, no magic hex codes anywhere in feature or
   core widget code. If a design's exact pixel value doesn't map to an
   existing `AppSizes` token, say so explicitly and either pick the nearest
   token or ask — don't silently invent a new unnamed number.

6. **Every user-facing string must come from `AppStrings`.** When a design
   needs new copy, add new `static const String` entries to
   `app_strings.dart` — **append, never delete or rename existing ones**
   (something else may depend on them). Validation/error messages belong
   there too, not as inline string literals in widgets.

7. **Reuse `core/widgets/` before writing anything new.** Before building a
   piece of UI, check `core/widgets/common/` and `core/widgets/utility/` for
   something that already does the job. Only add a new core widget when the
   design genuinely needs something that doesn't exist yet.

---

## 3. When a new core widget is needed

- Design it **generically** — parameterize what varies (label, icon, color,
  variant), not hardcoded to the one screen that triggered it. Assume other
  features will reuse it.
- Style it entirely from `AppColors` / `AppSizes`.
- Give it a short doc comment (`///`) explaining what it's for and when to
  reach for it instead of a similar existing widget.
- **Keep it backward compatible.** If updating an existing core widget,
  keep prior required parameters and their meaning intact; add new behavior
  via new optional parameters (with sensible defaults) or a variant enum,
  so every screen already using it keeps compiling and looking right.
- Call out clearly that it's a **replace-this-file** update vs. a **new
  file** so the person can drop it in without hunting for what changed.

---

## 4. Turning a Figma export / screenshot into code — step by step

1. **Identify the feature.** Map the screen to a `features/<feature_name>/`
   folder (existing or new). If new, it needs the same
   `data/{models,repositories}` + `presentation/{controllers,screens,widgets}`
   shape as every other feature, even if `data/` stays empty/untouched for now.

2. **Read the design.** Note: layout structure, spacing rhythm, text styles,
   colors, icons, interactive states (focused/active/disabled), and any
   copy/microcopy.

3. **Diff against `core/widgets/`.** For each visual element, decide:
   *reuse as-is* / *reuse with new optional param* / *needs a new core widget*.
   List anything new before writing feature code.

4. **Add missing `AppStrings` entries** for every piece of copy on the
   screen (titles, labels, hints, button text, validation messages).

5. **Build the feature widgets** in `presentation/widgets/`, one per logical
   section. Each one:
    - Takes only what it needs as constructor params.
    - Owns only *local* UI state (text controllers, obscure-toggle, etc.) —
      or reads that state from a `presentation/controllers/` Notifier if the
      state needs to survive rebuilds/be testable independently.
    - Exposes callbacks (`onSubmit`, `onTap`, `onResend`, ...) instead of
      calling a repository directly — the caller decides what happens.

6. **Assemble in `_mobile_view.dart` / `_tab_view.dart`.** Import the
   feature widgets, lay them out, supply the callbacks with real
   `go_router` navigation and a `// TODO` for the eventual repository call:
   ```dart
   onSignIn: (email, password, rememberMe) {
     // TODO: wire to authControllerProvider.login(email, password)
     // once the login/data/repositories layer is ready.
     context.go(RouteNames.mainShell);
   },
   ```

7. **Routes:** `routes/route_names.dart` and `routes/app_router.dart` are
   **not** restricted — add a new route name + `GoRoute` entry there if the
   screen needs one that doesn't exist yet.

8. **Deliver the code.** Always:
    - Paste code directly in the reply, **never as a zip**.
    - Group it under clear headers by exact file path
      (e.g. `## lib/features/login/presentation/widgets/login_form.dart`).
    - Separate **new files** from **updated files** explicitly.
    - Call out any core widget changes as "replace this file" with the full
      updated contents.
    - Flag anything that doesn't cleanly fit the const-token system (odd
      pixel values, missing `AppColors`/`AppSizes` entries) instead of
      quietly working around it.

---

## 5. Naming conventions

- Files: `snake_case.dart`. Classes: `PascalCase`.
- Feature widgets are named `<Feature><Purpose>`:
  `LoginForm`, `LoginHeader`, `RegisterForm`, `OtpForm`, `SocialLoginSection`,
  `RegisterPrompt`, `BackToLoginLink`.
- Screens: `<feature>_screen.dart` / `<feature>_mobile_view.dart` /
  `<feature>_tab_view.dart` → classes `XScreen` / `XMobileView` / `XTabView`.
- Core widgets: `Custom*` / `Primary*` / `Secondary*` prefixes for generic
  building blocks (`CustomCard`, `CustomAppBar`, `PrimaryButton`,
  `PrimaryInputField`) so they read clearly as shared, not feature-specific.

---

## 6. TODO convention for unfinished business logic

Since `data/models`, `data/repositories`, and `_screen.dart` stay untouched,
every screen ships with UI fully working except the final data call. Mark
that spot consistently:

```dart
// TODO: wire to <feature>ControllerProvider.<method>(...)
// once the <feature>/data/repositories layer is ready.
```

This makes every unfinished integration point grep-able later
(`grep -r "TODO: wire to" lib/`).

---

## 7. Quick checklist (copy this into the request if useful)

- [ ] Feature folder identified/created with the standard sub-structure
- [ ] Checked `core/widgets/common` + `core/widgets/utility` for reuse first
- [ ] Any new core widget is generic, themed, documented, backward-compatible
- [ ] All copy added to `AppStrings` (nothing hardcoded)
- [ ] All colors/sizes from `AppColors`/`AppSizes` (nothing hardcoded)
- [ ] New code only in `presentation/widgets/` (+ `presentation/controllers/`
  if UI state needs a Notifier)
- [ ] `_screen.dart` untouched (or converted once to the thin wrapper if it
  wasn't already)
- [ ] Wiring + navigation done in `_mobile_view.dart` / `_tab_view.dart`
- [ ] `data/models`, `data/repositories` untouched
- [ ] Routes added to `route_names.dart` / `app_router.dart` if needed
- [ ] TODO comments mark where repository/controller calls will go
- [ ] Code delivered inline, by file path, new vs. updated clearly labeled