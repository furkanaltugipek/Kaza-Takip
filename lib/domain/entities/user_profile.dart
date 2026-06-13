import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String id;
  final String? displayName;
  final String? email;
  final bool isFemale;
  final String dailyMode; // easy | medium | hard
  final bool isDarkMode;
  final bool notificationsEnabled;
  final DateTime createdAt;

  const UserProfile({
    required this.id,
    this.displayName,
    this.email,
    this.isFemale = false,
    this.dailyMode = 'medium',
    this.isDarkMode = false,
    this.notificationsEnabled = true,
    required this.createdAt,
  });

  UserProfile copyWith({
    String? displayName,
    bool? isFemale,
    String? dailyMode,
    bool? isDarkMode,
    bool? notificationsEnabled,
  }) {
    return UserProfile(
      id: id,
      displayName: displayName ?? this.displayName,
      email: email,
      isFemale: isFemale ?? this.isFemale,
      dailyMode: dailyMode ?? this.dailyMode,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [id, dailyMode, isDarkMode, notificationsEnabled];
}
