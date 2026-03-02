# 🚀 PROMPT DI REQUISITO — BICICLISTICO

> Questo documento descrive in modo completo e strutturato tutti i requisiti per la realizzazione dell'applicazione mobile **Biciclistico**, un ecosistema digitale dedicato ai ciclisti amatoriali e appassionati.

---

## CONTESTO DEL PROGETTO

**Nome App**: Biciclistico  
**Tipo**: Applicazione mobile nativa (iOS + Android)  
**Target**: Ciclisti amatoriali, appassionati e gruppi ciclistici  
**Obiettivo**: Fornire un ecosistema completo che combini assistenza AI personalizzata, gestione del parco bici, pianificazione percorsi con navigazione attiva, integrazione salute/biometria e una piattaforma social per organizzare uscite di gruppo.

---

## STACK TECNOLOGICO RICHIESTO

| Componente | Tecnologia | Note |
|---|---|---|
| Frontend | **Flutter 3.x** (Dart) | Codice unico per iOS e Android, Material 3 |
| Backend | **Supabase** | PostgreSQL, Auth, Storage, Realtime, Edge Functions |
| AI | **Google Gemini** | Unico motore AI (testo + visione) via Edge Function |
| Mappe | **OpenStreetMap** + `flutter_map` | Gratuito, nessuna API Key richiesta |
| Meteo | **Open-Meteo API** | Previsioni gratuite fino a 14 giorni |

---

## REQUISITI FUNZIONALI

### RF-01: Autenticazione & Onboarding
- Login/Registrazione tramite Supabase Auth (Email + Password).
- Wizard di onboarding in 3 step:
  1. **Dati fisici**: peso, altezza, età, sesso, frequenza cardiaca a riposo.
  2. **Sensibilità termica**: slider da 1 (freddo) a 5 (caldo) per personalizzare i consigli outfit.
  3. **Prima bici**: inserimento nome, tipo (Strada/MTB/Gravel), sistema cambio.

### RF-02: Dashboard Principale
- **Readiness Score**: Punteggio (0-100) calcolato su HRV e ore di sonno.
- **Card Meteo**: Temperatura, vento, precipitazioni per la posizione corrente o la prossima uscita.
- **Outfit Advisor**: L'AI "Biciclista" suggerisce l'abbigliamento tecnico ideale in base a: meteo, sensibilità termica, dislivello previsto.
- **Prossima Uscita**: Card con riepilogo del prossimo percorso pianificato.

### RF-03: Gestione Garage (Biciclette)
- CRUD biciclette con campi: nome, tipo, marca, anno, foto.
- **Componenti con usura**: Ogni bici ha componenti (catena, copertoni, pattini, cassetta, cavi) con:
  - Km attuali tracciati automaticamente.
  - Km limite configurabile dall'utente.
  - Alert automatico quando un componente supera l'80% del limite ("Attenzione") e il 100% ("Da Sostituire").
- Registro storico degli interventi di manutenzione.

### RF-04: Percorsi & Libreria GPX
- Importazione file GPX tramite `file_picker`.
- Parsing GPX per estrarre: coordinate, distanza, dislivello positivo/negativo, profilo altimetrico, tipo di superficie.
- Visualizzazione su mappa interattiva (`flutter_map` con tiles OpenStreetMap).
- Analisi AI del percorso tramite Google Gemini: difficoltà stimata, strategia consigliata, consigli specifici.
- Salvataggio nella libreria personale con possibilità di assegnare nome e tag.

### RF-05: Pianificatore di Rotte (Route Planner)
- Creazione percorsi disegnando punti sulla mappa.
- Calcolo automatico di distanza e dislivello.
- Esportazione in formato GPX.
- Salvataggio nella libreria personale.

### RF-06: Navigazione Attiva
- Mappa in tempo reale con traccia GPX sovrapposta.
- Posizione GPS aggiornata in continuo (`geolocator`).
- Freccia direzionale e bussola digitale (`flutter_compass`).
- **Avvisi vocali (TTS)**: Indicazioni audio a ogni svolta o punto critico (`flutter_tts`).
- **WakeLock**: Lo schermo resta acceso durante tutta la navigazione (`wakelock_plus`).
- Statistiche live: velocità istantanea, distanza percorsa, dislivello accumulato.

### RF-07: Social — Profilo Pubblico
- Pagina profilo con:
  - Avatar personalizzabile (elementi: casco, maglia, occhiali).
  - Bio testuale.
  - Statistiche: km totali, dislivello totale, numero di uscite.
  - "Garage Vetrina": le bici dell'utente visibili pubblicamente.
- Toggle privacy: profilo pubblico o privato.

### RF-08: Social — Amicizie
- Ricerca utenti per nome.
- Invio/Accettazione/Rifiuto richieste di amicizia.
- Lista amici con accesso al profilo pubblico.
- Aggiunta rapida tramite QR Code ("Scan to Follow").

### RF-09: Social — Crew (Uscite di Gruppo)
- Creazione evento "Ride" con:
  - Nome, descrizione, data/ora.
  - Percorso GPX allegato (opzionale).
  - Punto di ritrovo geolocalizzato su mappa.
  - Livello di difficoltà (facile/medio/difficile).
  - Numero massimo partecipanti.
  - Visibilità: pubblica o privata.
- Gestione adesioni in tempo reale (Supabase Realtime).
- Il creatore viene automaticamente aggiunto come partecipante.
- **Agenda Unificata**: Vista cronologica che combina le proprie uscite, quelle degli amici e gli eventi pubblici della zona.

