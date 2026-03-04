import 'package:quiz_domain/quiz_domain.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LegalRepositoryImpl implements LegalRepository {
  static const _key = 'has_accepted_legal_terms_v1';
  final String _termsUrl;
  final String _privacyPolicyUrl;

  LegalRepositoryImpl({
    String? termsUrl,
    String? privacyPolicyUrl,
  })  : _termsUrl = termsUrl ?? const String.fromEnvironment('TERMS_URL', defaultValue: 'https://quizarena.app/terms'),
        _privacyPolicyUrl = privacyPolicyUrl ?? const String.fromEnvironment('PRIVACY_URL', defaultValue: 'https://quizarena.app/privacy');

  @override
  Future<bool> hasAcceptedTerms() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }

  @override
  Future<void> acceptTerms() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
  }

  @override
  String get termsUrl => _termsUrl;

  @override
  String get privacyPolicyUrl => _privacyPolicyUrl;
}
