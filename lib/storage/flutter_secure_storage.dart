import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MySecureStorage {
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  Future<void> writeEmailAndPassword(String email, String password) async {
    await _storage.write(key: 'email', value: email);
    await _storage.write(key: 'password', value: password);
  }

  Future<void> writeToken(String token) async {
    await _storage.write(key: 'token', value: token);
  }

  Future<String?> readEmail() async {
    return await _storage.read(key: 'email');
  }

  Future<String?> readPassword() async {
    return await _storage.read(key: 'password');
  }

  Future<String?> readToken() async {
    return await _storage.read(key: 'token');
  }

  Future<void> deleteEmailAndPassword() async {
    await _storage.delete(key: 'email');
    await _storage.delete(key: 'password');
  }

  Future<void> saveLocale(String locale) async {
    await _storage.write(key: 'locale', value: locale);
  }

  Future<String?> readLocale() async {
    return await _storage.read(key: 'locale');
  }

  Future<void> deleteLocale() async {
    await _storage.delete(key: 'locale');
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: 'token');
  }

  Future<void> writeQuizData(String quizId, DateTime quizEndTime) async {
    await _storage.write(key: 'quizId', value: quizId);
    await _storage.write(
        key: 'quizEndTime', value: quizEndTime.toIso8601String());
  }

  Future<String?> readQuizId() async {
    return await _storage.read(key: 'quizId');
  }

  Future<String?> readQuizEndTime() async {
    return await _storage.read(key: 'quizEndTime');
  }

  Future<void> deleteQuizData() async {
    await _storage.delete(key: 'quizId');
    await _storage.delete(key: 'quizEndTime');
  }

  Future<void> writeRole(bool role) async {
    await _storage.write(key: 'role', value: role.toString());
  }

  Future<bool?> readRole() async {
    String? roleString = await _storage.read(key: 'role');
    if (roleString == null) return null;
    return roleString.toLowerCase() == 'true';
  }

  Future<void> deleteRole() async {
    await _storage.delete(key: 'role');
  }

  Future<void> writeIsQuizCreator(int isQuizCreator) async {
    await _storage.write(key: 'isQuizCreator', value: isQuizCreator.toString());
  }

  Future<int?> readIsQuizCreator() async {
    final value = await _storage.read(key: 'isQuizCreator');
    return value != null ? int.tryParse(value) : null;
  }

  Future<void> deleteIsQuizCreator() async {
    await _storage.delete(key: 'isQuizCreator');
  }

  Future<bool?> readDoNotShowOMRTutorial() async {
    final value = await _storage.read(key: 'omr_tutorial_preference');
    return value == 'true' ? true : null;
  }

  Future<void> saveDoNotShowOMRTutorial(bool value) async {
    await _storage.write(
        key: 'omr_tutorial_preference', value: value.toString());
  }

  Future<void> deleteDoNotShowOMRTutorial() async {
    await _storage.delete(key: 'omr_tutorial_preference');
  }

  Future<void> writeFcmToken(String token) async {
    await _storage.write(key: 'fcm_token', value: token);
  }

  Future<String?> readFcmToken() async {
    return await _storage.read(key: 'fcm_token');
  }

  Future<void> deleteFcmToken() async {
    await _storage.delete(key: 'fcm_token');
  }

  Future<void> saveThemeMode(String themeMode) async {
    await _storage.write(key: 'theme_mode', value: themeMode);
  }

  Future<String?> readThemeMode() async {
    return await _storage.read(key: 'theme_mode');
  }

  Future<void> deleteThemeMode() async {
    await _storage.delete(key: 'theme_mode');
  }
}
