-- ============================================================================
-- BICICLISTICO - CREW MODULE SCHEMA
-- ============================================================================
-- Modulo sociale: uscite di gruppo, marker real-time, profili pubblici
-- Da eseguire DOPO lo schema principale (schema.sql)
-- ============================================================================

-- ============================================================================
-- TABELLA: PUBLIC_PROFILES (Profili Pubblici Utenti)
-- ============================================================================
CREATE TABLE IF NOT EXISTS public_profiles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  
  -- Info Pubbliche
  display_name TEXT NOT NULL,
  bio TEXT,
  profile_image_url TEXT,
  
  -- Privacy Settings
  is_private BOOLEAN DEFAULT false,
  show_garage BOOLEAN DEFAULT false,
  show_stats BOOLEAN DEFAULT true,
  
  -- Statistiche (da Strava sync o calcolo locale)
  total_km DOUBLE PRECISION DEFAULT 0.0,
  total_rides INTEGER DEFAULT 0,
  total_elevation DOUBLE PRECISION DEFAULT 0.0,
  
  -- Timestamps
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  UNIQUE(user_id)
);

-- ============================================================================
-- TABELLA: FRIENDSHIPS (Relazioni Amicizia)
-- ============================================================================
CREATE TABLE IF NOT EXISTS friendships (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  friend_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  
  -- Status: pending, accepted, blocked
  status TEXT NOT NULL DEFAULT 'pending',
  
  -- Timestamps
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- Un utente non può essere amico di se stesso
  CHECK (user_id != friend_id),
  
  -- Unique constraint per evitare duplicati
  UNIQUE(user_id, friend_id)
);

-- ============================================================================
-- TABELLA: GROUP_RIDES (Uscite di Gruppo)
-- ============================================================================
CREATE TABLE IF NOT EXISTS group_rides (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  creator_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  
  -- Info Uscita
  ride_name TEXT NOT NULL,
  description TEXT,
  
  -- Dati Percorso
  gpx_data JSONB, -- GPX points array
  gpx_file_url TEXT, -- URL file GPX completo
  distance DOUBLE PRECISION,
  elevation DOUBLE PRECISION,
  
  -- Meeting Info
  meeting_point TEXT NOT NULL, -- Indirizzo o coordinate
  meeting_latitude DOUBLE PRECISION,
  meeting_longitude DOUBLE PRECISION,
  meeting_time TIMESTAMP WITH TIME ZONE NOT NULL,
  
  -- Difficoltà: easy, medium, hard, expert
  difficulty_level TEXT NOT NULL DEFAULT 'medium',
  
  -- Partecipanti
  max_participants INTEGER DEFAULT 10,
  
  -- Visibilità
  is_public BOOLEAN DEFAULT true, -- false = solo amici
  
  -- Status: planned, active, completed, cancelled
  status TEXT NOT NULL DEFAULT 'planned',
  
  -- Timestamps
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================================================
-- TABELLA: GROUP_RIDE_PARTICIPANTS (Partecipanti Uscite)
-- ============================================================================
CREATE TABLE IF NOT EXISTS group_ride_participants (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  group_ride_id UUID REFERENCES group_rides(id) ON DELETE CASCADE NOT NULL,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  
  -- Status: pending, confirmed, declined, left
  status TEXT NOT NULL DEFAULT 'confirmed',
  
  -- Timestamps
  joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- Un utente non può partecipare due volte alla stessa uscita
  UNIQUE(group_ride_id, user_id)
);

-- ============================================================================
-- TABELLA: MAP_MARKERS (Marker Mappa Real-time)
-- ============================================================================
CREATE TABLE IF NOT EXISTS map_markers (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  
  -- Posizione
  latitude DOUBLE PRECISION NOT NULL,
  longitude DOUBLE PRECISION NOT NULL,
  
  -- Tipo: danger, rest, info, photo
  marker_type TEXT NOT NULL,
  
  -- Info
  title TEXT,
  description TEXT,
  image_url TEXT,
  
  -- Scadenza automatica 24h
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  expires_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() + INTERVAL '24 hours'),
  is_active BOOLEAN DEFAULT true
);

