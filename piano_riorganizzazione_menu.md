# 🗺️ PIANO DI RIORGANIZZAZIONE DEI MENU E DELL'UI — BICICLISTICO

## 1. ANALISI DELLO STATO ATTUALE (AS-IS)

Basandomi sul codice finora sviluppato, l'app contiene un numero considerevole di funzionalità (Dashboard, Garage, Percorsi, Agenda/Crew, Biomeccanica, AI Coach, Salute, Statistiche e Leaderboard). Tuttavia, l'attuale struttura di navigazione presenta alcune criticità che penalizzano l'esperienza utente (UX):

### Criticità Rilevate:
1. **Dashboard Sovraffollata**: La `DashboardScreen` attualmente funge da "contenitore unico" per quasi tutto: Readiness Score, Trend biometrici, AI Coach Card, Biomeccanica Card, Prossima Uscita, Meteo, Manutenzione, Statistiche e Leaderboard. Questo rende la pagina lunghissima da scorrere e confusa.
2. **FAB (Floating Action Button) Disabilitato**: Nel `MainNavigationScreen`, il pulsante centrale per l'aggiunta rapida (`_showAddMenu()` che contiene Import GPX, Nuovo Percorso, Scan QR) è stato disabilitato (`floatingActionButton: null`). Di conseguenza, alcune azioni fondamentali sono difficili da raggiungere.
3. **Sezione Social (Agenda) Limitativa**: Il 4° tab della Bottom Navigation è "Agenda" (`UnifiedAgendaScreen`). Tuttavia, le funzionalità social (Discovery, Crew, Ricerca Amici, Classifiche) meriterebbero una vera e propria sezione "Community", non solo un'agenda.
4. **Funzioni AI "Nascoste"**: "Il Biciclista" (AI Coach) e la "Biomeccanica" sono relegate a card sulla Dashboard. Essendo funzioni "Premium/Core", necessitano di uno spazio dedicato e più ampio.
5. **Sezione Salute e Storico**: L'accesso ai dettagli delle attività (`HealthActivityListScreen`) avviene tappando sui Km totali nella Dashboard. Manca una sezione chiara per l'analisi approfondita delle proprie performance.

---

## 2. PROPOSTA DI RIORGANIZZAZIONE (TO-BE)

Per migliorare l'usabilità e valorizzare tutte le feature sviluppate, propongo la seguente nuova architettura dell'informazione:

### A. Bottom Navigation Bar (Rinnovata)
L'idea è passare a 5 elementi (con il FAB centrale), raggruppando meglio le logiche:

1. 🏠 **Home (ex Dashboard)**
   - *Scopo*: Visione d'insieme rapida (Oggi).
   - *Cosa mostrare*: Meteo di oggi, Readiness Score (compatto), Prossima Uscita in programma, e "Saggezza del giorno" (BiciclistaWisdom). Le altre card verranno spostate.

2. 🗺️ **Percorsi**
   - *Scopo*: Pianificazione ed esplorazione mappe.
   - *Cosa mostrare*: Libreria GPX, Route Planner, Mappa dei percorsi salvati.

3. ➕ **FAB Centrale (Azione Rapida)**
   - Ripristino del pulsante centrale sempre visibile (+).
   - *Azioni Mostrate al tap*:
     - Inizia Registrazione (Uscita Manuale / Navigazione Veloce)
     - Crea Route / Importa GPX
     - Organizza Uscita di Gruppo (Crew)
     - Scannerizza QR (Aggiungi amico/percorso)

4. 🚲 **Garage**
   - *Scopo*: Gestione hardware.
   - *Cosa mostrare*: Lista Biciclette, usura componenti, storico manutenzioni, alert in evidenza.

5. 👥 **Community**
   - *Scopo*: L'aspetto social dell'app (sostituisce "Agenda").
   - *Cosa mostrare (Tab o segmenti)*: 
     - *Feed/Agenda*: Uscite in programma (proprie e Crew).
     - *Esplora*: Discovery pubblici e ricerca ciclisti.
     - *Leaderboard*: Classifiche settimanali tra amici.

### B. Menu Laterale (Drawer) o Tab Profilo
L'App Bar superiore dovrebbe ospitare il titolo, l'icona delle Notifiche (campanella) e l'icona del Profilo. Al tap sul Profilo, l'utente accede alla "Scrivania Utente":

1. **👤 Profilo e Statistiche**
   - Dati utente, avatar personalizzato.
   - Statistiche dettagliate dei chilometri, dislivelli e lista completa delle attività passate (`HealthActivityListScreen`).
   
2. **📈 Salute & Biometria**
   - Trend del peso, HRV, Ore di Sonno. Le card analitiche rimosse dalla Dashboard trovano posto qui.

3. **🤖 Laboratorio AI (Nuova Sezione dedicata)**
   - Accesso alla chat interattiva completa con il Coach "Il Biciclista" (`AICoachScreen`).
   - Accesso allo strumento di posizionamento in sella (`BiomechanicsScreen`).

4. **⚙️ Impostazioni**
   - Settings App (Integrazioni Health/Strava, regole avvisi, stili abbigliamento, ecc.).

---

## 3. PIANO DI INTERVENTO (STEP BY STEP)

1. **Fase 1: Ripristino FAB e Strato Base**
   - Modificare `MainNavigationScreen.dart` per reinserire il FAB con sottomenu (Importa GPX, Planner, Scan QR).
   - Ristrutturare la BottomNavigation passando allo schema: *Home, Percorsi, [FAB], Garage, Community*.
   - Rinominare il tab "Agenda" in "Community" e fargli caricare un nuovo `CommunityScreen` (che a sua volta ha dei sub-tab: Agenda, Discovery, Leaderboard).

2. **Fase 2: Snellimento della Dashboard**
   - Pulire `DashboardScreen.dart`.
   - Mantenere solo: Meteo/Saggezza, Readiness (in forma compatta), e Prossima Uscita.
   - Spostare i grafici di trend, i km totali e settimanali all'interno di una nuova view di "Profilo/Statistiche".
   - Rimuovere la lista "Leaderboard" e la "Manutenzione" a fondo pagina dalla Dashboard.

3. **Fase 3: Raggruppamento AI & Laboratorio**
   - Creare una sezione/schermata o accessibile da un pulsante ben visibile nella Home (es. floating widget asimmetrico o nel Drawer/Profilo) chiamato "Laboratorio AI".
   - Collegarci i widget e le screen dell'AI Coach e della Biomeccanica (che attualmente affollano la dashboard).

4. **Fase 4: Perfezionamento Profilo e Salute**
   - Arricchire il `ProfileScreen` affinché mostri i tab per le Statistiche Storiche (tutte le attività importate) e i Trend Biometrici (peso, HRV).
