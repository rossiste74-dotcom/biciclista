-- ============================================================================
-- BICICLISTICO - COMMUNITY TRACKS CATALOG SCHEMA
-- ============================================================================
-- Catalogo globale tracce GPX con zero duplicazione e ottimizzazione spazio
-- Da eseguire DOPO crew_schema.sql
-- ============================================================================

-- ============================================================================
-- TABELLA: COMMUNITY_TRACKS (Catalogo Globale Tracce)
-- ============================================================================
CREATE TABLE IF NOT EXISTS community_tracks (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  creator_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  
  -- Info Traccia
  track_name TEXT NOT NULL,
  description TEXT,
  
  -- Dati GPX (semplificati con RDP)
  gpx_data JSONB, -- Array punti ottimizzati
  distance DOUBLE PRECISION NOT NULL,
  elevation DOUBLE PRECISION DEFAULT 0,
  duration INTEGER, -- Durata media in secondi
  
  -- Classificazione
  difficulty_level TEXT NOT NULL DEFAULT 'medium', -- easy, medium, hard, expert
  region TEXT, -- es. "Lombardia", "Toscana"
  country TEXT DEFAULT 'IT',
  track_type TEXT, -- road, gravel, mtb, mixed
  
  -- Visibilità & Popolarità
  is_public BOOLEAN DEFAULT true,
  is_featured BOOLEAN DEFAULT false, -- Tracce in evidenza
  usage_count INTEGER DEFAULT 0, -- Quante volte usata/salvata
  avg_rating DOUBLE PRECISION DEFAULT 0,
  total_ratings INTEGER DEFAULT 0,
  
  -- Coordinate inizio (per proximity search)
  start_latitude DOUBLE PRECISION,
  start_longitude DOUBLE PRECISION,
  
  -- Timestamps
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================================================
-- TABELLA: SAVED_TRACKS (Tracce Salvate Utente - Solo Riferimenti)
-- ============================================================================
CREATE TABLE IF NOT EXISTS saved_tracks (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  track_id UUID REFERENCES community_tracks(id) ON DELETE CASCADE NOT NULL,
  
  -- Personalizzazione
  custom_name TEXT, -- Override nome traccia
  notes TEXT, -- Note personali
  
  -- Timestamp
  saved_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- Un utente può salvare una traccia solo una volta
  UNIQUE(user_id, track_id)
);

-- ============================================================================
-- TABELLA: TRACK_RATINGS (Valutazioni Tracce)
-- ============================================================================
CREATE TABLE IF NOT EXISTS track_ratings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  track_id UUID REFERENCES community_tracks(id) ON DELETE CASCADE NOT NULL,
  
  -- Rating
  rating INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),
  comment TEXT,
  
  -- Timestamp
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- Un utente può valutare una traccia solo una volta
  UNIQUE(user_id, track_id)
);

-- ============================================================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================================================

ALTER TABLE community_tracks ENABLE ROW LEVEL SECURITY;
ALTER TABLE saved_tracks ENABLE ROW LEVEL SECURITY;
ALTER TABLE track_ratings ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- POLICIES: COMMUNITY_TRACKS
-- ============================================================================

-- Tracce pubbliche visibili a tutti
CREATE POLICY "Public tracks visible to all"
  ON community_tracks FOR SELECT
  USING (
    auth.uid() IS NOT NULL AND (
      is_public = true OR 
      creator_id = auth.uid()
    )
  );

-- Utenti possono creare tracce
CREATE POLICY "Users can create tracks"
  ON community_tracks FOR INSERT
  WITH CHECK (auth.uid() = creator_id);

-- Creator può aggiornare proprie tracce
CREATE POLICY "Creators can update own tracks"
  ON community_tracks FOR UPDATE
  USING (auth.uid() = creator_id)
  WITH CHECK (auth.uid() = creator_id);

-- Creator può eliminare proprie tracce
CREATE POLICY "Creators can delete own tracks"
  ON community_tracks FOR DELETE
  USING (auth.uid() = creator_id);

-- ============================================================================
-- POLICIES: SAVED_TRACKS
-- ============================================================================

-- Utenti vedono solo le proprie tracce salvate
CREATE POLICY "Users can view own saved tracks"
  ON saved_tracks FOR SELECT
  USING (auth.uid() = user_id);

-- Utenti possono salvare tracce
CREATE POLICY "Users can save tracks"
  ON saved_tracks FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Utenti possono eliminare proprie tracce salvate
CREATE POLICY "Users can delete own saved tracks"
  ON saved_tracks FOR DELETE
  USING (auth.uid() = user_id);

-- ============================================================================
-- POLICIES: TRACK_RATINGS
-- ============================================================================

-- Tutti vedono i rating
CREATE POLICY "Ratings visible to all authenticated"
  ON track_ratings FOR SELECT
  USING (auth.uid() IS NOT NULL);

-- Utenti possono creare rating
CREATE POLICY "Users can create ratings"
  ON track_ratings FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Utenti possono aggiornare propri rating
CREATE POLICY "Users can update own ratings"
  ON track_ratings FOR UPDATE
  USING (auth.uid() = user_id);