-- ============================================================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================================================

-- Abilita RLS
ALTER TABLE public_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE friendships ENABLE ROW LEVEL SECURITY;
ALTER TABLE group_rides ENABLE ROW LEVEL SECURITY;
ALTER TABLE group_ride_participants ENABLE ROW LEVEL SECURITY;
ALTER TABLE map_markers ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- POLICIES: PUBLIC_PROFILES
-- ============================================================================

-- Profili pubblici visibili a tutti gli utenti autenticati
CREATE POLICY "Public profiles visible to authenticated users"
  ON public_profiles FOR SELECT
  USING (
    auth.uid() IS NOT NULL AND (
      is_private = false OR 
      user_id = auth.uid() OR
      -- Visibile anche ad amici accettati se privato
      (is_private = true AND user_id IN (
        SELECT friend_id FROM friendships 
        WHERE user_id = auth.uid() AND status = 'accepted'
        UNION
        SELECT user_id FROM friendships 
        WHERE friend_id = auth.uid() AND status = 'accepted'
      ))
    )
  );

-- Utenti possono creare il proprio profilo
CREATE POLICY "Users can create own profile"
  ON public_profiles FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Utenti possono aggiornare il proprio profilo
CREATE POLICY "Users can update own profile"
  ON public_profiles FOR UPDATE
  USING (auth.uid() = user_id);

-- ============================================================================
-- POLICIES: FRIENDSHIPS
-- ============================================================================

-- Utenti vedono le proprie amicizie
CREATE POLICY "Users can view own friendships"
  ON friendships FOR SELECT
  USING (auth.uid() = user_id OR auth.uid() = friend_id);

-- Utenti possono creare richieste amicizia
CREATE POLICY "Users can create friend requests"
  ON friendships FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Utenti possono aggiornare richieste ricevute
CREATE POLICY "Users can update received requests"
  ON friendships FOR UPDATE
  USING (auth.uid() = friend_id);

-- Utenti possono eliminare le proprie amicizie
CREATE POLICY "Users can delete own friendships"
  ON friendships FOR DELETE
  USING (auth.uid() = user_id OR auth.uid() = friend_id);

-- ============================================================================
-- POLICIES: GROUP_RIDES
-- ============================================================================

-- Uscite pubbliche visibili a tutti
CREATE POLICY "Public rides visible to all authenticated"
  ON group_rides FOR SELECT
  USING (
    auth.uid() IS NOT NULL AND (
      is_public = true OR 
      creator_id = auth.uid() OR
      -- Participant può vedere
      id IN (SELECT group_ride_id FROM group_ride_participants WHERE user_id = auth.uid())
    )
  );

-- Utenti possono creare uscite
CREATE POLICY "Users can create group rides"
  ON group_rides FOR INSERT
  WITH CHECK (auth.uid() = creator_id);

-- Creator può aggiornare la propria uscita
CREATE POLICY "Creators can update own rides"
  ON group_rides FOR UPDATE
  USING (auth.uid() = creator_id);

-- Creator può cancellare la propria uscita
CREATE POLICY "Creators can delete own rides"
  ON group_rides FOR DELETE
  USING (auth.uid() = creator_id);

-- ============================================================================
-- POLICIES: GROUP_RIDE_PARTICIPANTS
-- ============================================================================

-- Utenti vedono partecipanti delle uscite a cui hanno accesso
CREATE POLICY "Users can view participants of visible rides"
  ON group_ride_participants FOR SELECT
  USING (
    group_ride_id IN (
      SELECT id FROM group_rides 
      WHERE is_public = true OR creator_id = auth.uid()
    )
  );

-- Utenti possono unirsi a uscite
CREATE POLICY "Users can join rides"
  ON group_ride_participants FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Utenti possono aggiornare la propria partecipazione
