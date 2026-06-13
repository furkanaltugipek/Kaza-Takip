import 'package:equatable/equatable.dart';

class KazaDebt extends Equatable {
  final String id;
  final String userId;
  final DateTime birthDate;
  final DateTime pubertyDate;
  final DateTime regularStartDate;
  final bool isFemale;

  // Per-prayer remaining counts (decremented as user completes kaza)
  final Map<String, int> remainingCounts;

  // Computed totals (derived, not stored separately)
  int get totalRemaining => remainingCounts.values.fold(0, (a, b) => a + b);

  final DateTime createdAt;
  final DateTime updatedAt;

  const KazaDebt({
    required this.id,
    required this.userId,
    required this.birthDate,
    required this.pubertyDate,
    required this.regularStartDate,
    required this.isFemale,
    required this.remainingCounts,
    required this.createdAt,
    required this.updatedAt,
  });

  KazaDebt copyWith({
    Map<String, int>? remainingCounts,
    DateTime? updatedAt,
  }) {
    return KazaDebt(
      id: id,
      userId: userId,
      birthDate: birthDate,
      pubertyDate: pubertyDate,
      regularStartDate: regularStartDate,
      isFemale: isFemale,
      remainingCounts: remainingCounts ?? this.remainingCounts,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        remainingCounts,
        updatedAt,
      ];
}
