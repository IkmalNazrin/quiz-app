import 'dart:io';

void main() {
  final f = File('packages/quiz_infrastructure/lib/src/features/challenge/data/datasources/challenge_remote_data_source.dart');
  var c = f.readAsStringSync();

  // Find the first @override before getMyChallenges
  final marker = 'Future<List<ChallengeModel>> getMyChallenges() async {';
  final idx = c.indexOf(marker);
  if (idx == -1) {
    print('ERROR: could not find getMyChallenges marker');
    return;
  }

  // Find the @override above it
  final overrideIdx = c.lastIndexOf('@override', idx);
  if (overrideIdx == -1) {
    print('ERROR: could not find @override before getMyChallenges');
    return;
  }

  final implementation = '''  @override
  Future<ChallengeModel> getChallengeById(String id) async {
    try {
      final response = await supabaseClient
          .from('challenges')
          .select()
          .eq('id', id)
          .single();
      return ChallengeModel.fromJson(response);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  ''';

  c = c.substring(0, overrideIdx) + implementation + c.substring(overrideIdx);
  f.writeAsStringSync(c);
  print('Done: getChallengeById inserted.');
}
