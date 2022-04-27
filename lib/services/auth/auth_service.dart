import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';

class AuthService {
  static final Logger _logger = Logger();
  static const String backendApiKeyStorageLocation = 'backend_api_key';
  static const String usernameStorageLocation = 'username';
  static const String passwordStorageLocation = 'password';

  static storeLogInCredenials(
      {required String username,
      required String password,
      required String apiKey}) async {
    const storage = FlutterSecureStorage();
    await storage.write(key: backendApiKeyStorageLocation, value: apiKey);
    await storage.write(key: usernameStorageLocation, value: username);
    await storage.write(key: passwordStorageLocation, value: password);
    _logger.d("Stored user credentials in secure storage");
  }

  static deleteUserCredentials() async {
    const storage = FlutterSecureStorage();
    await storage.delete(key: AuthService.backendApiKeyStorageLocation);
    await storage.delete(key: AuthService.usernameStorageLocation);
    await storage.delete(key: AuthService.passwordStorageLocation);
    _logger.d("deleted user credentials");
  }
}
