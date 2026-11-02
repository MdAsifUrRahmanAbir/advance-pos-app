import 'package:flutter/painting.dart';

/// Turns the small HTML snippets the backend sends in text fields
/// (`<p>`, `<br />`, `<strong>`, `<small>`, `&amp;` ...) into display text.
///
/// - [toPlainText]: tags removed, entities decoded, `<br>` and the end of a
///   block (`</p>`, `</div>`, `</li>` ...) become line breaks.
/// - [toSingleLine]: same, on one line. For fields like a branch address.
/// - [toSpans]: like [toPlainText], but text inside `<strong>` / `<b>` comes
///   back bold. For multi-line blocks such as terms and conditions.
///
/// Not a full HTML parser: unknown tags are dropped and their text is kept.
class HtmlText {
  HtmlText._();

  static final RegExp _token = RegExp(r'<[^>]*>|[^<]+');
  static final RegExp _tagName = RegExp(r'^<\s*(/?)\s*([a-zA-Z0-9]+)');
  static final RegExp _whitespace = RegExp(r'\s+');
  static final RegExp _numericEntity = RegExp(r'&#([xX]?)([0-9a-fA-F]+);');

  static const String _lineBreak = '\n';
  static const Set<String> _lineBreakTags = {'br'};
  static const Set<String> _blockTags = {
    'p', 'div', 'li', 'tr', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6',
  };
  static const Set<String> _boldTags = {'strong', 'b'};

  static const Map<String, String> _namedEntities = {
    '&lt;': '<',
    '&gt;': '>',
    '&quot;': '"',
    '&apos;': "'",
    '&nbsp;': ' ',
    '&amp;': '&', // last, so "&amp;lt;" stays "&lt;"
  };

  static const TextStyle _boldStyle = TextStyle(fontWeight: FontWeight.w700);

  /// Plain text with line breaks; '' for null or blank input.
  static String toPlainText(String? html) =>
      _runs(html).map((run) => run.text).join();

  /// [toPlainText] on a single line (line breaks become spaces).
  static String toSingleLine(String? html) =>
      toPlainText(html).replaceAll(_whitespace, ' ').trim();

  /// Text runs in order. Bold runs carry a w700 style; the rest have no
  /// style and inherit the parent's.
  static List<TextSpan> toSpans(String? html) => [
    for (final run in _runs(html))
      TextSpan(text: run.text, style: run.bold ? _boldStyle : null),
  ];

  static List<_Run> _runs(String? html) {
    if (html == null || html.trim().isEmpty) return const [];

    final runs = <_Run>[];
    var boldDepth = 0;

    for (final match in _token.allMatches(html)) {
      final token = match.group(0)!;
      if (!token.startsWith('<')) {
        final text = _decode(token.replaceAll(_whitespace, ' '));
        if (text.isNotEmpty) runs.add(_Run(text, bold: boldDepth > 0));
        continue;
      }
      final tag = _tagName.firstMatch(token);
      if (tag == null) continue;
      final closing = tag.group(1)!.isNotEmpty;
      final name = tag.group(2)!.toLowerCase();

      if (_lineBreakTags.contains(name) ||
          (closing && _blockTags.contains(name))) {
        runs.add(const _Run(_lineBreak, bold: false));
      } else if (_boldTags.contains(name)) {
        boldDepth = closing ? (boldDepth > 0 ? boldDepth - 1 : 0) : boldDepth + 1;
      }
    }

    return _merge(_tidyLines(runs));
  }

  /// Per line: trims spaces at both ends. Then drops empty lines and any
  /// break at the very start or end.
  static List<_Run> _tidyLines(List<_Run> runs) {
    final lines = <List<_Run>>[[]];
    for (final run in runs) {
      if (run.text == _lineBreak) {
        lines.add([]);
      } else {
        lines.last.add(run);
      }
    }

    final out = <_Run>[];
    for (final line in lines) {
      final trimmed = _trimLine(line);
      if (trimmed.isEmpty) continue;
      if (out.isNotEmpty) out.add(const _Run(_lineBreak, bold: false));
      out.addAll(trimmed);
    }
    return out;
  }

  static List<_Run> _trimLine(List<_Run> line) {
    final runs = [...line];
    while (runs.isNotEmpty && runs.first.text.trimLeft().isEmpty) {
      runs.removeAt(0);
    }
    while (runs.isNotEmpty && runs.last.text.trimRight().isEmpty) {
      runs.removeLast();
    }
    if (runs.isEmpty) return runs;
    runs[0] = runs.first.copyWith(runs.first.text.trimLeft());
    runs[runs.length - 1] = runs.last.copyWith(runs.last.text.trimRight());
    return runs;
  }

  /// Joins neighbouring runs of the same weight. A line break joins the run
  /// before it, whatever its weight.
  static List<_Run> _merge(List<_Run> runs) {
    final out = <_Run>[];
    for (final run in runs) {
      if (out.isNotEmpty &&
          (run.text == _lineBreak || out.last.bold == run.bold)) {
        out[out.length - 1] = out.last.copyWith(out.last.text + run.text);
      } else {
        out.add(run);
      }
    }
    return out;
  }

  static String _decode(String text) {
    var out = text.replaceAllMapped(_numericEntity, (m) {
      final hex = m.group(1)!.isNotEmpty;
      final code = int.tryParse(m.group(2)!, radix: hex ? 16 : 10);
      return code == null ? m.group(0)! : String.fromCharCode(code);
    });
    _namedEntities.forEach((entity, char) => out = out.replaceAll(entity, char));
    return out;
  }
}

class _Run {
  final String text;
  final bool bold;

  const _Run(this.text, {required this.bold});

  _Run copyWith(String text) => _Run(text, bold: bold);
}