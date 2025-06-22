-- Migration: Add trigger to automatically update recipe rating and review count
-- This trigger will automatically update the recipes table whenever reviews are added, updated, or deleted

-- First, create the function that will be called by the trigger
CREATE OR REPLACE FUNCTION update_recipe_rating_on_review_change()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    recipe_id_to_update uuid;
    new_rating numeric;
    new_count integer;
BEGIN
    -- Determine which recipe_id to update based on the operation
    IF TG_OP = 'DELETE' THEN
        recipe_id_to_update := OLD.recipe_id;
    ELSE
        recipe_id_to_update := NEW.recipe_id;
    END IF;    -- Calculate new average rating and count for the recipe
    SELECT 
        COALESCE(AVG(rating), 0),
        COUNT(*)
    INTO new_rating, new_count
    FROM recipe_reviews 
    WHERE recipe_id = recipe_id_to_update;

    -- Update the recipes table with new rating and review count
    UPDATE recipes 
    SET 
        rating = new_rating,
        review_count = new_count,
        updated_at = NOW()
    WHERE id = recipe_id_to_update;

    -- Return the appropriate row based on operation
    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    ELSE
        RETURN NEW;
    END IF;
END;
$$;

-- Create the trigger that calls the function
DROP TRIGGER IF EXISTS trigger_update_recipe_rating ON recipe_reviews;

CREATE TRIGGER trigger_update_recipe_rating
    AFTER INSERT OR UPDATE OR DELETE ON recipe_reviews
    FOR EACH ROW
    EXECUTE FUNCTION update_recipe_rating_on_review_change();

-- Comment explaining the trigger
COMMENT ON FUNCTION update_recipe_rating_on_review_change() IS 
'Automatically updates recipe rating and review_count whenever reviews are inserted, updated, or deleted';

COMMENT ON TRIGGER trigger_update_recipe_rating ON recipe_reviews IS 
'Trigger to automatically maintain recipe rating and review_count in sync with recipe_reviews table';
