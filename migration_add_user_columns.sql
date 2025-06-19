-- Migration: Add user_name and user_image_url columns to community_posts table
-- This migration adds the missing user columns to sync with the model expectations

-- Add user_name column to community_posts
ALTER TABLE public.community_posts 
ADD COLUMN IF NOT EXISTS user_name TEXT NOT NULL DEFAULT 'Unknown User';

-- Add user_image_url column to community_posts  
ALTER TABLE public.community_posts 
ADD COLUMN IF NOT EXISTS user_image_url TEXT;

-- Update existing records to populate user_name from user_profiles if possible
UPDATE public.community_posts 
SET user_name = COALESCE(
  (SELECT name FROM public.user_profiles WHERE user_profiles.id = community_posts.user_id),
  'Unknown User'
)
WHERE user_name = 'Unknown User' OR user_name IS NULL;

-- Update existing records to populate user_image_url from user_profiles if possible
UPDATE public.community_posts 
SET user_image_url = (
  SELECT image_url FROM public.user_profiles WHERE user_profiles.id = community_posts.user_id
)
WHERE user_image_url IS NULL;

-- Add some indexes for better performance
CREATE INDEX IF NOT EXISTS idx_community_posts_user_name ON public.community_posts(user_name);

-- Show the updated structure
\d public.community_posts;
