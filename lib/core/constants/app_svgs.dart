/// Modern rounded custom SVG icon set.
/// Designed for a clean SaaS / POS interface.
/// Rendered via `AppSvgIcon.string` and recolored using ColorFilter.
///
/// Each nav-style icon has two variants:
///   - the plain (outline) version, used when unselected
///   - a `selectedX` version — a solid silhouette with the internal detail
///     lines punched out as true transparent holes (via `mask` /
///     `fill-rule: evenodd`), so recoloring with ColorFilter still shows
///     the cutouts correctly instead of flattening them.
class AppSvgs {
  AppSvgs._();

  // ---- Home ----------------------------------------------------------

  static const String home = '''
<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path
    d="M4 11.5C4 10.9 4.25 10.35 4.68 9.97L11.18 4.3C11.65 3.9 12.35 3.9 12.82 4.3L19.32 9.97C19.75 10.35 20 10.9 20 11.5V18C20 19.1 19.1 20 18 20H6C4.9 20 4 19.1 4 18V11.5Z"
    stroke="#000000"
    stroke-width="1.7"
    stroke-linejoin="round"
  />
  <path
    d="M9.5 20V15.5C9.5 14.12 10.62 13 12 13C13.38 13 14.5 14.12 14.5 15.5V20"
    stroke="#000000"
    stroke-width="1.7"
    stroke-linecap="round"
    stroke-linejoin="round"
  />
</svg>
''';

  static const String selectedHome = '''
<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path
    fill-rule="evenodd"
    clip-rule="evenodd"
    d="M4 11.5C4 10.9 4.25 10.35 4.68 9.97L11.18 4.3C11.65 3.9 12.35 3.9 12.82 4.3L19.32 9.97C19.75 10.35 20 10.9 20 11.5V18C20 19.1 19.1 20 18 20H6C4.9 20 4 19.1 4 18V11.5Z M9.5 20V15.5C9.5 14.12 10.62 13 12 13C13.38 13 14.5 14.12 14.5 15.5V20Z"
    fill="#000000"
  />
</svg>
''';

  // ---- Stock / inventory ---------------------------------------------

  static const String stock = '''
<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path
    d="M4.5 8.5C4.5 7.86 4.86 7.28 5.43 6.98L11.43 3.98C11.79 3.79 12.21 3.79 12.57 3.98L18.57 6.98C19.14 7.28 19.5 7.86 19.5 8.5V15.5C19.5 16.14 19.14 16.72 18.57 17.02L12.57 20.02C12.21 20.21 11.79 20.21 11.43 20.02L5.43 17.02C4.86 16.72 4.5 16.14 4.5 15.5V8.5Z"
    stroke="#000000"
    stroke-width="1.7"
    stroke-linejoin="round"
  />
  <path
    d="M5 7.5L12 11L19 7.5"
    stroke="#000000"
    stroke-width="1.7"
    stroke-linecap="round"
    stroke-linejoin="round"
  />
  <path
    d="M12 11V20"
    stroke="#000000"
    stroke-width="1.7"
    stroke-linecap="round"
  />
</svg>
''';

  static const String selectedStock = '''
<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <mask id="selectedStockMask" maskUnits="userSpaceOnUse" x="0" y="0" width="24" height="24">
    <rect width="24" height="24" fill="#ffffff"/>
    <path d="M5 7.5L12 11L19 7.5" stroke="#000000" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"/>
    <path d="M12 11V20" stroke="#000000" stroke-width="1.7" stroke-linecap="round"/>
  </mask>
  <path
    d="M4.5 8.5C4.5 7.86 4.86 7.28 5.43 6.98L11.43 3.98C11.79 3.79 12.21 3.79 12.57 3.98L18.57 6.98C19.14 7.28 19.5 7.86 19.5 8.5V15.5C19.5 16.14 19.14 16.72 18.57 17.02L12.57 20.02C12.21 20.21 11.79 20.21 11.43 20.02L5.43 17.02C4.86 16.72 4.5 16.14 4.5 15.5V8.5Z"
    fill="#000000"
    mask="url(#selectedStockMask)"
  />
</svg>
''';

  // ---- Report ----------------------------------------------------------

  static const String report = '''
<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect
    x="5"
    y="3.5"
    width="14"
    height="17"
    rx="3"
    stroke="#000000"
    stroke-width="1.7"
  />
  <path
    d="M8 14.5C9 12.5 9.5 12.5 10.5 14C11.5 15.5 12 15.5 13 13.5C14 11.5 14.5 11.5 16 13"
    stroke="#000000"
    stroke-width="1.7"
    stroke-linecap="round"
    stroke-linejoin="round"
  />
  <circle cx="16" cy="13" r="1" fill="#000000"/>
</svg>
''';

  // ---- More (overflow) -------------------------------------------------

