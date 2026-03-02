# 📘 RIDE CREW - ANALISI TECNICA & FUNZIONALITÀ

## 1. STACK TECNOLOGICO

### **Frontend Mobile**
*   **Linguaggio**: Dart 3.x
*   **Framework**: Flutter 3.x (Material 3 UI)
*   **Architettura**: MVVM-based (Service-Repository Pattern)
*   **State Management**: `flutter_riverpod` (o Provider/StatefulWidget misti, basato sui file analizzati)

### **Backend & Cloud (BaaS)**
*   **Piattaforma**: **Supabase** (Cloud-only)
*   **Database**: PostgreSQL (Relazionale) con estensioni PostGIS (per dati geospaziali).
*   **Auth**: Supabase Auth (Email/Password + Social Login potential).
*   **Storage**: Supabase Storage (per Avatar, Foto Biomeccanica, file GPX).
*   **Edge Functions**: Deno/TypeScript (per logica AI e Proxy verso LLM).
*   **Realtime**: Supabase Realtime (per aggiornamenti live su Crew/Chat/Posizione).

### **Artificial Intelligence (AI)**
*   **Orchestrazione**: Edge Function `butler-ai-openrouter` (che funge da gateway).
*   **Provider LLM**: **Google Gemini** (via Vertex AI / Google AI Studio). Utilizzato come unico motore di intelligenza per il Butler, l'analisi dei percorsi e la generazione di contenuti.
*   **Vision AI**: **Google Gemini Pro Vision** per l'analisi biomeccanica.

---

## 2. FRAMEWORK E LIBRERIE CHIAVE

### **Core & Utility**
*   `supabase_flutter`: SDK ufficiale per connessione al backend.
*   `http`: Chiamate API REST (es. Open-Meteo).
*   `shared_preferences`: Persistenza locale leggera (flag, cache semplice).
*   `intl` / `easy_localization`: Internazionalizzazione e formattazione date.
*   `file_picker` / `image_picker`: Selezione file GPX e foto.

### **Mappe & Navigazione**
*   `flutter_map`: Rendering mappe OpenStreetMap (raster tiles).
*   `latlong2`: Gestione coordinate geografiche.
*   `geolocator`: Accesso al GPS del dispositivo.
*   `flutter_compass`: Bussola digitale.
*   `gpx`: Parsing e manipolazione file GPX.

### **Grafica & UI**
*   `fl_chart`: Grafici interattivi (LineChart per altimetria/HRV, BarChart).
*   `flutter_svg`: Rendering icone vettoriali.
*   `google_fonts`: Tipografia personalizzata.

### **Funzionalità Specifiche**
*   `health`: Sincronizzazione con Apple Health / Google Health Connect.
*   `qr_flutter` / `mobile_scanner`: Generazione e scansione codici QR.
*   `flutter_tts`: Sintesi vocale (Text-to-Speech) per navigazione e avvisi.
*   `wakelock_plus`: Mantiene lo schermo attivo durante la navigazione.

---

## 3. DESCRIZIONE DETTAGLIATA DELLE FUNZIONALITÀ

### **🚲 1. Gestione Garage (My Garage)**
*   **Lista Bici**: Creazione e gestione schede biciclette (Strada, MTB, Gravel, ecc.).
*   **Componenti & Usura**: Tracciamento km per ogni componente (catena, copertoni, pattini).
*   **Manutenzione**: Avvisi automatici ("Service Due") basati sul chilometraggio.

### **🌦️ 2. Dashboard & Smart Advice (Butler AI)**
*   **Home Dashboard**: Panoramica con 'Readiness Score' (recupero fisico), Meteo attuale e Prossima Uscita.
*   **Outfit Advisor**: L'AI analizza meteo, sensibilità termica utente e dislivello per consigliare l'abbigliamento tecnico esatto (es. "Porta la mantellina, discesa fredda").
*   **Saggezza Quotidiana**: Frasi motivazionali generate dall'AI per la community.

### **🗺️ 3. Percorsi & Navigazione (Routes)**
*   **Libreria Percorsi**: Importazione file GPX, visualizzazione dettagli (distanza, dislivello, superficie).
*   **Pianificazione (Route Planner)**: Creazione manuale o modifica percorsi.
*   **Navigazione Attiva**:
    *   Mappa interattiva con traccia da seguire.
    *   **Freccia direzionale** e bussola.
    *   **Avvisi Vocali (TTS)** per svolte o punti di interesse.
    *   **Modalità Safety**: WakeLock attivo, eventuale condivisione posizione.

### **👥 4. Area Social & Crew**
*   **Profili Pubblici**: Pagina utente con statistiche (Km totali, Dislivello), Avatar personalizzabile e "Garage Vetrina".
*   **Amicizie**: Sistema di Follow/Friendship con notifiche.
*   **Crew (Uscite di Gruppo)**:
    *   Creazione eventi "Ride" con data, ora, percorso e punto di ritrovo.
    *   Gestione adesioni ("Parteciperò").
    *   Chat/Bacheca evento (in roadmap).
*   **Discovery**: Esplorazione uscite pubbliche nella zona.
*   **Leaderboard**: Classifiche basate su km o dislivello (tra amici o globali).

### **🧘 5. Biomeccanica AI (Bike Fit)**
*   **Analisi Vision**: Caricamento foto in sella (laterale/frontale).
*   **Processing AI**: L'AI vision identifica i punti articolari (anche, ginocchia, caviglie).
*   **Report**: Calcolo angoli biomeccanici e generazione di un "Verdetto" con consigli di regolazione (es. "Alza la sella di 5mm").

### **📊 6. Salute & Training**
*   **Biometria**: Registrazione peso, RHR (Hearth Rate a riposo), FTP.
*   **Sync Cloud/Health**: Importazione attività da wearables (Garmin/Apple Watch via Health Connect).
*   **Grafici**: Trend andamento peso, HRV e sleep quality per calcolare il Readiness.

### **⚙️ 7. Utility & Impostazioni**
*   **QR Code**: "Scan to Follow" per aggiungere amici velocemente o unirsi a una Ride.
*   **Impostazioni Meteo**: Soglie di temperatura personalizzate per i consigli outfit.
*   **Backup Cloud**: Tutti i dati sono sincronizzati su Supabase, nessun rischio di perdita dati locale.

---

## 4. ARCHITETTURA DI FLUSSO (RIEPILOGO)

1.  **Auth**: Utente si logga -> Token JWT Supabase.
2.  **Data Fetch**: App richiede dati (es. `getUpcomindRides()`) -> Supabase Client -> PostgreSQL (con RLS).
3.  **AI Request**: App chiama `AIService` -> Edge Function `butler-ai` -> OpenRouter -> Risposta JSON -> App UI.
4.  **Realtime**: App sottoscrive canale `group_rides` -> Supabase invia push socket su cambiamenti (nuovi partecipanti).
