import 'package:hive/hive.dart';
import 'package:kaza_takip/domain/entities/user_profile.dart';

part 'user_profile_model.g.dart';

@HiveType(typeId: 3)
class UserProfileModel extends HiveObject {
  @HiveField(0) String id;
  @HiveField(1) String? displayName;
  @HiveField(2) String? email;
  @HiveField(3) bool isFemale;
  @HiveField(4) String dailyMode;
  @HiveField(5) bool isDarkMode;
  @HiveField(6) bool notificationsEnabled;
  @HiveField(7) DateTime createdAt;

  UserProfileModel({
    required this.id,
    this.displayName,
    this.email,
    required this.isFemale,
    required this.dailyMode,
    required this.isDarkMode,
    required this.notificationsEnabled,
    required this.createdAt,
  });

  factory UserProfileModel.fromEntity(UserProfile e) => UserProfileModel(
        id: e.id,
        displayName: e.displayName,
        email: e.email,
        isFemale: e.isFemale,
        dailyMode: e.dailyMode,
        isDarkMode: e.isDarkMode,
        notificationsEnabled: e.notificationsEnabled,
        createdAt: e.createdAt,
      );

  UserProfile toEntity() => UserProfile(
        id: id,
        displayName: displayName,
        email: email,
        isFemale: isFemale,
        dailyMode: dailyMode,
        isDarkMode: isDarkMode,
        notificationsEnabled: notificationsEnabled,
        createdAt: createdAt,
      );

  Map<String, dynamic> toFirestore() => {
        'id': id,
        'displayName': displayName,
        'email': email,
        'isFemale': isFemale,
        'dailyMode': dailyMode,
        'isDarkMode': isDarkMode,
        'notificationsEnabled': notificationsEnabled,
        'createdAt': createdAt.toIso8601String(),
      };
}
