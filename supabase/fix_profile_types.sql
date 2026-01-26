-- Force correct types for profiles table columns
-- Run this in Supabase SQL Editor if you see "invalid input syntax" errors

-- 1. Ensure Floating Point Columns are DOUBLE PRECISION
ALTER TABLE profiles ALTER COLUMN weight TYPE DOUBLE PRECISION USING weight::DOUBLE PRECISION;
ALTER TABLE profiles ALTER COLUMN height TYPE DOUBLE PRECISION USING height::DOUBLE PRECISION;
ALTER TABLE profiles ALTER COLUMN sleep_hours TYPE DOUBLE PRECISION USING sleep_hours::DOUBLE PRECISION;

-- 2. Ensure Integer Columns are INTEGER
ALTER TABLE profiles ALTER COLUMN resting_heart_rate TYPE INTEGER USING resting_heart_rate::INTEGER;
ALTER TABLE profiles ALTER COLUMN ftp TYPE INTEGER USING ftp::INTEGER;
ALTER TABLE profiles ALTER COLUMN hrv TYPE INTEGER USING hrv::INTEGER;
ALTER TABLE profiles ALTER COLUMN thermal_sensitivity TYPE INTEGER USING thermal_sensitivity::INTEGER;

-- 3. Ensure JSONB
ALTER TABLE profiles ALTER COLUMN health_history TYPE JSONB USING health_history::JSONB;
