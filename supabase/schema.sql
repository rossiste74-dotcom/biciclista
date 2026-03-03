-- Biciclistico - Supabase Database Schema
-- Run this SQL in your Supabase SQL Editor to create the database structure

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================================
-- PROFILES TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS profiles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  
  -- Basic Info
  name TEXT NOT NULL,
  age INTEGER,
  gender TEXT,
  
  -- Biometric Data
  weight DOUBLE PRECISION DEFAULT 70.0,
  hrv INTEGER DEFAULT 50,
  sleep_hours DOUBLE PRECISION DEFAULT 7.0,
  
  -- Health History (JSON array of daily records)
  health_history JSONB DEFAULT '[]'::jsonb,
  last_health_sync TIMESTAMP WITH TIME ZONE,
  
  -- Clothing Settings
  thermal_sensitivity INTEGER DEFAULT 3,
  hot_threshold DOUBLE PRECISION DEFAULT 20.0,
  warm_threshold DOUBLE PRECISION DEFAULT 15.0,
  cool_threshold DOUBLE PRECISION DEFAULT 10.0,
  cold_threshold DOUBLE PRECISION DEFAULT 5.0,
  sensitivity_adjustment DOUBLE PRECISION DEFAULT 3.0,
  
  -- Custom Clothing Kits (arrays of item indexes)
  hot_kit INTEGER[] DEFAULT '{}',
  warm_kit INTEGER[] DEFAULT '{}',
  cool_kit INTEGER[] DEFAULT '{}',
  cold_kit INTEGER[] DEFAULT '{}',
  very_cold_kit INTEGER[] DEFAULT '{}',
  
  -- AI Settings
  ai_provider TEXT,
  ai_api_key TEXT,
  ai_model TEXT,
  
  -- Navigation Settings
  max_off_course_distance DOUBLE PRECISION DEFAULT 30.0,
  voice_alerts_enabled BOOLEAN DEFAULT true,
  vibration_alerts_enabled BOOLEAN DEFAULT true,
  
  -- Community Mode
  is_community_mode BOOLEAN DEFAULT false,
  
  -- Timestamps
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- Unique constraint: one profile per user
  UNIQUE(user_id)
);

-- ============================================================================
-- BICYCLES TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS bicycles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  
  -- Basic Info
  name TEXT NOT NULL,
  bike_type TEXT NOT NULL,
  brand TEXT,
  model TEXT,
  year INTEGER,
  
  -- Stats
  total_kilometers DOUBLE PRECISION DEFAULT 0.0,
  chain_kms DOUBLE PRECISION DEFAULT 0.0,
  tyre_kms DOUBLE PRECISION DEFAULT 0.0,
  
  -- Maintenance Limits
  chain_limit DOUBLE PRECISION DEFAULT 3000.0,
  tyre_limit DOUBLE PRECISION DEFAULT 5000.0,
  
  -- Components (JSON array of component objects)
  components JSONB DEFAULT '[]'::jsonb,
  
  -- Timestamps
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================================================
-- PLANNED_RIDES TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS planned_rides (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  bicycle_id UUID REFERENCES bicycles(id) ON DELETE SET NULL,
  
  -- Ride Info
  ride_name TEXT,
  ride_date TIMESTAMP WITH TIME ZONE NOT NULL,
  distance DOUBLE PRECISION DEFAULT 0.0,
  elevation DOUBLE PRECISION DEFAULT 0.0,
  moving_time INTEGER DEFAULT 0,
  avg_speed DOUBLE PRECISION DEFAULT 0.0,
  
  -- Extended Stats
  avg_heart_rate INTEGER,
  max_heart_rate INTEGER,
  avg_power INTEGER,
  max_power INTEGER,
  avg_cadence INTEGER,
  calories INTEGER,
  
  -- Location
  latitude DOUBLE PRECISION,
  longitude DOUBLE PRECISION,
  
  -- GPX Data
  gpx_file_path TEXT,
  gpx_points JSONB,
  
  -- Weather
  forecast_weather JSONB,
  
  -- AI Analysis
  ai_analysis TEXT,
  
  -- Completion
  is_completed BOOLEAN DEFAULT false,
  
  -- Community
  supabase_event_id UUID,
  
  -- Timestamps
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================================================

-- Enable RLS on all tables
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE bicycles ENABLE ROW LEVEL SECURITY;
ALTER TABLE planned_rides ENABLE ROW LEVEL SECURITY;

-- PROFILES Policies
CREATE POLICY "Users can view own profile"
  ON profiles FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own profile"
  ON profiles FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own profile"
  ON profiles FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own profile"
  ON profiles FOR DELETE
  USING (auth.uid() = user_id);

-- BICYCLES Policies
CREATE POLICY "Users can view own bicycles"
  ON bicycles FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own bicycles"
  ON bicycles FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own bicycles"
  ON bicycles FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own bicycles"
  ON bicycles FOR DELETE
  USING (auth.uid() = user_id);

-- PLANNED_RIDES Policies
CREATE POLICY "Users can view own rides"
  ON planned_rides FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own rides"
  ON planned_rides FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own rides"
  ON planned_rides FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own rides"
  ON planned_rides FOR DELETE
  USING (auth.uid() = user_id);

-- ============================================================================
-- TRIGGERS FOR UPDATED_AT
-- ============================================================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply trigger to all tables
CREATE TRIGGER update_profiles_updated_at
  BEFORE UPDATE ON profiles
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_bicycles_updated_at
  BEFORE UPDATE ON bicycles
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_planned_rides_updated_at
  BEFORE UPDATE ON planned_rides
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- INDEXES FOR PERFORMANCE
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_profiles_user_id ON profiles(user_id);
CREATE INDEX IF NOT EXISTS idx_bicycles_user_id ON bicycles(user_id);
CREATE INDEX IF NOT EXISTS idx_planned_rides_user_id ON planned_rides(user_id);
CREATE INDEX IF NOT EXISTS idx_planned_rides_date ON planned_rides(ride_date);
CREATE INDEX IF NOT EXISTS idx_planned_rides_completed ON planned_rides(is_completed);
