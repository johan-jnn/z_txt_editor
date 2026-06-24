import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

/// Advanced color picker that allows selecting any color
class AdvancedColorPicker extends StatefulWidget {
  final Color color;
  final ValueChanged<Color> onColorChanged;

  const AdvancedColorPicker({
    super.key,
    required this.color,
    required this.onColorChanged,
  });

  @override
  State<AdvancedColorPicker> createState() => _AdvancedColorPickerState();
}

class _AdvancedColorPickerState extends State<AdvancedColorPicker> {
  late Color currentColor;

  @override
  void initState() {
    super.initState();
    currentColor = widget.color;
  }

  @override
  void didUpdateWidget(AdvancedColorPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.color != widget.color) {
      currentColor = widget.color; 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ColorPicker(
          pickerColor: currentColor,
          onColorChanged: (color) {
            setState(() => currentColor = color);
            widget.onColorChanged(color);
          },
          pickerAreaHeightPercent: 0.8,
          displayThumbColor: false,
          portraitOnly: true,
          enableAlpha: false,
          hexInputBar: true,
          labelTypes: const [],
        ),
      ],
    );
  }
}
