import 'package:flutter/material.dart';

class VibrationPatternEditor extends StatefulWidget {
  final Function(List<int>, List<int>) onPatternUpdated;
  final List<int> initPattern;
  final List<int> initIntensities;
  final String name;

  const VibrationPatternEditor(
      {required this.onPatternUpdated,
      super.key,
      required this.initPattern,
      required this.initIntensities,
      required this.name});

  @override
  VibrationPatternEditorState createState() => VibrationPatternEditorState();
}

class VibrationPatternEditorState extends State<VibrationPatternEditor> {
  List<int> _pattern = [500, 1000, 500, 2000];
  List<int> _intensities = [0, 128, 0, 128]; // 0 for "Wait", 128 for "Vibrate"

  @override
  void initState() {
    super.initState();

    _pattern = widget.initPattern;
    _intensities = widget.initIntensities;
  }

  // Callback to update pattern
  void _updatePattern() {
    widget.onPatternUpdated(_pattern, _intensities);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [],
    );
  }
}
