import 'dart:io';

void main() async {
  final directory = Directory('packages/quiz_infrastructure/lib/src');
  final files = directory.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));

  int modifiedFilesCount = 0;

  for (final file in files) {
    String content = await file.readAsString();
    if (content.contains('return throw ServerFailure(e.message);')) {
      content = content.replaceAll('return throw ServerFailure(e.message);', 'throw ServerFailure(e.message);');
      await file.writeAsString(content);
      modifiedFilesCount++;
      print('Fixed return throw in: \${file.path}');
    }
  }

  print('Total files fixed: \$modifiedFilesCount');
}
