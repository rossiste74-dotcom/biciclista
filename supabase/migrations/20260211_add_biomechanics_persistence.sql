-- Add biomechanics_analyses table for persistence
CREATE TABLE IF NOT EXISTS biomechanics_analyses (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  
  -- Analysis Data (The JSON model)
  analysis_data JSONB NOT NULL,
  
  -- The final narrative verdict
  verdict TEXT NOT NULL,
  
  -- Bike Type used
  bike_type TEXT DEFAULT 'ROAD',
  
  -- Timestamps
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE biomechanics_analyses ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "Users can view own analyses" ON biomechanics_analyses
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own analyses" ON biomechanics_analyses
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Index for performance
CREATE INDEX IF NOT EXISTS idx_biomechanics_user_id ON biomechanics_analyses(user_id);
CREATE INDEX IF NOT EXISTS idx_biomechanics_created_at ON biomechanics_analyses(created_at DESC);
