📄 PROGETTO: RIDE CREW - SPECIFICHE DI SVILUPPO (AGGIORNATO)
1. VISIONE E STACK TECNOLOGICO
	•	Obiettivo: Ecosistema ciclistico completo con funzionalità Social (Crew), Coaching AI avanzato e Biomeccanica.
	•	Architettura: Cloud-First (Supabase).
	•	Framework: Flutter (Dart).
	•	Backend & Database: Supabase (PostgreSQL, Auth, Realtime, Edge Functions, Storage).
	•	API Esterne: Open-Meteo (Meteo), OpenRouter/DeepSeek/Gemini (AI via Edge Functions).
	•	Costi: Scalabile (Free Tier Supabase inizialmente sufficiente).

2. MODELLI AI & STRUMENTI
	1.	Butler AI (DeepSeek/Claude/Gemini): Gestito via Supabase Edge Function ('butler-ai-openrouter'). Fornisce consigli pre-ride, analisi tracce e "Saggezza Quotidiana".
	2.	AI Vision (Gemini Pro Vision): Per l'analisi biomeccanica tramite foto (caricate su Supabase Storage).
	3.	Generazione UI: GPT-4o / Claude 3.5 Sonnet per codice Flutter.

3. SEQUENZA DI SVILUPPO (PROMPTS AGGIORNATI)

FASE 1: Setup Progetto e Backend (Cloud-Only)
Prompt da usare:
"Configura un progetto Flutter 'Ride Crew' connesso a Supabase.
1. Inizializza Supabase Flutter.
2. Crea le tabelle SQL su Supabase: 
   - `public_profiles`: dati utente, statistiche, preferenze (incluso 'coach_personality').
   - `bicycles`: dettagli tecnici e componenti con chilometraggio.
   - `planned_rides`: uscite pianificate con meteo e partecipanti.
   - `group_rides`: uscite di gruppo (Crew) con chat e adesioni.
   - `friendships`: gestione amicizie.
Use RLS (Row Level Security) per proteggere i dati."

FASE 2: Logica Core & AI Butler
Prompt da usare:
"Implementa il `AIService` che comunica con la Edge Function 'butler-ai-openrouter'.
La funzione deve accettare il contesto dell'utente (Peso, HRV, Bici) e restituire:
1. Analisi Pre-Ride: Consigli su outfit e strategia basati su Meteo e Traccia.
2. Analisi Traccia: Descrizione tecnica del percorso.
3. Saggezza Quotidiana: Frasi motivazionali per la community.
Implementa anche la gestione dei token/limiti giornalieri lato client."

FASE 3: Social & Crew (Nuovo Core)
Prompt da usare:
"Sviluppa il modulo Social:
1. `SocialService`: Gestione `public_profiles` (ricerca, visualizzazione stats).
2. `FriendshipService`: Invia/Accetta richieste di amicizia.
3. `CrewService`: 
   - Crea `GroupRide` (pubbliche o private).
   - Gestisci adesioni (`group_ride_participants`).
   - Visualizza 'Agenda Unificata' (le mie uscite + uscite degli amici + eventi pubblici).
Usa Supabase Realtime per aggiornare le adesioni in tempo reale."

FASE 4: Importazione GPX, Mappe e Navigazione
Prompt da usare:
"Implementa la gestione mappe con `flutter_map` (OpenStreetMap).
Funzionalità richieste:
1. Import GPX: Parsing dettagliato (pendenza, superficie).
2. Navigazione: Tracciamento posizione in tempo reale, avvisi audio (TTS) per svolte o POI.
3. Safety: WakeLock attivo durante la ride, condivisione posizione in tempo reale (facoltativo)."

FASE 5: Analisi Biomeccanica (AI Vision)
Prompt da usare:
"Crea la funzionalità 'Bike Fit AI':
1. L'utente carica 1-3 foto in sella (Laterale, Frontale).
2. Le immagini vengono inviate alla Edge Function 'butler-ai-openrouter' (Vision Mode).
3. L'AI analizza gli angoli (ginocchio, schiena, spalle) e restituisce un JSON con le metriche e un 'Verdetto' testuale (stile meccanico esperto).
4. Salva il report nella tabella `biomechanics_analysis`."

FASE 6: Extra e Rifiniture
Prompt da usare:
"Aggiungi funzionalità accessorie:
1. QR Code: Genera QR per condividere profili o eventi. Scanner per unirsi rapidamente.
2. Localizzazione: Supporto multilingua (IT/EN) con `easy_localization` caricato da Supabase.
3. Onboarding: Wizard iniziale per configurare Profilo Fisico e Bici."

4. LOGICA ALGORITMICA DI RIFERIMENTO (AI COMPLESSA)
Non più if/else hardcoded per l'outfit, ma un prompt di sistema per il Butler che riceve:
- Dati Meteo (Temp, Vento, Precipitazioni).
- Dati Utente (Sensibilità termica, HRV).
- Dati Percorso (Dislivello, Durata).
L'AI decide l'outfit ottimale e lo spiega con la personalità scelta (Sergente, Zen, Analitico).

Istruzioni per l'utente:
Usa questi prompt sequenziali con il tuo Coding Assistant. Verifica sempre che le tabelle Supabase esistano prima di scrivere il codice Flutter corrispondente.