### RF-10: Social — Discovery & Leaderboard
- **Discovery**: Feed di uscite pubbliche future nella propria area.
- **Leaderboard**: Classifiche per km percorsi o dislivello, settimanali/mensili, tra amici o globali.

### RF-11: AI Coach — "Il Biciclista"
- Chat interattiva con il coach AI "Il Biciclista", personalità ciclistica italiana.
- **4 Personalità selezionabili**: Amichevole, Sergente, Zen, Analitico.
- Contesto automatico inviato all'AI: profilo fisico, bici attuale, km componenti, prossima uscita pianificata, meteo.
- Limite giornaliero di 10 richieste (gestito lato client via `SharedPreferences`).
- I prompt di sistema sono salvati su Supabase (tabella `system_prompts`) e aggiornabili senza rilasciare una nuova versione dell'app.
- **Saggezza Quotidiana**: Frase motivazionale generata dall'AI e cachata per 24h.

### RF-12: Biomeccanica AI (Bike Fit)
- Caricamento di 1-3 foto dell'utente in sella (laterale obbligatoria, frontale opzionale).
- Invio immagini (base64) a Google Gemini Vision tramite Edge Function.
- L'AI restituisce un JSON strutturato con:
  - Angoli biomeccanici (ginocchio, schiena, spalle, KOPS).
  - Raccomandazioni (altezza sella, arretramento, stack manubrio).
  - Punteggio qualità immagine.
- Generazione di un "Verdetto" testuale in italiano (tono da meccanico esperto).
- Salvataggio report nella tabella `biomechanics_analysis`.

### RF-13: Salute & Biometria
- Registrazione manuale: peso, HRV, sonno, RHR, FTP.
- **Sync Health**: Importazione attività e dati da Apple Health / Google Health Connect (`health` plugin).
- Grafici trend (7/30 giorni) per peso e HRV con `fl_chart`.
- **Readiness Score**: Calcolato automaticamente da HRV e sonno.

### RF-14: QR Code
- Generazione QR per condividere: profilo utente, evento Ride.
- Scanner integrato (`mobile_scanner`) per seguire un utente o unirsi a un'uscita di gruppo.

### RF-15: Notifiche
- Notifiche locali (`flutter_local_notifications`) per:
  - Manutenzione componenti in scadenza.
  - Uscite di gruppo imminenti.
  - Condizioni meteo avverse per uscite pianificate.

### RF-16: Localizzazione
- Supporto multilingua IT/EN tramite `easy_localization`.
- Stringhe di traduzione caricate da Supabase.

---

## REQUISITI NON FUNZIONALI

| Codice | Requisito | Dettaglio |
|---|---|---|
| RNF-01 | **Persistenza** | Tutti i dati su Supabase (cloud-only). No database locale obbligatorio. |
| RNF-02 | **Sicurezza** | RLS (Row Level Security) su tutte le tabelle Supabase. Token JWT per autenticazione. |
| RNF-03 | **Performance** | UI Flutter a 60fps. Lazy loading per liste lunghe. |
| RNF-04 | **Scalabilità** | Supabase Free Tier per MVP, upgrade a Pro per produzione. |
| RNF-05 | **Privacy** | Profili privati di default. Dati salute mai condivisi pubblicamente. |
| RNF-06 | **Offline** | Funzionalità limitate offline (navigazione con cache tiles). Sync al ritorno online. |

---

## TABELLE DATABASE (Supabase PostgreSQL)

| Tabella | Descrizione |
|---|---|
| `public_profiles` | Profilo pubblico utente (nome, bio, avatar, stats, privacy) |
| `bicycles` | Biciclette con componenti e chilometraggio |
| `planned_rides` | Uscite pianificate con meteo e link a traccia |
| `tracks` | Libreria percorsi GPX importati |
| `group_rides` | Uscite di gruppo (Crew) |
| `group_ride_participants` | Adesioni alle uscite di gruppo |
| `friendships` | Relazioni di amicizia tra utenti |
| `system_prompts` | Prompt AI aggiornabili da remoto |
| `ai_logs` | Log delle richieste AI (tracking utilizzo) |
| `biomechanics_analysis` | Report analisi biomeccanica |
| `daily_wisdom` | Frasi motivazionali giornaliere |

---

## ARCHITETTURA

```
┌─────────────────────────────────────────────────┐
│             APP FLUTTER (Client)                │
│  Dashboard │ Crew │ Routes │ Garage │ AI Coach  │
└──────────────────────┬──────────────────────────┘
                       │ HTTPS / WebSocket
┌──────────────────────▼──────────────────────────┐
│                   SUPABASE                      │
│  PostgreSQL │ Auth │ Storage │ Realtime          │
│              Edge Functions                     │
└──────────────────────┬──────────────────────────┘
                       │ API
          ┌────────────┴────────────┐
          │                        │
┌─────────▼──────────┐  ┌──────────▼──────────┐
│   Google Gemini    │  │   Open-Meteo API    │
│  (AI Coach/Vision) │  │  (Meteo Previsioni) │
└────────────────────┘  └─────────────────────┘
```

---

## 📌 NOTA FINALE

> **Questo documento costituisce la base per un piano dettagliato di specifiche tecniche e funzionali da redigere su DocMind all'interno del progetto Biciclistico.** Ogni requisito funzionale (RF-xx) e non funzionale (RNF-xx) dovrà essere espanso in user stories, criteri di accettazione e task di implementazione nel piano DocMind dedicato.
