import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:iscte_spots/services/logging/LoggerService.dart';


class LoginStorageService {
  static const String backendApiKeyStorageLocation = 'backend_api_key';
  static const String usernameStorageLocation = 'username';
  static const String passwordStorageLocation = 'password';

  static storeLogInCredenials(
      {required String username,
      required String password,
      required String apiKey}) async {
    const secureStorage = FlutterSecureStorage();
    await secureStorage.write(key: backendApiKeyStorageLocation, value: apiKey);
    await secureStorage.write(key: usernameStorageLocation, value: username);
    await secureStorage.write(key: passwordStorageLocation, value: password);
    LoggerService.instance.debug("Stored user credentials in secure storage");
  }

  static deleteUserCredentials() async {
    const storage = FlutterSecureStorage();
    await storage.delete(key: LoginStorageService.backendApiKeyStorageLocation);
    await storage.delete(key: LoginStorageService.usernameStorageLocation);
    await storage.delete(key: LoginStorageService.passwordStorageLocation);
    LoggerService.instance.debug("deleted user credentials");
  }
}

class IscteLoginStorageService{
  static const String backendApiKeyStorageLocation = 'backend_api_key';
  static const String refreshTokenStorageLocation = 'refresh_token';

  static storeFenixLogInCredenials(
      {required String? refreshToken,
        required String? apiToken}) async {
    const secureStorage = FlutterSecureStorage();
    await secureStorage.write(key: backendApiKeyStorageLocation, value: apiToken);
    await secureStorage.write(key: refreshTokenStorageLocation, value: refreshToken);
    LoggerService.instance.debug("Stored Fenix user credentials in secure storage");
  }

  static deleteUserCredentials() async {
    const storage = FlutterSecureStorage();
    await storage.delete(key: backendApiKeyStorageLocation);
    await storage.delete(key: refreshTokenStorageLocation);
    LoggerService.instance.debug("Deleted Fenix user credentials");
  }
}
