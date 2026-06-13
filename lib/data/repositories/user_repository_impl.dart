import 'package:kaza_takip/data/datasources/local/hive_datasource.dart';
import 'package:kaza_takip/data/datasources/remote/firestore_datasource.dart';
import 'package:kaza_takip/data/models/user_profile_model.dart';
import 'package:kaza_takip/domain/entities/user_profile.dart';
import 'package:kaza_takip/domain/repositories/user_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class UserRepositoryImpl implements UserRepository {
  final HiveLocalDataSource local;
  final FirestoreDataSource remote;
  final SharedPreferences prefs;

  static const String _userIdKey = 'anonymous_user_id';

  UserRepositoryImpl({
    required this.local,
    required this.remote,
    required this.prefs,
  });

  @override
  Future<String> getOrCreateAnonymousUserId() async {
    final existing = prefs.getString(_userIdKey);
    if (existing != null) return existing;
    final id = const Uuid().v4();
    await prefs.setString(_userIdKey, id);
    return id;
  }

  @override
  Future<UserProfile?> getUserProfile(String userId) async {
    final model = local.getUserProfile(userId);
    return model?.toEntity();
  }

  @override
  Future<void> saveUserProfile(UserProfile profile) async {
    final model = UserProfileModel.fromEntity(profile);
    await local.saveUserProfile(model);
    await remote.syncUserProfile(model.toFirestore(), profile.id);
  }
}