  static const String more = '''
<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <circle cx="6" cy="12" r="1.5" fill="#000000"/>
  <circle cx="12" cy="12" r="1.5" fill="#000000"/>
  <circle cx="18" cy="12" r="1.5" fill="#000000"/>
</svg>
''';

  static const String selectedMore = '''
<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <mask id="selectedMoreMask" maskUnits="userSpaceOnUse" x="0" y="0" width="24" height="24">
    <rect width="24" height="24" fill="#ffffff"/>
    <circle cx="6" cy="12" r="1.5" fill="#000000"/>
    <circle cx="12" cy="12" r="1.5" fill="#000000"/>
    <circle cx="18" cy="12" r="1.5" fill="#000000"/>
  </mask>
  <rect x="3" y="9" width="18" height="6" rx="3" fill="#000000" mask="url(#selectedMoreMask)"/>
</svg>
''';

  // ---- Plus --------------------------------------------------------------

  static const String plus = '''
<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path
    d="M12 6V18M6 12H18"
    stroke="#FFFFFF"
    stroke-width="2"
    stroke-linecap="round"
  />
</svg>
''';

  // ---- Invoice (single) --------------------------------------------------

  static const String invoice = '''
<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path
    d="M6 3H18C18.55 3 19 3.45 19 4V20A1.75 1.75 0 0 1 15.5 20A1.75 1.75 0 0 1 12 20A1.75 1.75 0 0 1 8.5 20A1.75 1.75 0 0 1 5 20V4C5 3.45 5.45 3 6 3Z"
    stroke="#000000"
    stroke-width="1.7"
    stroke-linejoin="round"
  />
  <path
    d="M8.5 8H15.5"
    stroke="#000000"
    stroke-width="1.7"
    stroke-linecap="round"
  />
  <path
    d="M8.5 11.5H15.5"
    stroke="#000000"
    stroke-width="1.7"
    stroke-linecap="round"
  />
  <path
    d="M8.5 15H12.5"
    stroke="#000000"
    stroke-width="1.7"
    stroke-linecap="round"
  />
</svg>
''';

  static const String selectedInvoice = '''
<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <mask id="selectedInvoiceMask" maskUnits="userSpaceOnUse" x="0" y="0" width="24" height="24">
    <rect width="24" height="24" fill="#ffffff"/>
    <path d="M8.5 8H15.5" stroke="#000000" stroke-width="1.7" stroke-linecap="round"/>
    <path d="M8.5 11.5H15.5" stroke="#000000" stroke-width="1.7" stroke-linecap="round"/>
    <path d="M8.5 15H12.5" stroke="#000000" stroke-width="1.7" stroke-linecap="round"/>
  </mask>
  <path
    d="M6 3H18C18.55 3 19 3.45 19 4V20A1.75 1.75 0 0 1 15.5 20A1.75 1.75 0 0 1 12 20A1.75 1.75 0 0 1 8.5 20A1.75 1.75 0 0 1 5 20V4C5 3.45 5.45 3 6 3Z"
    fill="#000000"
    mask="url(#selectedInvoiceMask)"
  />
</svg>
''';

  // ---- Invoices (stack) ---------------------------------------------------

  static const String invoices = '''
<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect
    x="4"
    y="5"
    width="12"
    height="15"
    rx="2"
    stroke="#000000"
    stroke-width="1.7"
  />
  <path
    d="M8 9H12.5"
    stroke="#000000"
    stroke-width="1.7"
    stroke-linecap="round"
  />
  <path
    d="M8 12.5H12.5"
    stroke="#000000"
    stroke-width="1.7"
    stroke-linecap="round"
  />
  <path
    d="M8 16H10.5"
    stroke="#000000"
    stroke-width="1.7"
    stroke-linecap="round"
  />
  <path
    d="M16 8.5H18C19.1 8.5 20 9.4 20 10.5V18C20 19.1 19.1 20 18 20H11"
    stroke="#000000"
    stroke-width="1.7"
    stroke-linecap="round"
    stroke-linejoin="round"
  />
</svg>
''';

  static const String selectedInvoices = '''
<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="15" y="8.5" width="5" height="11.5" rx="2" fill="#000000"/>
  <mask id="selectedInvoicesMask" maskUnits="userSpaceOnUse" x="0" y="0" width="24" height="24">
    <rect width="24" height="24" fill="#ffffff"/>
    <path d="M8 9H12.5" stroke="#000000" stroke-width="1.7" stroke-linecap="round"/>
    <path d="M8 12.5H12.5" stroke="#000000" stroke-width="1.7" stroke-linecap="round"/>
    <path d="M8 16H10.5" stroke="#000000" stroke-width="1.7" stroke-linecap="round"/>
  </mask>
  <rect
    x="4"
    y="5"
    width="12"
    height="15"
    rx="2"
    fill="#000000"
    mask="url(#selectedInvoicesMask)"
  />
</svg>
''';
}