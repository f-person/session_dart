import 'session_client_impl/session_client_impl.dart';

abstract class SessionClient {
  factory SessionClient() {
    return SessionClientImpl();
  }

  Future<void> loadIdentity({required String seed});
}
