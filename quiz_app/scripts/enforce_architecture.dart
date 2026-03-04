import 'dart:io';

/// Enforces the Anti-Corruption Layer (ACL) defined in ARCHITECTURE.md.
/// Prevents feature/domain/UI code from directly importing infrastructure
/// dependencies like 'supabase_flutter' or 'drift'.
void main() {
  final packagesToScan = [
    'packages/quiz_domain',
    'packages/quiz_features',
    'packages/quiz_ui_core',
  ];

  final bannedImports = [
    'package:supabase_flutter/',
    'package:drift/',
    'package:quiz_infrastructure/',
  ];

  bool violationsFound = false;
  int filesScanned = 0;

  print('Starting Architecture Enforcement Scan...');
  print('Scanning packages: ${packagesToScan.join(', ')}');
  print('Banned imports: ${bannedImports.join(', ')}');
  print('--------------------------------------------------');

  for (final package in packagesToScan) {
    final dir = Directory(package);
    if (!dir.existsSync()) {
      print('Warning: Directory $package does not exist. Skipping.');
      continue;
    }

    final entities = dir.listSync(recursive: true);
    for (final entity in entities) {
      if (entity is File && entity.path.endsWith('.dart')) {
        filesScanned++;
        final lines = entity.readAsLinesSync();
        for (int i = 0; i < lines.length; i++) {
          final line = lines[i];
          if (line.trim().startsWith('import ')) {
            for (final banned in bannedImports) {
              if (line.contains(banned)) {
                print('VIOLATION FOUND:');
                print('File: ${entity.path}:${i + 1}');
                print('Line: $line');
                print('Reason: Direct import of $banned breaches Anti-Corruption Layer.');
                print('---');
                violationsFound = true;
              }
            }
          }
        }
      }
    }
  }

  print('--------------------------------------------------');
  print('Scanned $filesScanned Dart files.');
  
  if (violationsFound) {
    print('❌ Architecture violations detected! See above for details.');
    print('Please refactor the code to use interfaces from quiz_domain.');
    exit(1);
  } else {
    print('✅ Architecture scan passed. No violations found.');
    exit(0);
  }
}
