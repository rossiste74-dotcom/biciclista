/// Enum representing different types of cycling clothing items
enum ClothingItem {
  /// Lightweight summer cycling kit (jersey + shorts)
  summerKit('Completo Estivo', 'Maglia leggera e pantaloncini'),
  
  /// Windproof vest/gilet
  vest('Gilet', 'Gilet antivento per la protezione del busto'),
  
  /// Arm warmers for moderate temperatures
  armWarmers('Manicotti', 'Manicotti rimovibili termici'),
  
  /// Leg warmers or knee warmers
  legWarmers('Gambali', 'Protezione termica per le gambe'),
  
  /// Long sleeve jersey (lightweight)
  longSleeveJersey('Maglia Manica Lunga', 'Maglia leggera a maniche lunghe'),
  
  /// Light winter jacket
  lightJacket('Giacca Leggera', 'Giacca termica per clima fresco'),
  
  /// Heavy thermal winter jacket
  winterJacket('Giacca Invernale', 'Giacca termica pesante per clima freddo'),
  
  /// Windbreaker/rain jacket
  windbreaker('Antivento', 'Protezione da vento e pioggia per le discese'),
  
  /// Thermal base layer
  baseLayer('Intimo Termico', 'Strato base isolante'),
  
  /// Thermal gloves
  thermalGloves('Guanti Termici', 'Guanti isolati per clima freddo'),
  
  /// Shoe covers/overshoes
  shoeCovers('Copriscarpe', 'Protezione termica per i piedi'),
  
  /// Neck warmer/buff
  neckWarmer('Scaldacollo', 'Protezione termica per il collo');

  const ClothingItem(this.displayName, this.description);

  final String displayName;
  final String description;

  /// Helper to convert a list of indexes to a list of ClothingItems
  static List<ClothingItem> fromIndexes(List<int> indexes) {
    return indexes.map((i) => ClothingItem.values[i]).toList();
  }
}
