-- Simple Timer Seeder for Recipe Instructions
-- Copy and paste this directly into your database SQL editor

-- Update existing recipe instructions with realistic timer values
UPDATE recipe_instructions 
SET timer_minutes = CASE 
    -- Prep steps (usually quick)
    WHEN step_number = 1 THEN 
        CASE 
            WHEN LOWER(instruction_text) LIKE '%cuci%' OR LOWER(instruction_text) LIKE '%bersih%' THEN 3
            WHEN LOWER(instruction_text) LIKE '%potong%' OR LOWER(instruction_text) LIKE '%iris%' THEN 5
            WHEN LOWER(instruction_text) LIKE '%siapkan%' OR LOWER(instruction_text) LIKE '%campurkan%' THEN 2
            ELSE 3
        END
    
    -- Cooking steps (longer)
    WHEN step_number = 2 THEN
        CASE 
            WHEN LOWER(instruction_text) LIKE '%panaskan%' OR LOWER(instruction_text) LIKE '%tumis%' THEN 5
            WHEN LOWER(instruction_text) LIKE '%rebus%' OR LOWER(instruction_text) LIKE '%masak%' THEN 15
            WHEN LOWER(instruction_text) LIKE '%goreng%' THEN 8
            WHEN LOWER(instruction_text) LIKE '%bakar%' THEN 20
            ELSE 10
        END
    
    -- Advanced steps
    WHEN step_number = 3 THEN
        CASE 
            WHEN LOWER(instruction_text) LIKE '%masak%' OR LOWER(instruction_text) LIKE '%rebus%' THEN 20
            WHEN LOWER(instruction_text) LIKE '%tumis%' OR LOWER(instruction_text) LIKE '%aduk%' THEN 7
            WHEN LOWER(instruction_text) LIKE '%panggang%' OR LOWER(instruction_text) LIKE '%oven%' THEN 25
            WHEN LOWER(instruction_text) LIKE '%goreng%' THEN 10
            ELSE 12
        END
    
    -- Finishing steps
    WHEN step_number = 4 THEN
        CASE 
            WHEN LOWER(instruction_text) LIKE '%sajikan%' OR LOWER(instruction_text) LIKE '%hidangkan%' THEN 2
            WHEN LOWER(instruction_text) LIKE '%matang%' OR LOWER(instruction_text) LIKE '%masak%' THEN 15
            WHEN LOWER(instruction_text) LIKE '%angkat%' OR LOWER(instruction_text) LIKE '%tiriskan%' THEN 1
            ELSE 8
        END
    
    -- Final steps (usually serving)
    WHEN step_number >= 5 THEN
        CASE 
            WHEN LOWER(instruction_text) LIKE '%sajikan%' OR LOWER(instruction_text) LIKE '%hidangkan%' THEN 2
            WHEN LOWER(instruction_text) LIKE '%dinginkan%' OR LOWER(instruction_text) LIKE '%diamkan%' THEN 30
            WHEN LOWER(instruction_text) LIKE '%hias%' OR LOWER(instruction_text) LIKE '%tabur%' THEN 3
            ELSE 5
        END
    
    ELSE 5 -- Default 5 minutes
END
WHERE timer_minutes IS NULL OR timer_minutes = 0;

-- Update for recipes that still don't have timer_minutes with sensible defaults
UPDATE recipe_instructions 
SET timer_minutes = CASE 
    WHEN step_number = 1 THEN 5
    WHEN step_number = 2 THEN 10
    WHEN step_number = 3 THEN 15
    WHEN step_number = 4 THEN 12
    WHEN step_number = 5 THEN 8
    WHEN step_number >= 6 THEN 5
    ELSE 5
END
WHERE timer_minutes IS NULL OR timer_minutes = 0;