-- Utenti possono eliminare propri rating
CREATE POLICY "Users can delete own ratings"
  ON track_ratings FOR DELETE
  USING (auth.uid() = user_id);

-- ============================================================================
-- TRIGGERS
-- ============================================================================

-- Trigger per updated_at
CREATE TRIGGER update_community_tracks_updated_at
  BEFORE UPDATE ON community_tracks
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Trigger per incrementare usage_count quando traccia viene salvata
CREATE OR REPLACE FUNCTION increment_track_usage()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE community_tracks 
  SET usage_count = usage_count + 1 
  WHERE id = NEW.track_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER increment_usage_on_save
  AFTER INSERT ON saved_tracks
  FOR EACH ROW
  EXECUTE FUNCTION increment_track_usage();

-- Trigger per decrementare usage_count quando traccia salvata viene rimossa
CREATE OR REPLACE FUNCTION decrement_track_usage()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE community_tracks 
  SET usage_count = GREATEST(0, usage_count - 1)
  WHERE id = OLD.track_id;
  RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER decrement_usage_on_delete
  AFTER DELETE ON saved_tracks
  FOR EACH ROW
  EXECUTE FUNCTION decrement_track_usage();

-- Trigger per aggiornare avg_rating quando viene aggiunto un rating
CREATE OR REPLACE FUNCTION update_track_rating()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE community_tracks 
  SET 
    avg_rating = (
      SELECT AVG(rating)::DOUBLE PRECISION 
      FROM track_ratings 
      WHERE track_id = NEW.track_id
    ),
    total_ratings = (
      SELECT COUNT(*) 
      FROM track_ratings 
      WHERE track_id = NEW.track_id
    )
  WHERE id = NEW.track_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_rating_on_insert
  AFTER INSERT ON track_ratings
  FOR EACH ROW
  EXECUTE FUNCTION update_track_rating();

CREATE TRIGGER update_rating_on_update
  AFTER UPDATE ON track_ratings
  FOR EACH ROW
  EXECUTE FUNCTION update_track_rating();

CREATE TRIGGER update_rating_on_delete
  AFTER DELETE ON track_ratings
  FOR EACH ROW
  EXECUTE FUNCTION update_track_rating();

-- ============================================================================
-- INDEXES PER PERFORMANCE
-- ============================================================================

-- Index per creator
CREATE INDEX IF NOT EXISTS idx_community_tracks_creator ON community_tracks(creator_id);

-- Index per popolarità e rating
CREATE INDEX IF NOT EXISTS idx_community_tracks_usage ON community_tracks(usage_count DESC);
CREATE INDEX IF NOT EXISTS idx_community_tracks_rating ON community_tracks(avg_rating DESC);

-- Index per filtri
CREATE INDEX IF NOT EXISTS idx_community_tracks_public ON community_tracks(is_public);
CREATE INDEX IF NOT EXISTS idx_community_tracks_difficulty ON community_tracks(difficulty_level);
CREATE INDEX IF NOT EXISTS idx_community_tracks_region ON community_tracks(region);
CREATE INDEX IF NOT EXISTS idx_community_tracks_type ON community_tracks(track_type);

-- Index geospaziale per proximity search (semplice, senza PostGIS)
CREATE INDEX IF NOT EXISTS idx_community_tracks_start_coords 
  ON community_tracks(start_latitude, start_longitude);

-- Index per saved_tracks
CREATE INDEX IF NOT EXISTS idx_saved_tracks_user ON saved_tracks(user_id);
CREATE INDEX IF NOT EXISTS idx_saved_tracks_track ON saved_tracks(track_id);

-- Index per ratings
CREATE INDEX IF NOT EXISTS idx_track_ratings_track ON track_ratings(track_id);
CREATE INDEX IF NOT EXISTS idx_track_ratings_user ON track_ratings(user_id);

-- ============================================================================
-- FUNZIONI HELPER
-- ============================================================================

-- Funzione per calcolare distanza tra due punti (haversine)
CREATE OR REPLACE FUNCTION calculate_distance(
  lat1 DOUBLE PRECISION,
  lon1 DOUBLE PRECISION,
  lat2 DOUBLE PRECISION,
  lon2 DOUBLE PRECISION
)
RETURNS DOUBLE PRECISION AS $$
DECLARE
  R DOUBLE PRECISION := 6371; -- Earth radius in km
  dLat DOUBLE PRECISION;
  dLon DOUBLE PRECISION;
  a DOUBLE PRECISION;
  c DOUBLE PRECISION;
BEGIN
  dLat := radians(lat2 - lat1);
  dLon := radians(lon2 - lon1);
  
  a := sin(dLat/2) * sin(dLat/2) +
       cos(radians(lat1)) * cos(radians(lat2)) *
       sin(dLon/2) * sin(dLon/2);
  
  c := 2 * atan2(sqrt(a), sqrt(1-a));
  
  RETURN R * c;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- ============================================================================
-- COMPLETATO!
-- ============================================================================
-- Schema catalogo community tracce pronto
-- Esegui questo dopo crew_schema.sql
-- ============================================================================
