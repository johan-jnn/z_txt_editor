import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class CachedDuckImage extends StatefulWidget {
  final String imageUrl;
  final double opacity;
  final BoxFit fit;

  const CachedDuckImage({
    super.key,
    required this.imageUrl,
    this.opacity = 1.0,
    this.fit = BoxFit.cover,
  });

  @override
  State<CachedDuckImage> createState() => _CachedDuckImageState();
}

class _CachedDuckImageState extends State<CachedDuckImage> {
  Uint8List? _imageBytes;
  bool _isLoading = true;
  bool _hasError = false;
  File? _cachedFile;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(CachedDuckImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _imageBytes = null;
    });

    try {
      // Try to download the image using Dio
      final response = await Dio().get<Uint8List>(
        widget.imageUrl,
        options: Options(responseType: ResponseType.bytes),
      );
      
      if (response.statusCode == 200) {
        final bytes = response.data!;
        
        // Cache the image locally
        try {
          final tempDir = await getTemporaryDirectory();
          final fileName = path.basename(widget.imageUrl);
          _cachedFile = File('${tempDir.path}/duck_$fileName');
          await _cachedFile!.writeAsBytes(bytes);
        } catch (e) {
          // Ignore cache errors
        }
        
        setState(() {
          _imageBytes = bytes;
          _isLoading = false;
        });
      } else {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    } on DioException catch (_) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        color: Colors.transparent,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_hasError || _imageBytes == null) {
      return Container(color: Colors.transparent);
    }

    return Opacity(
      opacity: widget.opacity,
      child: Image.memory(
        _imageBytes!,
        fit: widget.fit,
        alignment: Alignment.center,
        errorBuilder: (context, error, stackTrace) => Container(color: Colors.transparent),
      ),
    );
  }

  @override
  void dispose() {
    _cachedFile?.delete().ignore();
    super.dispose();
  }
}
