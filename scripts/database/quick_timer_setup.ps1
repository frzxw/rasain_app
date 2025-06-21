# Simple PowerShell script untuk copy SQL ke clipboard dan buka browser
# Tidak menggunakan && operator, hanya PowerShell native commands

Write-Host ""
Write-Host "🍳 RECIPE TIMER SEEDER - BROWSER METHOD" -ForegroundColor Green
Write-Host "=======================================" -ForegroundColor Green
Write-Host ""

# Step 1: Check if SQL file exists
Write-Host "Step 1: Checking SQL file..." -ForegroundColor Cyan
if (Test-Path "simple_timer_seeder.sql") {
    Write-Host "✅ Found: simple_timer_seeder.sql" -ForegroundColor Green
} else {
    Write-Host "❌ Error: simple_timer_seeder.sql not found!" -ForegroundColor Red
    Write-Host "Make sure you're in the correct directory." -ForegroundColor Yellow
    exit
}

Write-Host ""

# Step 2: Copy SQL to clipboard
Write-Host "Step 2: Copying SQL to clipboard..." -ForegroundColor Cyan
try {
    $sqlContent = Get-Content "simple_timer_seeder.sql" -Raw
    $sqlContent | Set-Clipboard
    Write-Host "✅ SQL copied to clipboard successfully!" -ForegroundColor Green
} catch {
    Write-Host "⚠️  Could not copy to clipboard. Will show content for manual copy." -ForegroundColor Yellow
    $manualCopy = $true
}

Write-Host ""

# Step 3: Open browser
Write-Host "Step 3: Opening browser..." -ForegroundColor Cyan
try {
    # Try to open with Chrome first
    $chrome = Get-Command chrome -ErrorAction SilentlyContinue
    if ($chrome) {
        Start-Process chrome "https://supabase.com/dashboard"
        Write-Host "✅ Opened Chrome browser" -ForegroundColor Green
    } else {
        # Fallback to default browser
        Start-Process "https://supabase.com/dashboard"
        Write-Host "✅ Opened default browser" -ForegroundColor Green
    }
} catch {
    Write-Host "⚠️  Could not open browser automatically" -ForegroundColor Yellow
    Write-Host "Please manually go to: https://supabase.com/dashboard" -ForegroundColor White
}

Write-Host ""

# Step 4: Show instructions
Write-Host "Step 4: Follow these instructions:" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor White
Write-Host ""
Write-Host "1. Login to your Supabase dashboard" -ForegroundColor White
Write-Host "2. Select your project (rasain-database)" -ForegroundColor White
Write-Host "3. Click 'SQL Editor' in the left menu" -ForegroundColor White
Write-Host "4. Paste the SQL (Ctrl+V) - already in clipboard!" -ForegroundColor White
Write-Host "5. Click 'Run' button to execute" -ForegroundColor White
Write-Host ""

# Step 5: Show verification
Write-Host "Step 5: Verify with this query:" -ForegroundColor Cyan
Write-Host "==============================" -ForegroundColor White
Write-Host ""
Write-Host "SELECT COUNT(*) as total," -ForegroundColor Yellow
Write-Host "       COUNT(CASE WHEN timer_minutes > 0 THEN 1 END) as with_timer" -ForegroundColor Yellow
Write-Host "FROM recipe_instructions;" -ForegroundColor Yellow
Write-Host ""

# Show manual copy if clipboard failed
if ($manualCopy -eq $true) {
    Write-Host "MANUAL COPY - SQL CONTENT:" -ForegroundColor Red
    Write-Host "=========================" -ForegroundColor Red
    Write-Host ""
    Write-Host $sqlContent -ForegroundColor White
    Write-Host ""
    Write-Host "=========================" -ForegroundColor Red
    Write-Host ""
}

Write-Host "✅ Setup complete! Your recipe app will have cooking timers after running the SQL." -ForegroundColor Green
Write-Host ""
Write-Host "Press Enter to close..." -ForegroundColor Gray
Read-Host
