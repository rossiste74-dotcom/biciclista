# 📘 RIDE CREW — ANALISI DI PROGETTO

> Documento di analisi tecnica e funzionale dell'applicazione mobile **Ride Crew**, un ecosistema digitale per ciclisti amatoriali e appassionati.

---

## 1. STACK TECNOLOGICO

| Livello | Tecnologia | Ruolo |
|---|---|---|
| **Frontend** | Flutter 3.x (Dart) | App mobile nativa iOS e Android |
| **Backend** | Supabase | Database, Auth, Storage, Realtime |
| **AI** | Google Gemini | Coach AI, Analisi Biomeccanica |
| **Mappe** | OpenStreetMap + flutter_map | Visualizzazione percorsi |
| **Meteo** | Open-Meteo API | Previsioni gratuite e accurate |

### **Flutter**
Flutter è il framework open-source di Google per costruire applicazioni native multi-piattaforma (iOS e Android) da un unico codice sorgente scritto in Dart. Garantisce prestazioni elevate (60/120 fps) e un'interfaccia grafica coerente e personalizzabile su tutti i dispositivi.

### **Supabase**
Supabase è una piattaforma Backend-as-a-Service (BaaS) open-source, alternativa a Firebase. Fornisce un database PostgreSQL, un sistema di autenticazione, storage per file, funzioni serverless (Edge Functions) e aggiornamenti in tempo reale (Realtime). Tutta la logica di business e i dati dell'app risiedono su Supabase.

### **Google Gemini**
Google Gemini è il modello di intelligenza artificiale di Google utilizzato come unico motore AI dell'applicazione. Viene invocato tramite una Supabase Edge Function e gestisce sia le risposte testuali del "biciclista" (coach virtuale) sia l'analisi visiva delle foto per la biomeccanica.

---

## 2. FRAMEWORK E LIBRERIE DI SVILUPPO

### **Connettività & Backend**
| Libreria | Funzione |
|---|---|
| `supabase_flutter` | SDK per comunicare con il backend Supabase |
| `http` | Chiamate HTTP verso API esterne (Open-Meteo) |
| `flutter_secure_storage` | Salvataggio sicuro di credenziali e token |
| `shared_preferences` | Preferenze locali leggere (impostazioni utente) |

### **Mappe & GPS**
| Libreria | Funzione |
|---|---|
| `flutter_map` | Rendering mappe OpenStreetMap |
| `latlong2` | Gestione coordinate geografiche |
| `geolocator` | Accesso al GPS del dispositivo |
| `flutter_compass` | Bussola digitale per la navigazione |
| `gpx` | Parsing e analisi file GPX |

### **Interfaccia & Grafica**
| Libreria | Funzione |
|---|---|
| `fl_chart` | Grafici interattivi (altimetria, HRV, peso) |
| `flutter_svg` | Icone e avatar vettoriali |
| `google_fonts` | Tipografia moderna (es. Inter, Outfit) |

### **Funzionalità Specifiche**
| Libreria | Funzione |
|---|---|
| `health` | Sincronizzazione con Apple Health / Google Health Connect |
| `qr_flutter` | Generazione codici QR |
| `mobile_scanner` | Scansione codici QR |
| `flutter_tts` | Sintesi vocale per avvisi di navigazione |
| `wakelock_plus` | Schermo sempre attivo durante la navigazione |
| `share_plus` | Condivisione contenuti (risultati, percorsi) |
| `easy_localization` | Supporto multilingua (IT/EN) |
| `flutter_local_notifications` | Notifiche locali (manutenzione, meteo) |

---

## 3. FUNZIONALITÀ DELL'APPLICAZIONE

### 🏠 Dashboard Principale
La schermata principale offre una panoramica immediata della situazione del ciclista:
- **Readiness Score**: Punteggio di recupero fisico calcolato su HRV e qualità del sonno.
- **Card Meteo**: Condizioni attuali e previsioni per la prossima uscita pianificata.
- **Outfit Advisor**: Suggerimento abbigliamento tecnico generato dall'AI (biciclista) in base a temperatura, vento, dislivello e sensibilità termica personale.
- **Prossima Uscita**: Riepilogo rapido del percorso pianificato più vicino.

---

### 🗺️ Percorsi e Navigazione

#### Libreria Percorsi
- Importazione file GPX da storage locale.
- Visualizzazione su mappa interattiva (OpenStreetMap).
- Dettagli tecnici: distanza, dislivello totale, profilo altimetrico, tipo di superficie.
- Analisi AI del percorso: difficoltà, strategia di gara, consigli specifici.

