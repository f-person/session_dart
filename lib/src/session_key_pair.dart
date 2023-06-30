import 'dart:typed_data';

import 'package:convert/convert.dart';

class SessionKeypair {
  final Uint8List pubKey;
  final Uint8List privKey;
  final dynamic ed25519KeyPair;

  SessionKeypair({
    required this.pubKey,
    required this.privKey,
    required this.ed25519KeyPair,
  });

  String get sessionID => hex.encode(pubKey);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SessionKeypair &&
        other.pubKey == pubKey &&
        other.privKey == privKey &&
        other.ed25519KeyPair == ed25519KeyPair;
  }

  @override
  int get hashCode =>
      pubKey.hashCode ^ privKey.hashCode ^ ed25519KeyPair.hashCode;
}
