import 'package:hashlib/hashlib.dart' as hashlib;
import 'package:session_dart/src/session_client_impl/en_wordset.dart';

abstract class Mnemonic {
  //  TODO(f-person): Use Either with a sealed error type for return.
  static String decode(String str, {WordSet? wordSet}) {
    wordSet ??= WordSet.english();

    String out = '';
    final n = wordSet.words.length;
    final wordList = str.split(' ');
    if (wordList.length < 12) {
      throw Exception("You've entered too few words, please try again");
    }

    if ((wordSet.prefixLen == 0 && wordList.length % 3 != 0) ||
        (wordSet.prefixLen > 0 && wordList.length % 3 == 2)) {
      throw Exception("You've entered too few words, please try again");
    }

    if (wordSet.prefixLen > 0 && wordList.length % 3 == 0) {
      throw Exception(
          'You seem to be missing the last word in your private key, please try again');
    }

    final String checksumWord;
    if (wordSet.prefixLen > 0) {
      // Pop checksum from mnemonic
      checksumWord = wordList.removeLast();
    } else {
      checksumWord = '';
    }

    // Decode mnemonic
    for (int i = 0; i < wordList.length; i += 3) {
      final int w1, w2, w3;

      if (wordSet.prefixLen == 0) {
        w1 = wordSet.words.indexOf(wordList[i]);
        w2 = wordSet.words.indexOf(wordList[i + 1]);
        w3 = wordSet.words.indexOf(wordList[i + 2]);
      } else {
        w1 = wordSet.truncWords
            .indexOf(wordList[i].substring(0, wordSet.prefixLen));
        w2 = wordSet.truncWords
            .indexOf(wordList[i + 1].substring(0, wordSet.prefixLen));
        w3 = wordSet.truncWords
            .indexOf(wordList[i + 2].substring(0, wordSet.prefixLen));
      }
      if (w1 == -1 || w2 == -1 || w3 == -1) {
        throw Exception('invalid word in mnemonic');
      }

      final int x = w1 + n * ((n - w1 + w2) % n) + n * n * ((n - w2 + w3) % n);
      if (x % n != w1) {
        throw Exception('invalid word in mnemonic');
      }

      out += _swapEndian4Byte(x.toRadixString(16).padLeft(8, '0'));
    }

    // Verify checksum
    if (wordSet.prefixLen > 0) {
      final index = _getChecksumIndex(wordList, wordSet.prefixLen);
      final expectedChecksumWord = wordList[index];
      if (expectedChecksumWord.substring(0, wordSet.prefixLen) !=
          checksumWord.substring(0, wordSet.prefixLen)) {
        throw Exception('invalid checksum');
      }
    }

    return out;
  }

  static int _getChecksumIndex(List<String> words, int prefixLen) {
    String trimmedWords = '';
    for (final word in words) {
      trimmedWords += word.substring(0, prefixLen);
    }

    final checksum = hashlib.crc32code(trimmedWords);

    return checksum % words.length;
  }

  static String _swapEndian4Byte(String str) {
    if (str.length != 8) {
      throw Exception('Invalid input length: ${str.length}');
    }

    return str.substring(6, 8) +
        str.substring(4, 6) +
        str.substring(2, 4) +
        str.substring(0, 2);
  }
}

class WordSet {
  const WordSet({
    required this.words,
    required this.truncWords,
    required this.prefixLen,
  });

  factory WordSet.english() {
    const prefixLen = 3;

    return WordSet(
      words: enWordSet,
      truncWords: _getTruncWords(enWordSet, prefixLen),
      prefixLen: prefixLen,
    );
  }

  static List<String> _getTruncWords(List<String> words, int prefixLen) {
    if (prefixLen == 0) {
      return const [];
    }

    return [
      for (final word in words) word.substring(0, prefixLen),
    ];
  }

  final List<String> words;
  final List<String> truncWords;
  final int prefixLen;
}
