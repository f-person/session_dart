import 'package:sodium/sodium.ffi.dart';

import 'session_client_impl/session_client_impl.dart';

abstract class SessionClient {
  factory SessionClient({required DynamicLibraryFactory getLibsodium}) {
    return SessionClientImpl(getLibsodium: getLibsodium);
  }

  Future<void> loadIdentity({required String seed});
}