CREATE POLICY "Users can update own participation"
  ON group_ride_participants FOR UPDATE
  USING (auth.uid() = user_id);

-- Utenti possono lasciare uscite
CREATE POLICY "Users can leave rides"
  ON group_ride_participants FOR DELETE
  USING (auth.uid() = user_id);

-- ============================================================================
-- POLICIES: MAP_MARKERS
-- ============================================================================

-- Marker attivi visibili a tutti gli utenti autenticati
CREATE POLICY "Active markers visible to authenticated"
  ON map_markers FOR SELECT
  USING (
    auth.uid() IS NOT NULL AND 
    is_active = true AND 
    expires_at > NOW()
  );

-- Utenti possono creare marker
CREATE POLICY "Users can create markers"
  ON map_markers FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Utenti possono eliminare i propri marker
CREATE POLICY "Users can delete own markers"
  ON map_markers FOR DELETE
  USING (auth.uid() = user_id);

-- ============================================================================
-- TRIGGERS
-- ============================================================================

-- Trigger per updated_at su public_profiles
CREATE TRIGGER update_public_profiles_updated_at
  BEFORE UPDATE ON public_profiles
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Trigger per updated_at su friendships
CREATE TRIGGER update_friendships_updated_at
  BEFORE UPDATE ON friendships
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Trigger per updated_at su group_rides
CREATE TRIGGER update_group_rides_updated_at
  BEFORE UPDATE ON group_rides
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Trigger per auto-disattivare marker scaduti
CREATE OR REPLACE FUNCTION deactivate_expired_markers()
RETURNS void AS $$
BEGIN
  UPDATE map_markers 
  SET is_active = false 
  WHERE expires_at < NOW() AND is_active = true;
END;
$$ LANGUAGE plpgsql;

-- Schedulare pulizia marker (manuale o con pg_cron se disponibile)
-- Per ora, l'app chiamerà questa funzione periodicamente

-- ============================================================================
-- INDEXES PER PERFORMANCE
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_public_profiles_user_id ON public_profiles(user_id);
CREATE INDEX IF NOT EXISTS idx_public_profiles_is_private ON public_profiles(is_private);

CREATE INDEX IF NOT EXISTS idx_friendships_user_id ON friendships(user_id);
CREATE INDEX IF NOT EXISTS idx_friendships_friend_id ON friendships(friend_id);
CREATE INDEX IF NOT EXISTS idx_friendships_status ON friendships(status);

CREATE INDEX IF NOT EXISTS idx_group_rides_creator_id ON group_rides(creator_id);
CREATE INDEX IF NOT EXISTS idx_group_rides_meeting_time ON group_rides(meeting_time);
CREATE INDEX IF NOT EXISTS idx_group_rides_status ON group_rides(status);
CREATE INDEX IF NOT EXISTS idx_group_rides_is_public ON group_rides(is_public);

CREATE INDEX IF NOT EXISTS idx_group_ride_participants_ride_id ON group_ride_participants(group_ride_id);
CREATE INDEX IF NOT EXISTS idx_group_ride_participants_user_id ON group_ride_participants(user_id);

CREATE INDEX IF NOT EXISTS idx_map_markers_is_active ON map_markers(is_active);
CREATE INDEX IF NOT EXISTS idx_map_markers_expires_at ON map_markers(expires_at);
CREATE INDEX IF NOT EXISTS idx_map_markers_created_at ON map_markers(created_at);

-- Index geospaziale per query basate su distanza (opzionale con PostGIS)
-- CREATE INDEX IF NOT EXISTS idx_map_markers_location ON map_markers USING GIST (ll_to_earth(latitude, longitude));

-- ============================================================================
-- COMPLETATO!
-- ============================================================================
-- Esegui questo script dopo schema.sql
-- Le tabelle Crew sono ora pronte per l'uso
-- ============================================================================
