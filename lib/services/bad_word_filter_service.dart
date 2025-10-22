/// Service to filter and detect inappropriate/bad words in user input
class BadWordFilterService {
  // Helper method to escape special regex characters
  static String _escapeRegex(final String str) {
    return str.replaceAllMapped(
      RegExp(r'[.*+?^${}()|[\]\\]'),
      (final match) => '\\${match.group(0)}',
    );
  }

  // Comprehensive list of bad words to filter
  // Note: This is a basic implementation. For production, consider using
  // a more comprehensive profanity filter package or API
  static final List<String> _badWords = [
    // Common profanity
    'damn',
    'hell',
    'crap',
    'shit',
    'fuck',
    'bitch',
    'bastard',
    'ass',
    'asshole',
    'dick',
    'cock',
    'pussy',
    'piss',
    'whore',
    'slut',
    'fag',
    'nigger',
    'cunt',
    'bollocks',
    'bugger',
    'bloody',
    'wanker',

    // Variants with different spellings
    'f**k',
    'f*ck',
    'sh!t',
    'sh*t',
    'b!tch',
    'b*tch',
    r'a$$',
    'a**',
    '@ss',
    'd!ck',
    'd*ck',
    'p!ss',
    'p*ss',

    // Sexual/offensive terms
    'sex',
    'porn',
    'xxx',
    'rape',
    'nazi',
    'terrorist',
    'kill',
    'murder',
    'suicide',
    'die',

    // Spam/scam related
    'scam',
    'fraud',
    'fake',
    'cheat',
    'hack',
    'steal',

    // Drug related
    'cocaine',
    'heroin',
    'meth',
    'weed',
    'marijuana',
    'drugs',

    // Add more words as needed
  ];

  /// Check if text contains any bad words
  /// Returns true if bad words are found
  static bool containsBadWords(final String text) {
    if (text.isEmpty) return false;

    final String lowerText = text.toLowerCase();

    // Check for exact word matches (with word boundaries)
    for (final String badWord in _badWords) {
      // Use word boundary regex to avoid false positives
      // For example, "class" should not match "ass"
      final RegExp wordBoundary = RegExp(
        r'\b' + _escapeRegex(badWord) + r'\b',
        caseSensitive: false,
      );

      if (wordBoundary.hasMatch(lowerText)) {
        return true;
      }
    }

    // Check for obfuscated versions (e.g., f.u.c.k, f u c k)
    // Only check for words without special characters to avoid regex issues
    for (final String badWord in _badWords) {
      // Skip words with special regex characters like *, $, !, @, etc.
      if (badWord.length >= 4 &&
          !badWord.contains(RegExp(r'[*$!@#%^&()[\]{}\\|<>?.+]'))) {
        try {
          // Check for spaced version (e.g., "f u c k")
          final String spacedPattern =
              badWord.split('').map((final char) => _escapeRegex(char)).join(r'\s*');
          final RegExp spacedRegex =
              RegExp(spacedPattern, caseSensitive: false);
          if (spacedRegex.hasMatch(lowerText)) {
            return true;
          }

          // Check for dotted version (e.g., "f.u.c.k")
          final String dottedPattern =
              badWord.split('').map((final char) => _escapeRegex(char)).join(r'\.?');
          final RegExp dottedRegex =
              RegExp(dottedPattern, caseSensitive: false);
          if (dottedRegex.hasMatch(lowerText)) {
            return true;
          }
        } catch (e) {
          // Skip if regex compilation fails
          continue;
        }
      }
    }

    return false;
  }

  /// Get list of bad words found in text
  static List<String> getBadWords(final String text) {
    if (text.isEmpty) return [];

    final String lowerText = text.toLowerCase();
    final List<String> foundWords = [];

    for (final String badWord in _badWords) {
      final RegExp wordBoundary = RegExp(
        r'\b' + _escapeRegex(badWord) + r'\b',
        caseSensitive: false,
      );

      if (wordBoundary.hasMatch(lowerText)) {
        foundWords.add(badWord);
      }
    }

    return foundWords;
  }

  /// Clean text by replacing bad words with asterisks
  static String cleanText(final String text) {
    if (text.isEmpty) return text;

    String cleanedText = text;

    for (final String badWord in _badWords) {
      final RegExp wordBoundary = RegExp(
        r'\b' + _escapeRegex(badWord) + r'\b',
        caseSensitive: false,
      );

      // Replace with asterisks of same length
      final String replacement = '*' * badWord.length;
      cleanedText = cleanedText.replaceAllMapped(
        wordBoundary,
        (final match) => replacement,
      );
    }

    return cleanedText;
  }

  /// Validate text and return error message if bad words found
  static String? validateText(final String text) {
    if (containsBadWords(text)) {
      return 'Please avoid using inappropriate language';
    }
    return null;
  }

  /// Get sanitized version of text for display
  static String sanitize(final String text) {
    return cleanText(text);
  }
}
