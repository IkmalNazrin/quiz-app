abstract class LegalRepository {
  Future<bool> hasAcceptedTerms();
  Future<void> acceptTerms();
  String get termsUrl;
  String get privacyPolicyUrl;
}
