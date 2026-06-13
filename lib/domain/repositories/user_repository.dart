import 'package:kaza_takip/domain/entities/user_profile.dart';

abstract class UserRepository {
  Future<UserProfile?> getUserProfile(String userId);
  Future<void> saveUserProfile(UserProfile profile);
  Future<String> getOrCreateAnonymousUserId();
}
