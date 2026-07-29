import 'package:flutter/material.dart';

class PitchModel {
  dynamic id; 
  TextEditingController nameCon = TextEditingController();
  TextEditingController modifierCon = TextEditingController(text: '+0.00');
  String selectedFormat = '5-A-Side';
  String selectedSurface = 'AstroTurf';

  PitchModel({
    this.id,
    String? name,
    String? format,
    String? surface,
    String? modifier,
  }) {
    if (name != null) nameCon.text = name;
    if (format != null) selectedFormat = format;
    if (surface != null) selectedSurface = surface;
    if (modifier != null) modifierCon.text = modifier;
  }
}