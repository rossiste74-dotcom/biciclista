# Biciclista 🚴‍♂️

**Biciclista** è un'applicazione mobile completa per ciclisti, sviluppata in **Flutter**, progettata per migliorare l'esperienza di guida, gestire l'allenamento e connettere la community di appassionati.

## 🚀 Funzionalità Principali

L'applicazione offre un'ampia gamma di funzionalità divise per aree di interesse:

### 🗺️ Navigazione e Percorsi
- **Pianificazione Percorsi**: Creazione e gestione di percorsi personalizzati (`RoutePlanner`).
- **Navigazione Attiva**: Assistenza turn-by-turn durante la guida.
- **Libreria Percorsi**: Gestione e organizzazione dei percorsi salvati.
- **Importazione GPX**: Importazione facile di tracce da file GPX esterni.
- **Mappe Offline/Online**: Integrazione con `flutter_map`.

### 🤖 AI e Coaching
- **AI Coach**: Assistente virtuale per consigli su allenamento e performance.
- **Analisi Performance**: Suggerimenti basati sui dati storici dell'utente.

### 👥 Social e Community
- **Crew Management**: Creazione e gestione di gruppi (Crew).
- **Group Rides**: Organizzazione di uscite di gruppo con dettagli su percorso e partecipanti.
- **Community Explore**: Scoperta di nuovi percorsi e ciclisti nella zona.
- **Condivisione QR**: Scansione e condivisione rapida di profili e percorsi.

### 🚲 Garage e Equipaggiamento
- **Garage Virtuale**: Gestione delle proprie biciclette con dettagli specifici.
- **Manutenzione**: Tracciamento dello stato di manutenzione e promemoria.
- **Settings Abbigliamento**: Gestione del guardaroba tecnico per suggerimenti basati sul meteo.

### 📊 Dashboard e Salute
- **Integrazione Salute**: Sincronizzazione con Apple Health / Google Fit (tramite `health`).
- **Statistiche**: Visualizzazione grafica dei dati di attività (`fl_chart`).
- **Profilo Utente**: Dettagli personali, cronologia e preferenze.

---

## 🛠️ Tecnologie Utilizzate

Il progetto utilizza uno stack moderno basato su Flutter e Supabase.

### Frontend (Mobile App)
- **Framework**: [Flutter](https://flutter.dev/) (Dart SDK >=3.10.4)
- **Mappe**: `flutter_map`, `latlong2` per la gestione cartografica.
- **State & Data**: `provider` (implicito), `shared_preferences`, `flutter_secure_storage` per dati locali sicuri.
- **UI/UX**: `google_fonts`, `fl_chart` per grafici, `flutter_svg`, `cupertino_icons`.
- **Hardware Integration**:
  - `geolocator` (Posizione GPS)
  - `flutter_compass` (Bussola)
  - `mobile_scanner` / `qr_flutter` (Codici QR)
  - `vibration` (Feedback tattile)
  - `flutter_tts` (Text-to-Speech per navigazione vocale)
  - `health` (Dati biometrici)

### Backend (BaaS)
- **Piattaforma**: [Supabase](https://supabase.com/)
- **Database**: PostgreSQL (gestito tramite Supabase)
- **Auth**: Supabase Auth
- **Edge Functions**: TypeScript (nella cartella `supabase/functions/`) per logica server-side.

---

## ⚙️ Guida all'Installazione

### Prerequisiti
1.  **Flutter SDK**: Assicurati di avere Flutter installato e configurato ([Guida ufficiale](https://docs.flutter.dev/get-started/install)).
2.  **Account Supabase**: Un progetto Supabase attivo per il backend.

### Setup del Progetto

1.  **Clona il Repository**:
    ```bash
    git clone https://github.com/tuo-username/biciclista.git
    cd biciclista
    ```

2.  **Installa le Dipendenze**:
    ```bash
    flutter pub get
    ```

3.  **Configurazione Variabili d'Ambiente**:
    *   Individua il file di configurazione per le chiavi Supabase (solitamente `lib/core/constants.dart` o un file `.env` se presente).
    *   Inserisci `SUPABASE_URL` e `SUPABASE_ANON_KEY` del tuo progetto.

### Setup Backend (Supabase)

1.  **Database Schema**:
    *   Esegui gli script SQL presenti nella cartella `supabase/` nella dashboard SQL di Supabase per creare le tabelle necessarie:
        - `schema.sql` (Schema base)
        - `crew_schema.sql` (Schema per funzionalità social/crew)
        - `community_catalog_schema.sql` (Catalogo community)

2.  **Edge Functions (Opzionale/Avanzato)**:
    *   Se necessario, deploya le funzioni presenti in `supabase/functions/`:
    ```bash
    supabase functions deploy <nome-funzione>
    ```

---

## ▶️ Esecuzione

Per avviare l'applicazione in modalità debug:

```bash
flutter run
```

Seleziona il dispositivo di destinazione (Emulatore Android, Simulatore iOS o dispositivo fisico connesso).

---

## 📂 Struttura Cartelle Principali

- `lib/screens/`: Contiene tutte le schermate dell'app (es. `dashboard`, `navigation`, `profile`).
- `lib/widgets/`: Componenti UI riutilizzabili.
- `lib/models/`: Modelli dati Dart.
- `assets/`: Immagini, icone e file statici.
- `supabase/`: Script SQL e funzioni backend.
