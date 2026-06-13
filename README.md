# Kaza Takip — İbadet Planlayıcısı

**%100 Ücretsiz, Reklamsız** Kaza Namazı Takip Uygulaması.

## Mimari

```
lib/
├── core/           # Sabitler, tema, hesaplama formülleri, DI
├── domain/         # Entity, UseCase, Repository arayüzleri (saf Dart)
├── data/           # Hive modelleri, Firestore datasource, impl
└── presentation/   # BLoC, sayfalar, widget'lar
```

## Kurulum

### 1. Firebase kurulumu
```bash
flutter pub global activate flutterfire_cli
flutterfire configure --project=YOUR_FIREBASE_PROJECT_ID
```

### 2. Paket kurulumu
```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### 3. Çalıştırma
```bash
flutter run
```

## Firebase Ücretsiz Katman Optimizasyonu

Firestore yazmaları **yerel önbellekte** toplanır. Her **10 değişiklikten** sonra veya uygulama arka plana geçtiğinde toplu olarak senkronize edilir (`syncToRemote()`). Bu sayede günlük Firestore yazma kotası minimum düzeyde tutulur.

## Modüller

| Modül | Durum |
|-------|-------|
| Kaza Borcu Hesaplama Sihirbazı | ✅ |
| Günlük Plan (Kolay/Orta/Yoğun) | ✅ |
| Simülatör Kaydırıcısı | ✅ |
| Seri & Rozet Sistemi | ✅ |
| Oruç Takibi | 🔜 |
| Hatim Takibi | 🔜 |
| Zikirmatik | 🔜 |
| Sadaka Hedefleri | 🔜 |
| Katkı Takvimi (GitHub stili) | 🔜 |
