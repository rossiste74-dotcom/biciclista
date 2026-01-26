-- Add FTP column to profiles table
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS ftp INTEGER DEFAULT 200;
