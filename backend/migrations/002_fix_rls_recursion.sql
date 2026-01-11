-- Run this in Supabase SQL Editor to fix the infinite recursion error
-- The issue is that the profiles policy is checking profiles which creates a loop

-- First, drop the problematic policies
DROP POLICY IF EXISTS "Public profiles are viewable by everyone" ON profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON profiles;
DROP POLICY IF EXISTS "Enable insert for authenticated users" ON profiles;

-- Recreate simple, non-recursive policies
-- Allow anyone to read any profile (public profiles)
CREATE POLICY "Public profiles are viewable by everyone" 
ON profiles FOR SELECT 
USING (true);

-- Allow users to update their own profile
CREATE POLICY "Users can update own profile" 
ON profiles FOR UPDATE 
USING (auth.uid() = id);

-- Allow new profiles to be inserted (for the trigger and signup)
CREATE POLICY "Allow profile creation" 
ON profiles FOR INSERT 
WITH CHECK (true);

-- Fix events policy to not reference profiles (avoiding recursion)
DROP POLICY IF EXISTS "Organizers can insert events" ON events;
CREATE POLICY "Authenticated users can insert events" 
ON events FOR INSERT 
WITH CHECK (auth.role() = 'authenticated');

-- Fix registrations policies
DROP POLICY IF EXISTS "Admins can view all registrations" ON registrations;

-- Simpler registration viewing - users see their own
CREATE POLICY "Users can view own registrations" 
ON registrations FOR SELECT 
USING (auth.uid() = user_id);
