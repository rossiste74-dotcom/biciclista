# Biciclistico 🚴‍♂️

**Biciclistico** è il tuo assistente digitale personale per il ciclismo. Non un semplice tracker, ma un vero **Biciclista** che si prende cura della tua esperienza in sella, dalla manutenzione della bici ai consigli sull'abbigliamento, potenziato dall'Intelligenza Artificiale.

![App Icon](assets/icon/icon.png)

## ✨ Funzionalità Principali

### 🧠 AI Coach "Biciclista" (BYOK)
Il cuore pulsante dell'app. Configura la tua chiave API personale (OpenAI, Claude o Gemini) e lascia che il Biciclista analizzi i tuoi dati:
*   **Analisi Biometrica**: Incrocia HRV, sonno e recupero per dirti quanto spingere.
*   **Consigli Meteo**: Suggerisce l'outfit perfetto in base a temperatura e vento.
*   **Analisi Percorsi**: Valuta la difficoltà di un percorso importato in relazione alla tua forma attuale.
*   **Meccanico Virtuale**: Chiedi consigli su come riparare o mantenere componenti specifici direttamente dal Garage.

### 🔧 Garage & Manutenzione Avanzata
Gestisci la tua flotta di biciclette con precisione millimetrica:
*   **Componenti Personalizzabili**: Definisci tu cosa tracciare (Catena, Copertoni, Pastiglie, Forcella, ecc.).
*   **Soglie su Misura**: Imposta i km limite per ogni componente.
*   **Tracking Automatico**: Ogni km percorso viene scalato automaticamente da tutti i componenti della bici usata.
*   **Dashboard Garage**: Visualizza lo stato di salute di ogni bici a colpo d'occhio con barre di usura colorate.

### 🗺️ Gestione Attività & Percorsi
Pianifica e analizza le tue uscite:
*   **Importazione GPX**: Carica tracce da altre app o dispositivi.
*   **Analisi Altimetrica**: Grafici interattivi di elevazione e lista delle "Salite Impegnative".
*   **Timeline Meteo**: Previsioni dettagliate punto per punto lungo il percorso (Partenza, Metà, Vetta, Arrivo).
*   **QR Sharing**: Condividi i tuoi percorsi con altri ciclisti tramite QR Code generato al volo.

### 👤 Profilo & Salute
*   **Biometria Completa**: Peso, Altezza, FTP, HRV, Sonno.
*   **Health Sync**: Sincronizzazione automatica con Apple Health / Health Connect per avere sempre dati aggiornati.
*   **Trend**: Visualizza l'andamento del tuo stato di forma nella Dashboard.

## 🚀 Per Iniziare

### Requisiti
*   Smartphone Android o iOS.
*   Chiave API (opzionale ma consigliata) per OpenAI, Anthropic o Google Gemini.

### Configurazione Iniziale
1.  **Profilo**: Inserisci i tuoi dati biometrici per calibrare i consigli.
2.  **Garage**: Aggiungi le tue bici e configura i componenti che vuoi monitorare.
3.  **AI (Opzionale)**: Vai in Impostazioni > AI Coach e inserisci la tua API Key.

## 📦 Installazione e Sviluppo

### Requisiti di Sistema
*   **Flutter SDK**: Versione 3.10.4 o superiore.
*   **Dart SDK**: Incluso in Flutter.
*   **Android Studio** (per Android) o **Xcode** (per iOS/macOS).
*   **Dispositivo Fisico**: Consigliato per testare GPS e sensori (Emulatore supportato ma limitato).

### 🏃 Esecuzione in Ambiente di Sviluppo (Agility/Locale)
Per avviare l'app nel tuo ambiente di sviluppo o IDE preferito:

1.  **Clona il Repository**:
    ```bash
    git clone https://github.com/stefanorossi/biciclista.git
    cd biciclista
    ```
2.  **Installa le Dipendenze**:
    ```bash
    flutter pub get
    ```
3.  **Avvia l'Applicazione**:
    Collega il telefono via USB (o avvia un emulatore) ed esegui:
    ```bash
    flutter run
    ```

### 📱 Generazione APK (Installazione Manuale)
Se vuoi generare un file `.apk` da inviare e installare manualmente su un dispositivo Android:

1.  **Compila la Release**:
    Esegui questo comando nel terminale del progetto:
    ```bash
    flutter build apk --release
    ```
2.  **Trova il File**:
    Al termine della compilazione, troverai il file APK in:
    `build/app/outputs/flutter-apk/app-release.apk`
3.  **Installa**:
    *   Invia il file al tuo smartphone (via email, Telegram, Drive, USB).
    *   Aprilo dal telefono e autorizza l'installazione da "Sorgenti Sconosciute" se richiesto.

### 🤖 Automazione con GitHub Actions
Questo repository include un workflow pre-configurato per compilare automaticamente l'APK nel cloud.

1.  **Carica il Codice**: Fai push delle modifiche sul branch `main`.
2.  **Monitora la Build**:
    *   Vai sulla tab **Actions** del repository GitHub.
    *   Clicca sull'ultimo workflow "Build Android APK".
3.  **Scarica l'APK**:
    *   A build terminata (icona verde ✅), scorri in basso nella sezione **Artifacts**.
    *   Clicca su `app-release` per scaricare lo zip contenente l'APK.

---

## 🛠️ Stack Tecnologico

Sviluppato con ❤️ usando **Flutter**.
*   **Database**: [Isar](https://isar.dev/) (NoSQL locale ultra-veloce).
*   **Mappe**: [Flutter Map](https://pub.dev/packages/flutter_map) & OpenStreetMap.
*   **Grafici**: [Fl Chart](https://pub.dev/packages/fl_chart).
*   **AI**: Integrazioni HTTP dirette per massima privacy (nessun server intermedio).

---
*Ride safe. Ride smart.*
