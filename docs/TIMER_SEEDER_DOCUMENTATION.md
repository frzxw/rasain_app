# Recipe Instructions Timer Seeder Documentation

This document explains how to run the SQL seeder to populate the `timer_minutes` column in the `recipe_instructions` table.

## Prerequisites

1. **Supabase CLI** installed and configured
   ```powershell
   npm install -g supabase
   ```

2. **Database connection** configured
   - Either logged in via `supabase login`
   - Or have `SUPABASE_DB_URL` environment variable set

## Files

- `recipe_instructions_timer_seeder.sql` - The main SQL script
- `run_timer_seeder.ps1` - PowerShell execution script
- `run_timer_seeder.bat` - Batch file for cmd users

## Running the Seeder

### Option 1: PowerShell Script (Recommended for Windows)

```powershell
# Navigate to the project directory
cd "d:\KULIAH\SEMESTER 4\provis\tugas 3\rasain_app"

# Run the PowerShell script
.\run_timer_seeder.ps1
```

### Option 2: Batch File (cmd)

```cmd
# Navigate to the project directory
cd "d:\KULIAH\SEMESTER 4\provis\tugas 3\rasain_app"

# Run the batch file
run_timer_seeder.bat
```

### Option 3: Direct SQL Execution

```powershell
# Using Supabase CLI
supabase db sql --file recipe_instructions_timer_seeder.sql

# Or pipe the content
Get-Content recipe_instructions_timer_seeder.sql | supabase db sql
```

### Option 4: Manual Execution

1. Copy the content of `recipe_instructions_timer_seeder.sql`
2. Paste it into your database client (pgAdmin, DBeaver, etc.)
3. Execute the script

## What the Seeder Does

1. **Updates existing instructions** with realistic timer values based on:
   - Step number (prep steps are shorter)
   - Description keywords (cooking methods)
   - Recipe type

2. **Specific timing for popular Indonesian dishes**:
   - Sate Ayam: 10-20 minutes per step
   - Nasi Goreng: 3-10 minutes per step  
   - Rendang: 15-60 minutes per step
   - Gado-gado: 2-10 minutes per step
   - Soto Ayam: 3-60 minutes per step
   - And more...

3. **Default fallback values** for any remaining null timer_minutes

4. **Sample data insertion** for testing purposes

## Timer Categories

- **Quick** (≤5 minutes): Prep work, serving
- **Medium** (6-15 minutes): Basic cooking, sautéing
- **Long** (16-30 minutes): Grilling, boiling
- **Very Long** (>30 minutes): Slow cooking, braising

## Verification

After running the seeder, verify the results:

```sql
SELECT 
    r.name as recipe_name,
    ri.step_number,
    ri.description,
    ri.timer_minutes,
    CASE 
        WHEN ri.timer_minutes <= 5 THEN 'Quick'
        WHEN ri.timer_minutes <= 15 THEN 'Medium' 
        WHEN ri.timer_minutes <= 30 THEN 'Long'
        ELSE 'Very Long'
    END as duration_category
FROM recipes r
JOIN recipe_instructions ri ON r.id = ri.recipe_id
ORDER BY r.name, ri.step_number
LIMIT 20;
```

## Troubleshooting

### "Supabase CLI not found"
Install Supabase CLI:
```powershell
npm install -g supabase
```

### "Permission denied" on PowerShell
Enable script execution:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### "Database connection failed"
Ensure you're logged in:
```powershell
supabase login
```

Or set your database URL:
```powershell
$env:SUPABASE_DB_URL = "your-database-url"
```

### "SQL file not found"
Make sure you're in the correct directory and the file exists:
```powershell
Get-Location
Test-Path "recipe_instructions_timer_seeder.sql"
```

## Integration with Flutter App

After running the seeder, the Flutter app will automatically:

1. **Display timers** in the ModernInstructionSteps widget
2. **Show cooking mode** with step-by-step timers
3. **Format duration** properly (e.g., "15 min", "1h 30min")

The timer data flows through:
```
Database → RecipeService → Recipe Model → ModernRecipeDetailScreen → ModernInstructionSteps Widget
```

## Notes

- The seeder is **safe to run multiple times** (uses UPDATE statements)
- Existing timer_minutes values won't be overwritten unless they're NULL or 0
- The INSERT statement uses `ON CONFLICT` to prevent duplicates
- All times are in minutes and based on realistic cooking scenarios
