# PowerShell script to display SQL for manual execution
# Since Supabase CLI is not available, this will show you the SQL to copy

Write-Host "=======================================" -ForegroundColor Cyan
Write-Host "RECIPE TIMER SEEDER - MANUAL EXECUTION" -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Since Supabase CLI is not installed, please follow these steps:" -ForegroundColor Yellow
Write-Host ""

Write-Host "OPTION 1: Use the Simple Seeder (Recommended)" -ForegroundColor Green
Write-Host "1. Open your database interface (the one shown in your screenshot)" -ForegroundColor White
Write-Host "2. Go to the SQL Editor or Query tab" -ForegroundColor White
Write-Host "3. Copy and paste the content from: simple_timer_seeder.sql" -ForegroundColor White
Write-Host "4. Execute the SQL" -ForegroundColor White
Write-Host ""

Write-Host "OPTION 2: Use the Full Seeder" -ForegroundColor Green  
Write-Host "1. Open your database interface" -ForegroundColor White
Write-Host "2. Copy and paste the content from: recipe_instructions_timer_seeder.sql" -ForegroundColor White
Write-Host "3. Execute the SQL" -ForegroundColor White
Write-Host ""

Write-Host "OPTION 3: Install Supabase CLI (for future use)" -ForegroundColor Green
Write-Host "Run this command to install Supabase CLI:" -ForegroundColor White
Write-Host "npm install -g supabase" -ForegroundColor Cyan
Write-Host ""

# Check if files exist and show their content
$simpleFile = "simple_timer_seeder.sql"
$fullFile = "recipe_instructions_timer_seeder.sql"

if (Test-Path $simpleFile) {
    Write-Host "✅ Simple seeder file found: $simpleFile" -ForegroundColor Green
    $lines = (Get-Content $simpleFile).Count
    Write-Host "   File has $lines lines" -ForegroundColor Gray
} else {
    Write-Host "❌ Simple seeder file not found: $simpleFile" -ForegroundColor Red
}

if (Test-Path $fullFile) {
    Write-Host "✅ Full seeder file found: $fullFile" -ForegroundColor Green
    $lines = (Get-Content $fullFile).Count
    Write-Host "   File has $lines lines" -ForegroundColor Gray
} else {
    Write-Host "❌ Full seeder file not found: $fullFile" -ForegroundColor Red
}

Write-Host ""
Write-Host "VERIFICATION QUERY:" -ForegroundColor Magenta
Write-Host "After running the seeder, use this query to verify results:" -ForegroundColor White
Write-Host ""
Write-Host "SELECT COUNT(*) as total_instructions, " -ForegroundColor Cyan
Write-Host "       COUNT(CASE WHEN timer_minutes IS NOT NULL AND timer_minutes > 0 THEN 1 END) as with_timer," -ForegroundColor Cyan
Write-Host "       AVG(timer_minutes) as avg_timer_minutes" -ForegroundColor Cyan
Write-Host "FROM recipe_instructions;" -ForegroundColor Cyan
Write-Host ""

Write-Host "SAMPLE DATA QUERY:" -ForegroundColor Magenta
Write-Host "SELECT r.name, ri.step_number, ri.instruction_text, ri.timer_minutes" -ForegroundColor Cyan
Write-Host "FROM recipes r" -ForegroundColor Cyan
Write-Host "JOIN recipe_instructions ri ON r.id = ri.recipe_id" -ForegroundColor Cyan
Write-Host "ORDER BY r.name, ri.step_number" -ForegroundColor Cyan
Write-Host "LIMIT 10;" -ForegroundColor Cyan
Write-Host ""

Write-Host "=======================================" -ForegroundColor Cyan
Write-Host "Ready to proceed with manual execution!" -ForegroundColor Green
Write-Host "=======================================" -ForegroundColor Cyan
