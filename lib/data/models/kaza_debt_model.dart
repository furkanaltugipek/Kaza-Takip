import 'package:hive/hive.dart';
import 'package:kaza_takip/domain/entities/kaza_debt.dart';

part 'kaza_debt_model.g.dart';

@HiveType(typeId: 0)
class KazaDebtModel extends HiveObject {
  @HiveField(0) String id;
  @HiveField(1) String userId;
  @HiveField(2) DateTime birthDate;
  @HiveField(3) DateTime pubertyDate;
  @HiveField(4) DateTime regularStartDate;
  @HiveField(5) bool isFemale;
  @HiveField(6) Map<String, int> remainingCounts;
  @HiveField(7) DateTime createdAt;
  @HiveField(8) DateTime updatedAt;

  KazaDebtModel({
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

  factory KazaDebtModel.fromEntity(KazaDebt e) => KazaDebtModel(
        id: e.id,
        userId: e.userId,
        birthDate: e.birthDate,
        pubertyDate: e.pubertyDate,
        regularStartDate: e.regularStartDate,
        isFemale: e.isFemale,
        remainingCounts: Map<String, int>.from(e.remainingCounts),
        createdAt: e.createdAt,
        updatedAt: e.updatedAt,
      );

  KazaDebt toEntity() => KazaDebt(
        id: id,
        userId: userId,
        birthDate: birthDate,
        pubertyDate: pubertyDate,
        regularStartDate: regularStartDate,
        isFemale: isFemale,
        remainingCounts: Map<String, int>.from(remainingCounts),
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  Map<String, dynamic> toFirestore() => {
        'id': id,
        'userId': userId,
        'birthDate': birthDate.toIso8601String(),
        'pubertyDate': pubertyDate.toIso8601String(),
        'regularStartDate': regularStartDate.toIso8601String(),
        'isFemale': isFemale,
        'remainingCounts': remainingCounts,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory KazaDebtModel.fromFirestore(Map<String, dynamic> map) =>
      KazaDebtModel(
        id: map['id'] as String,
        userId: map['userId'] as String,
        birthDate: DateTime.parse(map['birthDate'] as String),
        pubertyDate: DateTime.parse(map['pubertyDate'] as String),
        regularStartDate: DateTime.parse(map['regularStartDate'] as String),
        isFemale: map['isFemale'] as bool,
        remainingCounts: Map<String, int>.from(map['remainingCounts'] as Map),
        createdAt: DateTime.parse(map['createdAt'] as String),
        updatedAt: DateTime.parse(map['updatedAt'] as String),
      );
}
