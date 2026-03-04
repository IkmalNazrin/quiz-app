import 'package:profanity_filter/profanity_filter.dart';

class ContentModeration {
  static final _filter = ProfanityFilter();

  static bool isProfane(String text) {
    return _filter.hasProfanity(text);
  }

  static String sanitize(String text) {
    return _filter.censor(text);
  }

  static String? validateNickname(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nickname cannot be empty';
    }
    if (isProfane(value)) {
      return 'Please choose a more appropriate nickname';
    }
    if (value.length > 20) {
      return 'Nickname is too long (max 20 characters)';
    }
    return null;
  }
}
