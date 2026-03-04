import 'dart:io';

void main() {
  var file = File('packages/quiz_domain/lib/src/features/challenge/domain/repositories/challenge_repository.dart');
  var content = file.readAsStringSync();
  content = content.replaceFirst(
    '  Future<Either<Failure, void>> sendChallenge(',
    '  Future<Either<Failure, ChallengeEntity>> getChallengeById(String id);\n  Future<Either<Failure, void>> sendChallenge('
  );
  file.writeAsStringSync(content);

  file = File('packages/quiz_infrastructure/lib/src/features/challenge/data/datasources/challenge_remote_data_source.dart');
  content = file.readAsStringSync();
  content = content.replaceFirst(
    '  Future<void> createChallenge(',
    '  Future<ChallengeModel> getChallengeById(String id);\n  Future<void> createChallenge('
  );
  content = content.replaceFirst(
    '  @override\n  Future<List<ChallengeModel>> getMyChallenges() async {',
    '''  @override
  Future<ChallengeModel> getChallengeById(String id) async {
    final response = await supabaseClient.from('challenges').select().eq('id', id).single();
    response['id'] = response['id'].toString();
    response['quizTitle'] = response['quiz_title'] ?? response['quiz_id']; // HACK for quiz_id
    return ChallengeModel.fromJson(response);
  }

  @override
  Future<List<ChallengeModel>> getMyChallenges() async {'''
  );
  file.writeAsStringSync(content);

  file = File('packages/quiz_infrastructure/lib/src/features/challenge/data/repositories/challenge_repository_impl.dart');
  content = file.readAsStringSync();
  content = content.replaceFirst(
    '  @override\n  Future<Either<Failure, List<ChallengeEntity>>> getMyChallenges() async {',
    '''  @override
  Future<Either<Failure, ChallengeEntity>> getChallengeById(String id) async {
    try {
      final challenge = await remoteDataSource.getChallengeById(id);
      return Right(challenge);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ChallengeEntity>>> getMyChallenges() async {'''
  );
  file.writeAsStringSync(content);

  file = File('packages/quiz_features/lib/src/features/challenge/presentation/pages/challenge_loading_screen.dart');
  content = file.readAsStringSync();

  content = content.replaceAll(
    '''final quiz = await ref
            .read(quizRemoteDataSourceProvider)
            .getQuizDetails(widget.quizId!);''',
    '''final quizEither = await ref.read(quizRepositoryProvider).getQuizDetails(widget.quizId!);
        final quiz = quizEither.fold((l) => throw Exception(l.message), (r) => r);'''
  );

  content = content.replaceAll(
    '''final response = await Supabase.instance.client
            .from('challenges')
            .select()
            .eq('id', widget.challengeId!)
            .single();

        _challengeData = response;
        final quizId = response['quiz_id'];
        final quiz =
            await ref.read(quizRemoteDataSourceProvider).getQuizDetails(quizId);''',
    '''final challengeEither = await ref.read(challengeRepositoryProvider).getChallengeById(widget.challengeId!);
        final challenge = challengeEither.fold((l) => throw Exception(l.message), (r) => r);
        _challengeData = {'id': challenge.id, 'quiz_id': challenge.quizTitle};
        final quizId = challenge.quizTitle; // Model sets quiz_id to quizTitle
        final quizEither = await ref.read(quizRepositoryProvider).getQuizDetails(quizId);
        final quiz = quizEither.fold((l) => throw Exception(l.message), (r) => r);'''
  );

  content = content.replaceFirst(
    "import 'package:supabase_flutter/supabase_flutter.dart';",
    ""
  );

  file.writeAsStringSync(content);
}
