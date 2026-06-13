import 'package:kaza_takip/domain/entities/streak.dart';
import 'package:kaza_takip/domain/repositories/kaza_repository.dart';

class GetStreak {
  final KazaRepository repository;
  GetStreak(this.repository);

  Future<Streak> call(String userId) => repository.getStreak(userId);
}