#### Pianificatore di Rotte (Route Planner)
- Creazione manuale di percorsi disegnando sulla mappa.
- Calcolo automatico di distanza e dislivello.
- Salvataggio nella libreria personale.

#### Navigazione Attiva
- Mappa in tempo reale con posizione GPS aggiornata.
- Freccia direzionale e bussola digitale.
- **Avvisi Vocali (TTS)**: Indicazioni audio per svolte o punti critici del percorso.
- **WakeLock**: Lo schermo rimane acceso per tutta la durata della navigazione.
- Statistiche live: velocità, distanza percorsa, dislivello accumulato.

---

### 🚲 Garage (Gestione Biciclette)

- Schede dettagliate per ogni bicicletta (nome, tipo, marca, anno).
- **Tracciamento Componenti**: Monitoraggio km per catena, copertoni, pattini freno, cassetta.
- **Alert Manutenzione**: Notifiche automatiche quando un componente si avvicina al limite di usura.
- **Registro Interventi**: Storico delle manutenzioni effettuate.

---

### 👥 Social & Crew

#### Profilo Pubblico
- Avatar personalizzabile con elementi grafici (casco, maglia, occhiali).
- Statistiche pubbliche: km totali, dislivello, numero di uscite.
- "Garage Vetrina": possibilità di mostrare le proprie bici agli altri utenti.

#### Amicizie
- Ricerca utenti per nome.
- Invio e gestione richieste di amicizia.
- Feed attività degli amici.

#### Crew (Uscite di Gruppo)
- Creazione eventi "Ride" con: nome, data/ora, percorso GPX, punto di ritrovo su mappa, livello di difficoltà, numero massimo partecipanti.
- Gestione adesioni in tempo reale (Supabase Realtime).
- Visibilità pubblica o privata dell'evento.
- **Agenda Unificata**: Vista combinata delle proprie uscite, quelle degli amici e gli eventi pubblici nella zona.

#### Discovery
- Esplorazione di uscite pubbliche aperte nella propria area geografica.
- Filtro per data, difficoltà e distanza.

#### Leaderboard
- Classifiche settimanali/mensili per km percorsi o dislivello accumulato.
- Confronto tra amici o classifica globale.

---

### 🧘 Biomeccanica AI (Bike Fit)

- Caricamento di 1-3 foto in sella (vista laterale e frontale).
- Analisi visiva tramite **Google Gemini Vision**: rilevamento automatico dei punti articolari (anca, ginocchio, caviglia, spalla).
- Calcolo degli angoli biomeccanici chiave (estensione ginocchio, angolo schiena, KOPS).
- Generazione di un **Verdetto** in italiano con consigli pratici di regolazione (es. "Alza la sella di 5mm", "Avanza il sellino di 10mm").
- Salvataggio dello storico delle analisi per monitorare i progressi nel tempo.

---

### 📊 Salute & Biometria

- Registrazione manuale di: peso, HRV (Heart Rate Variability), ore di sonno, RHR (frequenza cardiaca a riposo).
- **Sincronizzazione Health**: Import automatico di attività e dati biometrici da Apple Health (iOS) e Google Health Connect (Android).
- Grafici di tendenza per peso e HRV degli ultimi 7/30 giorni.
- Calcolo del **Readiness Score** giornaliero basato su HRV e sonno.

---

### 🤖 AI Coach (biciclista)

- Chat interattiva con il "biciclista", il coach AI con personalità ciclistica italiana.
- **Personalità selezionabili**: Amichevole, Sergente, Zen, Analitico.
- Contesto automatico: il biciclista conosce il profilo fisico, la bici, i km dei componenti e la prossima uscita pianificata.
- Limite giornaliero di richieste gestito lato client.
- **Saggezza Quotidiana**: Frase motivazionale generata ogni giorno per la community.

---

### ⚙️ Impostazioni & Utility

- **QR Code**: Generazione QR per condividere il proprio profilo o un evento. Scanner integrato per seguire un utente o unirsi a una Ride.
- **Impostazioni Outfit**: Personalizzazione delle soglie di temperatura per i consigli abbigliamento.
- **Impostazioni Manutenzione**: Configurazione dei limiti di usura per ogni tipo di componente.
- **Onboarding**: Wizard iniziale guidato per configurare profilo fisico, sensibilità termica e prima bicicletta.
- **Localizzazione**: Interfaccia disponibile in Italiano e Inglese.
- **Backup Cloud**: Tutti i dati sono sincronizzati su Supabase, nessun rischio di perdita dati.

---

## 4. ARCHITETTURA DEL SISTEMA

```
┌─────────────────────────────────────────────────┐
│               APP FLUTTER (Client)              │
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
