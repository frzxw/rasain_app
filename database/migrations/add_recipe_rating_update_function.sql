-- Migration: Add RPC function to update recipe ratings
-- This function bypasses RLS to allow rating updates from any authenticated user
-- Date: 2025-06-23

-- Drop function if it exists
DROP FUNCTION IF EXISTS update_recipe_rating(UUID, NUMERIC, INTEGER);

-- Create function to update recipe rating and review count
CREATE OR REPLACE FUNCTION update_recipe_rating(
  recipe_id UUID,
  new_rating NUMERIC,
  new_review_count INTEGER
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER -- This allows the function to bypass RLS
AS $$
BEGIN
  -- Update the recipe with new rating and review count
  UPDATE recipes 
  SET 
    rating = new_rating,
    review_count = new_review_count,
    updated_at = NOW()
  WHERE id = recipe_id;
  
  -- Check if the update was successful
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Recipe with id % not found', recipe_id;
  END IF;
END;
$$;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION update_recipe_rating(UUID, NUMERIC, INTEGER) TO authenticated;

-- Add comment
COMMENT ON FUNCTION update_recipe_rating IS 'Updates recipe rating and review count, bypassing RLS for rating calculations';
