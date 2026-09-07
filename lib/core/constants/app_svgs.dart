/// Raw SVG source strings for the modern outline icon set used across
/// the app (bottom navigation, etc.) instead of Material Icons. Rendered
/// via `AppSvgIcon.string`, which recolors them with a [ColorFilter] —
/// the stroke/fill colors below are placeholders and never actually shown.
class AppSvgs {
  AppSvgs._();

  static const String home = '''
<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M3 10.5L12 3L21 10.5" stroke="#000000" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
<path d="M5 9.5V20C5 20.5523 5.44772 21 6 21H9.5V15C9.5 14.4477 9.94772 14 10.5 14H13.5C14.0523 14 14.5 14.4477 14.5 15V21H18C18.5523 21 19 20.5523 19 20V9.5" stroke="#000000" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
</svg>
''';

  static const String stock = '''
<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M3.5 7.5L12 3L20.5 7.5V16.5L12 21L3.5 16.5V7.5Z" stroke="#000000" stroke-width="1.8" stroke-linejoin="round"/>
<path d="M3.5 7.5L12 12M12 12L20.5 7.5M12 12V21" stroke="#000000" stroke-width="1.8" stroke-linejoin="round"/>
</svg>
''';

  static const String report = '''
<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M7 3.5H14L18 7.5V19.5C18 20.0523 17.5523 20.5 17 20.5H7C6.44772 20.5 6 20.0523 6 19.5V4.5C6 3.94772 6.44772 3.5 7 3.5Z" stroke="#000000" stroke-width="1.8" stroke-linejoin="round"/>
<path d="M9 12.5H15M9 15.5H15M9 9.5H11" stroke="#000000" stroke-width="1.8" stroke-linecap="round"/>
</svg>
''';

  static const String more = '''
<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
<circle cx="6" cy="6" r="2" fill="#000000"/>
<circle cx="12" cy="6" r="2" fill="#000000"/>
<circle cx="18" cy="6" r="2" fill="#000000"/>
<circle cx="6" cy="12" r="2" fill="#000000"/>
<circle cx="12" cy="12" r="2" fill="#000000"/>
<circle cx="18" cy="12" r="2" fill="#000000"/>
<circle cx="6" cy="18" r="2" fill="#000000"/>
<circle cx="12" cy="18" r="2" fill="#000000"/>
<circle cx="18" cy="18" r="2" fill="#000000"/>
</svg>
''';

  static const String plus = '''
<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M12 5V19M5 12H19" stroke="#FFFFFF" stroke-width="2.4" stroke-linecap="round"/>
</svg>
''';
}