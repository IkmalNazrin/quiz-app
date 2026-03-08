import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:quiz_domain/quiz_domain.dart';
import 'package:quiz_infrastructure/src/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:quiz_infrastructure/src/features/profile/data/models/profile_model.dart';
import 'package:quiz_infrastructure/src/features/profile/data/repositories/profile_repository_impl.dart';

class MockProfileRemoteDataSource extends Mock implements ProfileRemoteDataSource {}

void main() {
  late ProfileRepositoryImpl repository;
  late MockProfileRemoteDataSource mockRemoteDataSource;

  final tDate = DateTime(2023, 1, 1);
  final tProfileModel = ProfileModel(
    id: 'test_id',
    username: 'tester',
    createdAt: tDate,
  );

  setUpAll(() {
    registerFallbackValue(tProfileModel);
  });

  setUp(() {
    mockRemoteDataSource = MockProfileRemoteDataSource();
    repository = ProfileRepositoryImpl(mockRemoteDataSource);
  });

  group('getProfile', () {
    test('should return ProfileModel when remote data source call is successful', () async {
      when(() => mockRemoteDataSource.getProfile(any()))
          .thenAnswer((_) async => tProfileModel);

      final result = await repository.getProfile('test_id');

      verify(() => mockRemoteDataSource.getProfile('test_id'));
      expect(result, equals(tProfileModel));
    });

    test('should propagate exceptions from remote data source correctly', () async {
      when(() => mockRemoteDataSource.getProfile(any()))
          .thenThrow(const ServerFailure('Server Error'));

      expect(() => repository.getProfile('test_id'), throwsA(isA<ServerFailure>()));
    });
  });

  group('updateProfile', () {
    test('should call updateProfile on remote data source', () async {
      when(() => mockRemoteDataSource.updateProfile(any()))
          .thenAnswer((_) async => Future<void>.value());

      await repository.updateProfile(tProfileModel);

      verify(() => mockRemoteDataSource.updateProfile(any())).called(1);
    });
  });

  group('createProfile', () {
    test('should call createProfile on remote data source', () async {
      when(() => mockRemoteDataSource.createProfile(any()))
          .thenAnswer((_) async => Future<void>.value());

      await repository.createProfile(tProfileModel);

      verify(() => mockRemoteDataSource.createProfile(any())).called(1);
    });
  });
}
