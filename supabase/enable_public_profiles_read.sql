-- Enable public read access for profiles table
-- allowing all authenticated users to see other users' names and avatars

DROP POLICY IF EXISTS "Users can view own profile" ON profiles;

CREATE POLICY "Authenticated users can view all profiles"
  ON profiles FOR SELECT
  USING (auth.role() = 'authenticated');
