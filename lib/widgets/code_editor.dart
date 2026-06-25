import 'dart:math' show max;

import 'package:flutter/material.dart';
import 'package:flutter_highlight/themes/vs2015.dart';
import 'package:highlight/highlight.dart' show highlight, Node;

class SyntaxHighlightController extends TextEditingController {
  String _language;

  SyntaxHighlightController({this._language = '', super.text});

  String get language => _language;

  set language(String value) {
    if (_language != value) {
      _language = value;
      notifyListeners();
    }
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    if (_language.isEmpty || (value.composing.isValid && withComposing)) {
      return super.buildTextSpan(
        context: context,
        style: style,
        withComposing: withComposing,
      );
    }
    try {
      final parsed = highlight.parse(text, language: _language);
      final nodes = parsed.nodes;
      if (nodes == null || nodes.isEmpty) {
        return TextSpan(text: text, style: style);
      }
      return TextSpan(style: style, children: _buildSpans(nodes));
    } catch (_) {
      return TextSpan(text: text, style: style);
    }
  }

  List<TextSpan> _buildSpans(List<Node> nodes) {
    return nodes.map((node) {
      final nodeStyle = node.className != null
          ? vs2015Theme[node.className!]
          : null;
      if (node.value != null) {
        return TextSpan(text: node.value, style: nodeStyle);
      }
      return TextSpan(
        children: _buildSpans(node.children ?? []),
        style: nodeStyle,
      );
    }).toList();
  }
}

class CodeEditor extends StatefulWidget {
  final SyntaxHighlightController controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;

  const CodeEditor({
    super.key,
    required this.controller,
    this.focusNode,
    this.onChanged,
  });

  @override
  State<CodeEditor> createState() => _CodeEditorState();
}

class _CodeEditorState extends State<CodeEditor> {
  final _vScroll = ScrollController();
  final _hScroll = ScrollController();

  static const double _fontSize = 14.0;
  static const double _lineHeight = 20.0;
  static const double _lineNumWidth = 52.0;
  // Measured at initState via TextPainter for accurate no-wrap guarantee
  double _charWidth = 8.5;

  @override
  void initState() {
    super.initState();
    _charWidth = _measureCharWidth();
    widget.controller.addListener(_onCursorChanged);
  }

  @override
  void didUpdateWidget(CodeEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onCursorChanged);
      widget.controller.addListener(_onCursorChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onCursorChanged);
    _vScroll.dispose();
    _hScroll.dispose();
    super.dispose();
  }

  // Measure the actual rendered character width for the code font.
  // Using 40 chars to average out sub-pixel rounding.
  double _measureCharWidth() {
    const sample = 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'; // 40 chars
    final tp = TextPainter(
      text: const TextSpan(
        text: sample,
        style: TextStyle(fontFamily: 'monospace', fontSize: _fontSize),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final width = tp.width / sample.length;
    tp.dispose();
    return width;
  }

  void _onCursorChanged() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _followCursor());
  }

  void _followCursor() {
    if (!mounted || !_vScroll.hasClients) return;
    final selection = widget.controller.selection;
    if (!selection.isValid) return;

    final text = widget.controller.text;
    final selOffset = selection.baseOffset.clamp(0, text.length);
    final lineIndex = '\n'.allMatches(text.substring(0, selOffset)).length;
    final cursorTop = lineIndex * _lineHeight;
    final cursorBottom = cursorTop + _lineHeight;

    final viewportH = _vScroll.position.viewportDimension;
    final scrollOffset = _vScroll.offset;
    final maxScroll = _vScroll.position.maxScrollExtent;

    if (cursorTop < scrollOffset) {
      _vScroll.jumpTo(cursorTop.clamp(0.0, maxScroll));
    } else if (cursorBottom > scrollOffset + viewportH) {
      _vScroll.jumpTo((cursorBottom - viewportH).clamp(0.0, maxScroll));
    }
  }

  double _estimateContentWidth() {
    final lines = widget.controller.text.split('\n');
    final maxLen = lines.fold<int>(
      0,
      (acc, line) => line.length > acc ? line.length : acc,
    );
    // Extra 200px right margin so the longest line is never clipped
    return maxLen * _charWidth + 200.0;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          // Single vertical scroll drives both line numbers and code simultaneously.
          // No controller sync needed — they're siblings in the same scroll view.
          controller: _vScroll,
          child: Padding(
            padding: EdgeInsets.only(bottom: constraints.maxHeight * 0.25),
            child: ListenableBuilder(
              listenable: widget.controller,
              builder: (context, _) {
                final lineCount =
                    '\n'.allMatches(widget.controller.text).length + 1;
                // Available width for the code pane (screen minus line numbers gutter)
                final codeAreaWidth = constraints.maxWidth - _lineNumWidth;
                final effectiveWidth = max(
                  codeAreaWidth,
                  _estimateContentWidth(),
                );

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Gutter — scrolls with the code because it's inside the same SV
                    SizedBox(
                      width: _lineNumWidth,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(
                          lineCount,
                          (i) => SizedBox(
                            height: _lineHeight,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  '${i + 1}',
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: _fontSize,
                                    height: 1.0,
                                    color: Color(0xFF858585),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Code pane — horizontal scroll only
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        controller: _hScroll,
                        // SizedBox gives the TextField a fixed width so it never wraps
                        child: SizedBox(
                          width: effectiveWidth,
                          child: TextField(
                            controller: widget.controller,
                            focusNode: widget.focusNode,
                            maxLines: null,
                            // Vertical scroll is handled by the outer SV above
                            scrollPhysics: const NeverScrollableScrollPhysics(),
                            onChanged: widget.onChanged,
                            textAlignVertical: TextAlignVertical.top,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: _fontSize,
                              height: _lineHeight / _fontSize,
                              color: Color(0xFFD4D4D4),
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: _lineHeight / 8,
                              ),
                              fillColor: Colors.transparent,
                              filled: true,
                            ),
                            cursorColor: Colors.white,
                            keyboardType: TextInputType.multiline,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}
