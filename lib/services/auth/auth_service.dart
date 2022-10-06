import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:iscte_spots/services/logging/LoggerService.dart';


class AuthService {
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
    LoggerService.instance.debug("Stored user credentials in secure storage");
  }

  static deleteUserCredentials() async {
    const storage = FlutterSecureStorage();
    await storage.delete(key: AuthService.backendApiKeyStorageLocation);
    await storage.delete(key: AuthService.usernameStorageLocation);
    await storage.delete(key: AuthService.passwordStorageLocation);
    LoggerService.instance.debug("deleted user credentials");
  }
}
