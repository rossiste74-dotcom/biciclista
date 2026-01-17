# Biciclistico 🚴‍♂️

**Biciclistico** è il tuo assistente digitale personale per il ciclismo. Non un semplice tracker, ma un vero **Butler** che si prende cura della tua esperienza in sella, dalla manutenzione della bici ai consigli sull'abbigliamento, potenziato dall'Intelligenza Artificiale.

![App Icon](assets/icon/icon.png)

## ✨ Funzionalità Principali

### 🧠 AI Coach "Butler" (BYOK)
Il cuore pulsante dell'app. Configura la tua chiave API personale (OpenAI, Claude o Gemini) e lascia che il Butler analizzi i tuoi dati:
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

## 🛠️ Stack Tecnologico
Sviluppato con ❤️ usando **Flutter**.
*   **Database**: [Isar](https://isar.dev/) (NoSQL locale ultra-veloce).
*   **Mappe**: [Flutter Map](https://pub.dev/packages/flutter_map) & OpenStreetMap.
*   **Grafici**: [Fl Chart](https://pub.dev/packages/fl_chart).
*   **AI**: Integrazioni HTTP dirette per massima privacy (nessun server intermedio).

---
*Ride safe. Ride smart.*
