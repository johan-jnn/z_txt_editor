import 'package:flutter/material.dart';

class CodeEditor extends StatefulWidget {
  final TextEditingController controller;
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
  final _codeScroll = ScrollController();
  final _lineScroll = ScrollController();

  static const double _lineHeight = 20.0;
  static const double _fontSize = 14.0;
  static const double _lineNumWidth = 52.0;

  @override
  void initState() {
    super.initState();
    _codeScroll.addListener(_syncLineScroll);
  }

  @override
  void dispose() {
    _codeScroll.removeListener(_syncLineScroll);
    _codeScroll.dispose();
    _lineScroll.dispose();
    super.dispose();
  }

  void _syncLineScroll() {
    if (_lineScroll.hasClients) {
      _lineScroll.jumpTo(_codeScroll.offset);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: _lineNumWidth,
          child: Container(
            color: Colors.transparent,
            child: ListenableBuilder(
              listenable: widget.controller,
              builder: (context, _) {
                final lineCount = '\n'.allMatches(widget.controller.text).length + 1;
                return SingleChildScrollView(
                  controller: _lineScroll,
                  physics: const NeverScrollableScrollPhysics(),
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
                );
              },
            ),
          ),
        ),
        Expanded(
          child: TextField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            maxLines: null,
            expands: true,
            scrollController: _codeScroll,
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
              contentPadding: EdgeInsets.symmetric(horizontal: 8),
              fillColor: Colors.transparent,
              filled: true,
            ),
            cursorColor: Colors.white,
            keyboardType: TextInputType.multiline,
          ),
        ),
      ],
    );
  }
}
