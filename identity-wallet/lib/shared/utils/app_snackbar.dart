import 'package:flutter/material.dart';

/// Muestra un [SnackBar] breve con [message] usando el [ScaffoldMessenger] actual.
void showAppSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
