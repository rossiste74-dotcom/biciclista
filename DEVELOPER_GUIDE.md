# 🗺️ Guida Operativa per Sviluppatori

Questo documento serve come bussola per orientarsi nel codice sorgente di **Biciclista**. Qui troverai indicazioni precise su dove sono implementate le funzionalità chiave, come modificare le regole dell'AI e come gestire il database, con collegamenti diretti ai file.

---

## 📍 Mappa delle Funzionalità

| Area Funzionale | Descrizione | File Sorgente Principali |
| :--- | :--- | :--- |
| **AI & Coach** | Logica del "Biciclista", prompt e personalità. | [`lib/services/ai_service.dart`](./lib/services/ai_service.dart) |
| **Database** | CRUD, query Supabase e gestione utenti. | [`lib/services/database_service.dart`](./lib/services/database_service.dart) |
| **Navigazione** | Calcolo percorsi, routing graphhopper. | [`lib/services/route_planning_service.dart`](./lib/services/route_planning_service.dart) |
| **GPX** | Parsing e gestione file traccia. | [`lib/services/gpx_service.dart`](./lib/services/gpx_service.dart) |
| **Social / Crew** | Gestione gruppi, uscite condivise. | [`lib/services/crew_service.dart`](./lib/services/crew_service.dart) |
| **Meteo** | integrazione previsioni. | [`lib/services/weather_service.dart`](./lib/services/weather_service.dart) |
| **Salute** | Integrazione HealthKit/Google Fit. | [`lib/services/health_sync_service.dart`](./lib/services/health_sync_service.dart) |

---

## 🧠 Intelligenza Artificiale (AI Coach)

Il cuore dell'AI risiede nella classe `AIService`.

### 1. Dove modificare i Prompt e le "Personalità"
Se vuoi cambiare il modo in cui il Coach risponde (es. renderlo più aggressivo o più zen), devi modificare i metodi all'interno di **[`lib/services/ai_service.dart`](./lib/services/ai_service.dart)**:

*   **Prompt di Sistema Base**: Metodo `_buildSystemPrompt`. Qui vengono iniettati i dati dell'utente (peso, HRV, bici) nel contesto dell'AI.
*   **Personalità (Sergente, Zen, ecc.)**: Cerca lo `switch (personality)` all'interno di `analyzeRide` e `analyzeTrack`.
    *   *Esempio*: Per modificare il "Sergente", edita la stringa nella case `'sergeant'`.
    *   *Codice*:
        ```dart
        case 'sergeant':
          systemPrompt = "Sei un SERGENTE ISTRUTTORE... [modifica qui]";
          break;
        ```

### 2. Backend AI
L'applicazione non chiama direttamente le API LLM (OpenAI/Anthropic) dal client, ma passa attraverso una **Edge Function** di Supabase per sicurezza.
*   **Funzione Cloud**: [`supabase/functions/butler-ai-openrouter/index.ts`](./supabase/functions/butler-ai-openrouter/index.ts)
*   **Chiamata Client**: `_callAI` in [`ai_service.dart`](./lib/services/ai_service.dart) invoca `_functions.invoke('butler-ai-openrouter', ...)`

---

## 🗄️ Database & Backend (Supabase)

L'interazione con il database è centralizzata.

### 1. Database Service
Tutte le operazioni CRUD passano per **[`lib/services/database_service.dart`](./lib/services/database_service.dart)**.
*   Questo servizio agisce come un Singleton.
*   Esempio: Per aggiungere una query sui "Biciclette", modifica `getAllBicycles()` o aggiungi un metodo simile in questo file.
*   **Nota**: Non ci sono query SQL sparse nelle schermate UI; usa sempre questo servizio.

### 2. Configurazione
Le chiavi API e l'URL del progetto sono definiti in:
*   **[`lib/services/supabase_config.dart`](./lib/services/supabase_config.dart)**
*   *Attenzione*: Assicurati di non committare chiavi prodotte reali se il repo è pubblico (usa variabili d'ambiente in CI/CD).

### 3. Schema Dati (SQL)
Se devi modificare la struttura delle tabelle:
*   Controlla i file `.sql` nella cartella [`/supabase`](./supabase/) (es. `schema.sql`, `crew_schema.sql`).
*   Questi file rappresentano la "source of truth" per la struttura del DB.

---

## 🗺️ Navigazione e Mappe

### 1. Pianificazione (Routing)
La logica per calcolare il percorso tra due punti si trova in:
*   **[`lib/services/route_planning_service.dart`](./lib/services/route_planning_service.dart)**
*   Utilizza servizi esterni (come GraphHopper o OSRM, a seconda della configurazione) per ottenere i punti GPS.

### 2. Visualizzazione Mappa
Le schermate che mostrano la mappa usano `flutter_map`.
*   **Active Navigation**: [`lib/screens/active_navigation_screen.dart`](./lib/screens/active_navigation_screen.dart) (Schermata durante la guida).
*   **Route Planner**: [`lib/screens/route_planner_screen.dart`](./lib/screens/route_planner_screen.dart) (Schermata di creazione percorso).

---

## 🧩 Struttura del Progetto

*   **[`lib/models/`](./lib/models/)**: Contiene le classi dati (DTO). Se aggiungi una colonna al DB, aggiungi il campo qui (es. in [`user_profile.dart`](./lib/models/user_profile.dart)).
*   **[`lib/screens/`](./lib/screens/)**: Contiene solo la logica UI. Le chiamate ai dati dovrebbero essere delegate ai *Services*.
*   **[`lib/widgets/`](./lib/widgets/)**: Componenti riutilizzabili (es. grafici, card attività).

---

## 🛠️ Come aggiungere una nuova funzionalità

1.  **Definisci il Modello**: Crea/Aggiorna il file in [`lib/models/`](./lib/models/).
2.  **Aggiorna il DB**: Modifica [`database_service.dart`](./lib/services/database_service.dart) per gestire lettura/scrittura a Supabase.
3.  **Crea il Servizio (Opzionale)**: Se c'è logica complessa (es. calcoli), crea un servizio dedicato in [`lib/services/`](./lib/services/).
4.  **UI**: Implementa la schermata in [`lib/screens/`](./lib/screens/) usando i servizi creati.
