
📄 PROGETTO: RIDE CREW - SPECIFICHE DI SVILUPPO
1. VISIONE E STACK TECNOLOGICO
	•	Obiettivo: Assistente logistico per ciclisti amatoriali (Meteo, Outfit, Biometria, Manutenzione).
	•	Architettura: Local-First (nessun backend obbligatorio).
	•	Framework: Flutter (Dart).
	•	Database: Isar (Embedded, locale).
	•	API Esterne: Open-Meteo (Gratuita).
	•	Costi: 0€ (Solo risorse gratuite e locali).

2. MODELLI AI CONSIGLIATI PER L'ESECUZIONE
	1.	Claude 4.5 Opus / 3.5 Sonnet: Per l'architettura iniziale, la logica del database Isar e l'algoritmo di calcolo vestiario.
	2.	GPT-4o: Per la creazione della UI (Widget, Dashboard, Grafici con fl_chart).
	3.	Gemini 1.5 Pro: Per il debug globale e l'analisi dei file GPX complessi.

3. SEQUENZA DI SVILUPPO (PROMPTS)
FASE 1: Setup Progetto e Database
Prompt da usare:
"Configura un nuovo progetto Flutter 'Ride Crew. Aggiorna pubspec.yaml con: isar, isar_flutter_libs, path_provider, gpx, file_picker, fl_chart, health, google_fonts, e isar_generator, build_runner(dev_dependencies). Crea i modelli Isar:
	•	UserProfile: biometria (età, peso, RHR, FTP) e sensibilità termica (1-5).
	•	Bicycle: nome, tipo, sistema cambio, ultima manutenzione.
	•	PlannedRide: data, percorso GPX, meteo previsto.
	•	HealthSnapshot: HRV, sonno, peso giornaliero.Crea un DatabaseService singleton per gestire l'inizializzazione e il CRUD."
FASE 2: Logica Core (Il "Butler Advice")
Prompt da usare:
"Implementa la logica di 'Outfit Suggestion'. Crea una funzione che riceva in input: Temperatura esterna, Vento, Altitudine (dal GPX) e thermalSensitivity dell'utente. Deve restituire una lista di capi consigliati (es. Maglia termica, Gilet, Mantellina) basata su soglie termiche personalizzabili. Aggiungi un controllo: se il dislivello del GPX supera i 500m, suggerisci sempre un antivento per la discesa."
FASE 3: Importazione GPX e Mappe
Prompt da usare:
"Crea un modulo per importare file GPX locali. L'app deve: 1. Permettere all'utente di selezionare un file. 2. Estrarre coordinate (Inizio, Metà, Fine), Distanza e Dislivello. 3. Visualizzare il percorso su una mappa gratuita usando flutter_map (OpenStreetMap). Salva il file nella directory locale dell'app e registra il link nel DB Isar."
FASE 4: Dashboard Biometrica e Anteprima
Prompt da usare:
"Costruisci la Home Dashboard (Material 3). Inserisci:
	1.	Un 'Readiness Score' basato sull'ultimo HRV e sonno.
	2.	Una card 'Prossima Uscita' che mostri meteo e outfit per il GPX pianificato più vicino.
	3.	Grafici sparkline per il trend del peso e dell'HRV degli ultimi 7 giorni usando fl_chart.
	4.	Un pulsante per sincronizzare i dati da Apple Health/Google Fit tramite il plugin health."
FASE 5: Backup e Onboarding
Prompt da usare:
"1. Implementa una procedura di Onboarding a 3 step: Dati fisici, Test di sensibilità al freddo (slider 1-5), e aggiunta prima bici.
2. Crea una funzione di Backup/Ripristino che esporti l'intero database Isar in un file JSON locale, permettendo all'utente di salvarlo esternamente o importarlo."

4. LOGICA ALGORITMICA DI RIFERIMENTO (Da dare all'AI)
Per il calcolo dei vestiti, usa questa logica di base come punto di partenza:
	•	Temp > 20°C: Kit estivo leggero.
	•	15°C - 20°C: Kit estivo + Gilet (se ventoso).
	•	10°C - 15°C: Manica lunga leggera o manicotti.
	•	5°C - 10°C: Giacca invernale leggera + Calzamaglia.
	•	< 5°C: Giacca termica pesante, copriscarpe, guanti termici.
	•	Correzione: Se thermalSensitivity > 3, abbassa le soglie di 3 gradi. Se < 3, alzale di 3 gradi.

Istruzioni per l'utente:
Copia questo documento in un file di testo o direttamente nella chat di sistema del tuo IDE Agility. Inizia con il Prompt Fase 1 e attendi che l'AI generi il codice prima di passare alla fase successiva.
