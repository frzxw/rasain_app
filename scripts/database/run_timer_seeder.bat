@echo off
echo Starting Recipe Instructions Timer Seeder...

REM Check if Supabase CLI is available
supabase --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Error: Supabase CLI not found. Please install it first.
    echo Install with: npm install -g supabase
    exit /b 1
)

echo Supabase CLI found.

REM Check if SQL file exists
if not exist "recipe_instructions_timer_seeder.sql" (
    echo Error: SQL file 'recipe_instructions_timer_seeder.sql' not found in current directory.
    exit /b 1
)

echo Found SQL file: recipe_instructions_timer_seeder.sql

REM Execute the SQL file
echo Executing timer seeder SQL...
supabase db sql --file recipe_instructions_timer_seeder.sql

if %errorlevel% equ 0 (
    echo Timer seeder executed successfully!
) else (
    echo Error executing SQL file. Please check your database connection.
    exit /b 1
)

echo Recipe Instructions Timer Seeder completed!
echo All recipe instructions should now have timer_minutes values.
pause
