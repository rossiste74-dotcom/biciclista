-- Add track_id column to planned_rides table
-- This is required to link planned rides to personal tracks

ALTER TABLE planned_rides 
ADD COLUMN IF NOT EXISTS track_id UUID REFERENCES personal_tracks(id) ON DELETE SET NULL;

-- Add index for performance
CREATE INDEX IF NOT EXISTS idx_planned_rides_track_id ON planned_rides(track_id);

-- Optional: If personal_tracks table is missing (which shouldn't happen based on code analysis, but safe to check)
-- We assume personal_tracks exists. If not, this migration will fail on the REFERENCES part.
