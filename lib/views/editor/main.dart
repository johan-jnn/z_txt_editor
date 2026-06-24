import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:z_txt_editor/widgets/code_editor.dart';
import 'package:z_txt_editor/widgets/z_app_bar.dart';

class Editor extends StatefulWidget {
  const Editor({super.key});

  @override
  State<Editor> createState() => _EditorState();
}

class _EditorState extends State<Editor> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  String? _filePath;
  String _fileName = '';
  String _savedContent = '';

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  bool _hasUnsavedChanges() => _controller.text != _savedContent;

  Future<void> _openFile() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['html', 'css', 'js', 'md', 'py', 'txt'],
        withData: true,
      );
      if (result == null || !mounted) return;

      final file = result.files.single;
      if (file.bytes == null) return;

      final content = String.fromCharCodes(file.bytes!);

      if (!mounted) return;
      setState(() {
        _controller.text = content;
        _savedContent = content;
        _filePath = file.path;
        _fileName = file.name;
      });
    } catch (e) {
      if (mounted) _snack('Failed to open file: $e');
    }
  }

  Future<void> _saveFile() async {
    if (_filePath != null) {
      await _writeFile(_filePath!);
    } else {
      await _saveNew();
    }
  }

  Future<void> _saveNew() async {
    if (kIsWeb) {
      _snack('Saving not supported on web.');
      return;
    }
    final name = _fileName.isEmpty ? 'untitled.txt' : _fileName;
    // FilePicker.saveFile() is desktop-only — on mobile save to documents dir
    if (Platform.isAndroid || Platform.isIOS) {
      try {
        final dir = await getApplicationDocumentsDirectory();
        final path = '${dir.path}/$name';
        await _writeFile(path);
        if (mounted) setState(() { _filePath = path; _fileName = name; });
      } catch (e) {
        if (mounted) _snack('Failed to save: $e');
      }
      return;
    }
    try {
      final path = await FilePicker.saveFile(dialogTitle: 'Save as', fileName: name);
      if (path == null || !mounted) return;
      await _writeFile(path);
      setState(() { _filePath = path; _fileName = path.split('/').last; });
    } catch (e) {
      if (mounted) _snack('Failed to save: $e');
    }
  }

  Future<void> _writeFile(String path) async {
    try {
      await File(path).writeAsString(_controller.text);
      if (mounted) {
        setState(() => _savedContent = _controller.text);
        _snack('Saved');
      }
    } catch (e) {
      if (mounted) _snack('Failed to write file: $e');
    }
  }

  Future<void> _closeEditor() async {
    if (!_hasUnsavedChanges()) {
      if (mounted) context.goNamed('home');
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Unsaved changes'),
        content: const Text('Close without saving?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Close'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) context.goNamed('home');
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final title = _fileName.isEmpty
        ? 'New File'
        : _hasUnsavedChanges()
            ? '$_fileName •'
            : _fileName;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: ZAppBar(
        title: title,
        actions: [
          IconButton(
            icon: const Icon(Icons.save_outlined),
            tooltip: 'Save',
            onPressed: _saveFile,
          ),
          IconButton(
            icon: const Icon(Icons.folder_open_outlined),
            tooltip: 'Open file',
            onPressed: _openFile,
          ),
          IconButton(
            icon: const Icon(Icons.close),
            tooltip: 'Close',
            onPressed: _closeEditor,
          ),
        ],
      ),
      body: _fileName.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.insert_drive_file_outlined,
                    size: 64,
                    color: Colors.white24,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No file open',
                    style: TextStyle(color: Colors.white38),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _openFile,
                    icon: const Icon(Icons.folder_open),
                    label: const Text('Open a file'),
                  ),
                ],
              ),
            )
          : CodeEditor(
              controller: _controller,
              focusNode: _focusNode,
              onChanged: (_) => setState(() {}),
            ),
    );
  }
}
