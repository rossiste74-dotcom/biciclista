-- Migration script to add missing columns to profiles and public_profiles tables
-- Date: 2024-01-21

-- 1. Add avatar_data to public_profiles (needed for CrewService)
ALTER TABLE public_profiles 
ADD COLUMN IF NOT EXISTS avatar_data JSONB;

-- 2. Add raw_data to profiles (needed for DataModeService sync)
ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS raw_data JSONB;

-- 3. Add avatar_data to profiles (for completeness/direct access)
ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS avatar_data JSONB;

-- 4. Update the trigger function to ensure updated_at is handled (just in case)
-- (Already exists in schema.sql but good to double check if needed, skipping for now as it's just columns)
