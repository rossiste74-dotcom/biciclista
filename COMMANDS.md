# Guida ai Comandi Flutter per Biciclista

## 1. Sviluppo e Debug
Per avviare l'app in modalità debug sul dispositivo collegato o emulatore:
```bash
flutter run
```

Per vedere i log dettagliati (se necessario):
```bash
flutter run -v
```

## 2. Pulizia del Progetto
Se riscontri errori strani di build, spesso è utile pulire la cache:
```bash
flutter clean
flutter pub get
```

## 3. Generazione Codice (build_runner)
Se modifichi i modelli o le icone, potresti dover rigenerare i file auto-generati (es. json_serializable, riverpod, etc.):
```bash
dart run build_runner build --delete-conflicting-outputs
```

## 4. Creazione APK Finale (Android)

### APK Singolo (Universale)
Crea un unico file APK pesante che contiene le librerie per tutte le architetture:
```bash
flutter build apk --release
```
*Il file si troverà in: `build/app/outputs/flutter-apk/app-release.apk`*

### APK Divisi per Architettura (Consigliato per installazione manuale)
Crea più APK ottimizzati per ogni tipo di processore (arm64, armeabi, x86):
```bash
flutter build apk --split-per-abi --release
```
*I file si troveranno nella stessa cartella, es: `app-arm64-v8a-release.apk`*

## 5. Creazione App Bundle (Per Google Play Store)
Se devi caricare l'app sullo store, usa questo formato (Google gestirà la creazione degli APK):
```bash
flutter build appbundle --release
```
*Il file si troverà in: `build/app/outputs/bundle/release/app-release.aab`*
