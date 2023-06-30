import 'package:session_dart/session_dart.dart';

Future<void> main() async {
  final seed = String.fromEnvironment('SESSION_SEED');
  if (seed.isNotEmpty) {
    await SessionClient().loadIdentity(seed: seed);
  }
}
