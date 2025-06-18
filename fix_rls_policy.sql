-- 1. Check existing RLS settings
SELECT 
  tablename, 
  rowsecurity
FROM pg_tables 
WHERE tablename IN ('recipes', 'recipe_instructions', 'recipe_ingredients');

-- 2. First disable RLS temporarily to diagnose issues
ALTER TABLE public.recipe_instructions DISABLE ROW LEVEL SECURITY;

-- 3. Drop policy if it exists (to avoid conflicts)
DROP POLICY IF EXISTS "Allow public read access for recipe_instructions" ON public.recipe_instructions;

-- 4. Create a simple but effective policy
CREATE POLICY "Allow public read access for recipe_instructions" 
   ON public.recipe_instructions
   FOR SELECT
   USING (true);
   
-- 5. Re-enable RLS with our new policy
ALTER TABLE public.recipe_instructions ENABLE ROW LEVEL SECURITY;

-- 6. Grant permissions to the anonymous role
GRANT SELECT ON TABLE public.recipe_instructions TO anon;
GRANT SELECT ON TABLE public.recipe_instructions TO authenticated;

-- 7. Check resulting policies
SELECT tablename, policyname, permissive, roles, cmd 
FROM pg_policies 
WHERE tablename = 'recipe_instructions';
