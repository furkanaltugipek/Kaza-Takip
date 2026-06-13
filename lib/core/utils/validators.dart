class AppValidators {
  AppValidators._();

  static String? birthDate(DateTime? value) {
    if (value == null) return 'Doğum tarihi gerekli';
    if (value.isAfter(DateTime.now())) return 'Doğum tarihi gelecekte olamaz';
    return null;
  }

  static String? pubertyDate(DateTime? value, DateTime? birthDate) {
    if (value == null) return 'Ergenlik tarihi gerekli';
    if (birthDate != null && !value.isAfter(birthDate)) {
      return 'Ergenlik tarihi doğum tarihinden sonra olmalı';
    }
    if (value.isAfter(DateTime.now())) return 'Ergenlik tarihi gelecekte olamaz';
    return null;
  }

  static String? regularStartDate(DateTime? value, DateTime? pubertyDate) {
    if (value == null) return 'Düzenli namaz tarihi gerekli';
    if (pubertyDate != null && value.isBefore(pubertyDate)) {
      return 'Bu tarih ergenlik tarihinden önce olamaz';
    }
    return null;
  }

  static String? dailyTarget(int? value) {
    if (value == null || value <= 0) return 'Günlük hedef 0\'dan büyük olmalı';
    if (value > 100) return 'Günlük hedef 100\'den küçük olmalı';
    return null;
  }
}
