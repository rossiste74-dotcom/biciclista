-- Adds the missing 'supabase_event_id' column to 'planned_rides' table
-- to properly track which community group rides have been completed by the user.
ALTER TABLE planned_rides
ADD COLUMN IF NOT EXISTS supabase_event_id UUID;

CREATE INDEX IF NOT EXISTS idx_planned_rides_supabase_event_id ON planned_rides(supabase_event_id);
