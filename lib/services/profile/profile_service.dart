import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:iscte_spots/helper/constants.dart';
import 'package:iscte_spots/services/auth/auth_storage_service.dart';
import 'package:iscte_spots/services/logging/LoggerService.dart';

class ProfileService {
  static final ProfileService _instance = ProfileService._internal();
  factory ProfileService() {
    return _instance;
  }
  ProfileService._internal() {
    // initialization logic
  }

  Map? storedProfile;

  Future<Map> fetchProfile() async {
    try {
      const FlutterSecureStorage secureStorage = FlutterSecureStorage();

      HttpClient client = HttpClient();
      client.badCertificateCallback =
          ((X509Certificate cert, String host, int port) => true);
      final request = await client.getUrl(
          Uri.parse('${BackEndConstants.API_ADDRESS}/api/users/profile'));
      String? apiToken = await secureStorage.read(key: LoginStorageService.backendApiKeyStorageLocation);

      request.headers.add("Authorization", "Token $apiToken");

      final response = await request.close();

      if (response.statusCode == 200) {
        var userProfile =
            jsonDecode(await response.transform(utf8.decoder).join());
        storedProfile = userProfile;
        return userProfile;
      }
    } catch (e) {
      LoggerService.instance.error(e);
    }
    throw Exception("Failed to load profile");
  }
}
