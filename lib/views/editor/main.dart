import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:z_txt_editor/utils/file_download.dart';
import 'package:z_txt_editor/widgets/code_editor.dart';
import 'package:z_txt_editor/widgets/z_app_bar.dart';

class Editor extends StatefulWidget {
  const Editor({super.key});

  @override
  State<Editor> createState() => _EditorState();
}

class _EditorState extends State<Editor> {
  final _controller = SyntaxHighlightController();
  final _focusNode = FocusNode();
  // _filePath is only set when we have a real, writable filesystem path.
  // When file_picker caches the file to a temp dir, this stays null.
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

  String _detectLanguage(String fileName) {
    final ext = fileName.contains('.') ? fileName.split('.').last.toLowerCase() : '';
    return switch (ext) {
      'js' => 'javascript',
      'html' => 'html',
      'css' => 'css',
      'md' => 'markdown',
      'py' => 'python',
      'json' => 'json',
      _ => 'plaintext',
    };
  }

  Future<void> _openFile() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['html', 'css', 'js', 'md', 'py', 'txt', 'json'],
        withData: true,
      );
      if (result == null || !mounted) return;

      final file = result.files.single;
      if (file.bytes == null) return;

      final content = utf8.decode(file.bytes!, allowMalformed: true);

      // file_picker on Android copies files to a temp cache dir.
      // Detect this and treat as "no writable path" so Save goes through Save As.
      String? effectivePath = file.path;
      if (effectivePath != null && !kIsWeb) {
        try {
          final tmp = await getTemporaryDirectory();
          if (effectivePath.startsWith(tmp.path)) effectivePath = null;
        } catch (_) {}
      }

      if (!mounted) return;
      setState(() {
        _controller.text = content;
        _savedContent = content;
        _filePath = effectivePath;
        _fileName = file.name;
        _controller.language = _detectLanguage(file.name);
      });
    } catch (e) {
      if (mounted) _snack('Failed to open file: $e');
    }
  }

  // Save — writes directly to the original path when available.
  // Falls back to Save As when the path is unknown or unwritable.
  Future<void> _saveFile() async {
    if (kIsWeb) {
      triggerWebDownload(_fileName.isEmpty ? 'untitled.txt' : _fileName, _controller.text);
      return;
    }

    if (_filePath == null) {
      // No writable path (file came from Android cache, or never saved) — use Save As
      await _saveAs();
      return;
    }

    try {
      await File(_filePath!).writeAsString(_controller.text, encoding: utf8);
      if (!mounted) return;
      setState(() => _savedContent = _controller.text);
      _snack('Saved');
    } catch (_) {
      if (!mounted) return;
      _snack('Cannot write to the original file. Use "Save as" instead.');
    }
  }

  // Save As — uses FilePicker.saveFile(bytes:) which writes through
  // Android ContentResolver, so it works with Downloads and any SAF location.
  // Falls back to a name dialog + app external dir if the picker is unavailable.
  Future<void> _saveAs() async {
    if (kIsWeb) {
      final name = await _promptFileName();
      if (name == null || !mounted) return;
      triggerWebDownload(name, _controller.text);
      return;
    }

    try {
      final bytes = utf8.encode(_controller.text);
      final result = await FilePicker.saveFile(
        dialogTitle: 'Save as',
        fileName: _fileName.isEmpty ? 'untitled.txt' : _fileName,
        bytes: bytes,
      );

      if (result == null || !mounted) return;

      // bytes were already written by file_picker (via ContentResolver on Android).
      // If the result is a real path (not a content URI), we can also use it for
      // future direct saves. If it's a content URI, we keep _filePath = null.
      final isContentUri = result.startsWith('content://');
      setState(() {
        _savedContent = _controller.text;
        if (!isContentUri) {
          _filePath = result;
          _fileName = result.split('/').last;
        }
      });
      _snack('Saved');
    } on UnimplementedError {
      // FilePicker.saveFile() not available on this platform/version
      await _fallbackSave();
    } catch (e) {
      if (mounted) _snack('Failed to save: $e');
    }
  }

  // Fallback when FilePicker.saveFile() is unavailable:
  // ask for a name and write to the app's external storage directory.
  Future<void> _fallbackSave() async {
    final name = await _promptFileName();
    if (name == null || name.isEmpty || !mounted) return;

    try {
      Directory? dir;
      if (Platform.isAndroid) dir = await getExternalStorageDirectory();
      dir ??= await getApplicationDocumentsDirectory();
      final path = '${dir.path}/$name';
      await File(path).writeAsString(_controller.text, encoding: utf8);
      if (!mounted) return;
      setState(() {
        _savedContent = _controller.text;
        _filePath = path;
        _fileName = name;
      });
      _snack('Saved to $path');
    } catch (e) {
      if (mounted) _snack('Failed to save: $e');
    }
  }

  Future<String?> _promptFileName() {
    final nameCtrl = TextEditingController(
      text: _fileName.isEmpty ? 'untitled.txt' : _fileName,
    );
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Save as'),
        content: TextField(
          controller: nameCtrl,
          decoration: const InputDecoration(labelText: 'File name'),
          autofocus: true,
          onSubmitted: (_) => Navigator.of(ctx).pop(nameCtrl.text.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(nameCtrl.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
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
          PopupMenuButton<String>(
            icon: const Icon(Icons.save_outlined),
            tooltip: 'Save',
            onSelected: (value) {
              if (value == 'save') _saveFile();
              if (value == 'saveAs') _saveAs();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'save',
                child: ListTile(
                  leading: Icon(Icons.save_outlined),
                  title: Text('Save'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              PopupMenuItem(
                value: 'saveAs',
                child: ListTile(
                  leading: Icon(Icons.save_as_outlined),
                  title: Text('Save as'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
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
                  const Icon(Icons.insert_drive_file_outlined, size: 64, color: Colors.white24),
                  const SizedBox(height: 16),
                  const Text('No file open', style: TextStyle(color: Colors.white38)),
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
