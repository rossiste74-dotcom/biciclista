/// prompts used for generating the "Anonima Ciclisti" comic strips.
/// These can be used as a reference or moved to Supabase for dynamic generation.
class ComicPrompts {
  static const String graphicalStyle = '''
- Stile: Fumetto illustrato, stile europeo moderno (es. stile Ligne Claire o moderno BD).
- Tratto: Linee pulite, contorni definiti, colori pieni e naturali.
- Ambientazione: All'aperto (strade di campagna, bordo sentiero, bar ciclistici).
- Personaggi: Riconoscibili per abbigliamento tecnico (caschi, maglie, occhiali sportivi).
- Espressioni: Corporee teatrali, ironiche, sguardi sarcastici.
''';

  static const String characterBase = '''
Basato sulla foto di riferimento del gruppo "MTB CREW":
- Protagonista: Uomo con barba, casco bianco, occhiali scuri, maglia "MTB CREW" con palma.
- Spalla 1: Uomo con casco arancio acceso.
- Spalla 2: Uomo con maglia verde "PASSOSCURO".
- Gruppo: Altri ciclisti amatoriali del gruppo originale.
''';

  static const String promptAvg = '''
3 vignette orizzontali. 
Vignetta 1: Il protagonista (casco bianco) è sul sentiero e dice: "Domani si pedala sul serio!".
Vignetta 2: Primo piano degli altri due (casco arancio e maglia verde) che sembrano stanchi o scettici. Bubbles: "Se non piove.", "Se non tira vento.", "Se non sono stanco."
Vignetta 3: Tutto il gruppo è seduto al bar con le bici appoggiate. Un cartello dice: "La motivazione è facoltativa." Il protagonista ride: "Dai, almeno un caffè lo facciamo."
''';

  static const String promptLazy = '''
3 vignette orizzontali.
Vignetta 1: Il protagonista è sul divano col telecomando, la bici è in un angolo con ragnatele. Lui chiede: "Oggi si esce?"
Vignetta 2: Schermo di uno smartphone con chat di gruppo. Messaggi: "Piove troppo (non piove)", "Ho una cena tra tre giorni, devo riposare", "Mi fa male l'unghia del mignolo".
Vignetta 3: Il gruppo è in pizzeria, senza bici. Un cartello dice: "Il divano è il nostro GPM preferito."
''';

  static const String promptPro = '''
3 vignette orizzontali.
Vignetta 1: Il protagonista e quello col casco arancio arrancano su una salita brutale al 20%, sudati. Lui dice: "Solo un giretto agile, dicevano..."
Vignetta 2: Quello con la maglia verde guarda il Garmin che segna "5000m D+". Urla: "Siamo solo a metà! Pigri!"
Vignetta 3: Tutti crollati a terra esausti ma sorridenti vicino a un cartello: "Se non soffri, non sei del gruppo."
''';
}
