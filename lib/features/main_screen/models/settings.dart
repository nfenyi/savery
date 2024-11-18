import 'package:flutter/material.dart';

class Setting {
  final IconData icon;
  final String name;
  final Function? callback;

  Setting({
    required this.icon,
    required this.name,
    this.callback,
  });
}
