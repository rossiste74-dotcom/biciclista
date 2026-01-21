# 🚴 Biciclistico

**Biciclistico** è l'applicazione compagna definitiva per i ciclisti, progettata per gestire ogni aspetto della vita su due ruote: dalla pianificazione dei percorsi alla manutenzione del garage, fino alle uscite di gruppo con la community.

> **Stato**: In Sviluppo Attivo 🚧

---

## 🌟 Funzionalità Principali

### 📊 Dashboard
Una panoramica completa delle tue attività e del tuo stato fisico.
- **Metriche**: Monitoraggio distanza settimanale, peso e HRV (Heart Rate Variability).
- **Meteo**: Integrazione per previsioni meteo sulle uscite.

### 🗺️ Percorsi (Routes Library)
Il cuore dell'esplorazione. Gestisci le tue tracce GPX e scopri nuovi sentieri.
- **I Miei Percorsi**:
  - Importazione file **GPX**.
  - Sincronizzazione **Cloud** (Supabase) automatica per non perdere mai una traccia.
  - Creazione percorsi disegnando direttamente su mappa (**Route Planner**).
  - Condivisione rapida via **QR Code**.
- **Community**:
  - Catalogo globale di percorsi condivisi da altri utenti.
  - **Pubblica** le tue tracce migliori con un click.
  - **Salva** le tracce della community nella tua libreria personale.
  - Visualizzazione dettagli: difficoltà, terreno, regione e autore ("di [Nome]").

### � Garage Digitale
Tieni traccia dell'usura delle tue biciclette e dei componenti.
- **Gestione Bici**: Aggiungi le tue bici (Strada, MTB, Gravel, ecc.).
- **Manutenzione Intelligente**: Monitoraggio chilometrico dei componenti (catena, copertoni).
- **Avvisi**: Notifiche automatiche quando un componente raggiunge il limite di usura.

### � Agenda & Social
Organizza e partecipa alle uscite.
- **Uscite di Gruppo**: Crea eventi per pedalare insieme.
- **Partecipazione**: Segna la tua presenza e vedi chi altro partecipa.

---

## �️ Tecnologie Utilizzate

Il progetto è costruito con tecnologie moderne per garantire prestazioni, offline-first experience e scalabilità.

- **Frontend**: [Flutter](https://flutter.dev) (Dart)
- **Database Locale**: [Isar](https://isar.dev) (NoSQL, ultra-veloce, offline-first)
- **Backend & Cloud**: [Supabase](https://supabase.com)
  - **PostgreSQL**: Database relazionale per dati condivisi e sync.
  - **Auth**: Gestione utenti.
  - **Storage**: Salvataggio file GPX nel cloud.
  - **Realtime**: Aggiornamenti live per le uscite di gruppo.
- **Mappe**: `flutter_map` basato su OpenStreetMap.
- **Parsers**: Gestione nativa file `.gpx`.

---

## 🚀 Installazione

Per eseguire il progetto in locale:

1.  **Prerequisiti**:
    - Flutter SDK installato (`flutter doctor` per verificare).
    - Un account Supabase configurato.

2.  **Clona la repository**:
    ```bash
    git clone https://github.com/tuo-user/biciclistico.git
    cd biciclistico
    ```

3.  **Installa le dipendenze**:
    ```bash
    flutter pub get
    ```

4.  **Generazione Codice (Isar/Json)**:
    ```bash
    dart run build_runner build --delete-conflicting-outputs
    ```

5.  **Configurazione Supabase**:
    - Assicurati che `lib/services/supabase_config.dart` contenga URL e Anonym Key del tuo progetto Supabase.
    - Esegui gli script SQL presenti nella cartella `supabase/` per creare le tabelle necessarie (`schema.sql`, `community_catalog_schema.sql`, ecc.).

6.  **Avvio**:
    ```bash
    flutter run
    ```

---

## 📂 Struttura Cartelle

- `lib/screens`: Tutte le schermate dell'app (Dashboard, Garage, Percorsi, ecc.).
- `lib/models`: Modelli dati (Track, Bicycle, GroupRide) e collezioni Isar.
- `lib/services`: Logica di business (Sync, Database, GPX, Community).
- `lib/utils`: Helper per ottimizzazione GPX, formattazione, ecc.
- `supabase`: Script SQL per la configurazione del backend.

---

Realizzato con ❤️ e tanti Watt.
