import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:sodium/sodium.ffi.dart';

import '../session_key_pair.dart';
import '../session_client.dart';
import 'mnemonic.dart';

class SessionClientImpl implements SessionClient {
  SessionClientImpl({required this.getLibsodium});

  final DynamicLibraryFactory getLibsodium;

  @override
  Future<void> loadIdentity({required String seed}) async {
    final keypair = await _computeKeypairFromSeed(seed);
    print('Computed keypair for Session ID: ${keypair.sessionID}');
  }

  Future<SessionKeypair> _computeKeypairFromSeed(String seed) async {
    var seedHex = Mnemonic.decode(seed);

    const privKeyHexLength = 32 * 2;

    // handle shorter than 32 bytes seeds
    if (seedHex.length != privKeyHexLength) {
      seedHex = seedHex + ('0' * 32);
      seedHex = seedHex.substring(0, privKeyHexLength);
    }

    final seedUint8List = Uint8List.fromList(hex.decode(seedHex));

    final sodium = await SodiumSumoInit.init2(getLibsodium);

    final secureKey = sodium.secureCopy(seedUint8List);
    // This is correct!!!
    final ed25519KeyPair = sodium.crypto.sign.seedKeyPair(secureKey);

    final x25519PublicKey =
        sodium.crypto.sign.pkToCurve25519(ed25519KeyPair.publicKey);

    // prepend version byte (coming from `processKeys(raw_keys)`)
    final origPub = Uint8List.fromList(x25519PublicKey);
    final prependedX25519PublicKey = Uint8List(33);
    prependedX25519PublicKey.setAll(1, origPub);
    prependedX25519PublicKey[0] = 5;
    final x25519SecretKey =
        sodium.crypto.sign.skToCurve25519(ed25519KeyPair.secretKey);

    return SessionKeypair(
      pubKey: prependedX25519PublicKey,
      privKey: x25519SecretKey,
      ed25519KeyPair: ed25519KeyPair,
    );
  }
}
