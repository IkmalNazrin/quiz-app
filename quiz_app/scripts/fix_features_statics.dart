import 'dart:io';

void main() async {
  final dir = Directory('packages/quiz_features/lib');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));

  for (final file in files) {
    String content = await file.readAsString();
    bool modified = false;

    if (content.contains('AppLogger.')) {
      content = content.replaceAllMapped(RegExp(r"AppLogger\.[iew]\((.*?)\);", dotAll: true), (m) {
          // Replace all logging with simple debugPrint taking the exact same arguments
          // If it had multiple args like e(e, st), debugPrint only takes one String, so we wrap it:
          String args = m.group(1)!;
          return "debugPrint(\\$args.toString());";
      });
      // A quick and dirty fix for the above wrap since dart doesn't like \$ directly on multiple args
      // We can just inject an interpolation:
      content = content.replaceAllMapped(RegExp(r"AppLogger\.[iew]\((.*?)\);", dotAll: true), (m) => "debugPrint('\${${m.group(1)}}');");
      modified = true;
    }

    if (content.contains('Supabase.instance.client.auth.currentUser?.id')) {
      content = content.replaceAll('Supabase.instance.client.auth.currentUser?.id', 'ref.read(authStateProvider).value?.id');
      modified = true;
    }
    
    // Fallback for simple Supabase auth
    if (content.contains('supabaseClient.auth.currentUser?.id')) {
      content = content.replaceAll('supabaseClient.auth.currentUser?.id', 'ref.read(authStateProvider).value?.id');
      modified = true;
    }

    if (content.contains('HapticService.') && !content.contains('package:quiz_ui_core/quiz_ui_core.dart')) {
      content = "import 'package:quiz_ui_core/quiz_ui_core.dart';\n" + content;
      modified = true;
    }

    if (modified) {
      if (content.contains('debugPrint') && !content.contains('package:flutter/foundation.dart') && !content.contains('import \'package:flutter/material.dart\'')) {
        content = "import 'package:flutter/foundation.dart';\n" + content;
      }
      
      if (content.contains('authStateProvider') && !content.contains('package:quiz_features/quiz_features.dart') && !content.contains('auth_provider.dart')) {
        content = "import 'package:quiz_features/quiz_features.dart';\n" + content;
      }
      
      await file.writeAsString(content);
      print('Fixed \${file.path}');
    }
  }
}
