import 'dart:io';

void main() async {
  final directory = Directory('packages/quiz_infrastructure/lib/src');
  final files = directory.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));

  int modifiedFilesCount = 0;

  for (final file in files) {
    String content = await file.readAsString();
    bool modified = false;

    // We must ensure the file imports supabase_flutter and dart:io if we inject these types
    bool needsSupabase = false;
    bool needsIo = false;

    // Case 1: Repository catching & returning Left(ServerFailure)
    final repoPattern = RegExp(r'\}\s*catch\s*\(\s*e\s*\)\s*\{\s*return\s+Left\(\s*ServerFailure\(\s*e\.toString\(\)\s*\)\s*\);\s*\}', multiLine: true);
    if (repoPattern.hasMatch(content)) {
      content = content.replaceAll(repoPattern, '''} on AuthException catch (e) {
      return Left(ServerFailure(e.message));
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') return Left(NotFoundFailure(e.message));
      return Left(ServerFailure(e.message));
    } on SocketException catch (_) {
      return Left(const NetworkFailure());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }''');
      needsSupabase = true;
      needsIo = true;
      modified = true;
    }

    // Case 2: DataSource throwing ServerFailure
    final dsPattern = RegExp(r'\}\s*catch\s*\(\s*e\s*\)\s*\{\s*throw\s+ServerFailure\(\s*e\.toString\(\)\s*\);\s*\}', multiLine: true);
    if (dsPattern.hasMatch(content)) {
      content = content.replaceAll(dsPattern, '''} on AuthException catch (e) {
      throw ServerFailure(e.message);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') throw NotFoundFailure(e.message);
      return throw ServerFailure(e.message);
    } on SocketException catch (_) {
      throw const NetworkFailure();
    } catch (e) {
      throw ServerFailure(e.toString());
    }''');
      needsSupabase = true;
      needsIo = true;
      modified = true;
    }

    // Insert imports if necessary and not present
    if (modified) {
      if (needsSupabase && !content.contains("package:supabase_flutter/supabase_flutter.dart")) {
        content = "import 'package:supabase_flutter/supabase_flutter.dart';\n" + content;
      }
      if (needsIo && !content.contains("import 'dart:io';")) {
        content = "import 'dart:io';\n" + content;
      }
      
      await file.writeAsString(content);
      modifiedFilesCount++;
      print('Modified: \${file.path}');
    }
  }

  print('Total files modified: \$modifiedFilesCount');
}
