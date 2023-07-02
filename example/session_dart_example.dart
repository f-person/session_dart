import 'dart:ffi';

import 'package:session_dart/session_dart.dart';

Future<void> main() async {
  final seed = String.fromEnvironment('SESSION_SEED');
  if (seed.isEmpty) {
    print('No seed provided. Please set SESSION_SEED environment variable.');
    return;
  }

  final client = SessionClient(
    getLibsodium: () => DynamicLibrary.open(
      '/opt/homebrew/Cellar/libsodium/1.0.18_1/lib/libsodium.dylib',
    ),
  );
  await client.loadIdentity(seed: seed);
}
