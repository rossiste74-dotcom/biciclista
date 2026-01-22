-- ============================================================================
-- SCRIPT DI PULIZIA DATABASE (RESET COMPLETO)
-- ============================================================================
-- ATTENZIONE: Questo script cancella TUTTI i dati creati dagli utenti 
-- (percorsi, uscite, marker, amicizie, ecc.) ma MANTIENE gli account utenti
-- (auth.users) e i relativi profili (profiles, public_profiles).
-- Utile per resettare l'app mantenendo gli account di test.
-- ============================================================================

BEGIN;

-- 1. Disabilita temporaneamente i trigger per velocità (opzionale, ma sicuro)
-- SET session_replication_role = 'replica';

-- 2. Truncate tables a cascata (ordine inverso di dipendenza o CASCADE)
-- Usiamo TRUNCATE ... CASCADE per pulire tutto in un colpo solo rispettando le FK.

RAISE NOTICE 'Inizio pulizia database...';

-- Clean CREW module
TRUNCATE TABLE 
  map_markers,
  group_ride_participants,
  group_rides,
  friendships
CASCADE;

-- Clean CATOLOG module
TRUNCATE TABLE 
  track_ratings,
  saved_tracks,
  community_tracks
CASCADE;

-- Clean CORE module (eccetto profiles)
TRUNCATE TABLE 
  planned_rides,
  bicycles
CASCADE;

-- Nota: profiles e public_profiles NON vengono toccati per mantenere gli account.
-- Se vuoi resettare anche i dati "personali" del profilo (es. peso, hrv) 
-- puoi eseguire degli UPDATE:
-- UPDATE profiles SET weight=70, hrv=50, health_history='[]'::jsonb;

RAISE NOTICE 'Database ripulito con successo (Utenti preservati).';

-- 3. Riabilita trigger
-- SET session_replication_role = 'origin';

COMMIT;
