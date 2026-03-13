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
Basato sulla foto di riferimento del gruppo "MTB CREW" tutti i ciclisti usano biciclette MTB. 
- Protagonista:"Il PRESIDENTE" Uomo con barba, casco bianco con piccola ananas sulla fronte, occhiali scuri, maglia "MTB CREW" con palma.
- Spalla 1:"MarcoTrek" Uomo con casco Rosso acceso smpre pronto a scattare in fuga, magliagerde con strisce nera alta e palma mtbCrew al centre.
- Spalla 2:"EnzoChar" il nonno un 10 marcie in più..... ci parli in partenza al giro e ti stacca dopo 2 km. se ti dice bene lo rivedi al bar all'arrivo.Maglia giallo nera MtbCrew
- Spalla 3:"E-Davide" Il e-bike robotico maglia bianco con riferimenti al tricolore.
- Spalla 4:"Dany" DanySucciaruota , maglia nera con palma mtbCrew al centre e occhiali scuri è sempre lì a ruota di chi sta davanti. 
- Spalla 5:"Pante"  un tipo magro alto con occhiali scuri e maglia nera con palma mtbCrew al centre, con ogni tipo di tecnologia addosso per fare filmati.
- Spalla 6:"Marc-Tancio" il bicilcista zainetto..Tancio il ciclista che non deve chiedere mai! .... Ma che c'avrà mai dentro?  .maglia nero verde con palma mtbCrew al centre.
- Spalla 7:"VaLentino - il fantino" maglia nera verde con scritta "arsenium" ma quando pedali
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
