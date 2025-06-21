# PowerShell script to run the recipe instructions timer seeder
# This script executes the SQL seeder file for timer_minutes

Write-Host "Starting Recipe Instructions Timer Seeder..." -ForegroundColor Green

# Check if Supabase CLI is available
try {
    $supabaseVersion = supabase --version
    Write-Host "Supabase CLI found: $supabaseVersion" -ForegroundColor Green
} catch {
    Write-Host "Error: Supabase CLI not found. Please install it first." -ForegroundColor Red
    Write-Host "Install with: npm install -g supabase" -ForegroundColor Yellow
    exit 1
}

# Check if SQL file exists
$sqlFile = "recipe_instructions_timer_seeder.sql"
if (-Not (Test-Path $sqlFile)) {
    Write-Host "Error: SQL file '$sqlFile' not found in current directory." -ForegroundColor Red
    exit 1
}

Write-Host "Found SQL file: $sqlFile" -ForegroundColor Green

# Execute the SQL file
try {
    Write-Host "Executing timer seeder SQL..." -ForegroundColor Yellow
    supabase db reset --db-url $env:SUPABASE_DB_URL --file $sqlFile
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Timer seeder executed successfully!" -ForegroundColor Green
    } else {
        throw "SQL execution failed with exit code $LASTEXITCODE"
    }
} catch {
    Write-Host "Error executing SQL: $_" -ForegroundColor Red
    Write-Host "Trying alternative method..." -ForegroundColor Yellow
    
    try {
        # Alternative: Use psql if available
        $content = Get-Content $sqlFile -Raw
        $content | supabase db sql
        Write-Host "Timer seeder executed successfully using alternative method!" -ForegroundColor Green
    } catch {
        Write-Host "Error: Could not execute SQL file. Please run manually." -ForegroundColor Red
        Write-Host "You can copy the SQL content and paste it directly in your database client." -ForegroundColor Yellow
        exit 1
    }
}

Write-Host "Recipe Instructions Timer Seeder completed!" -ForegroundColor Green
Write-Host "All recipe instructions should now have timer_minutes values." -ForegroundColor Cyan

# Optional: Show some results
try {
    Write-Host "`nSample results:" -ForegroundColor Cyan
    $sampleQuery = @"
SELECT 
    r.name as recipe_name,
    ri.step_number,
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
LIMIT 10;
"@
    
    $sampleQuery | supabase db sql
} catch {
    Write-Host "Could not fetch sample results, but seeder should be complete." -ForegroundColor Yellow
}
