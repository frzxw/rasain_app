# PowerShell script untuk membuka SQL seeder di browser
# Script ini akan membuka database dashboard dan menyediakan SQL untuk copy-paste

Write-Host "🚀 Opening Database Dashboard for SQL Seeder..." -ForegroundColor Green
Write-Host ""

# Detect Chrome installation
$chromePaths = @(
    "$env:ProgramFiles\Google\Chrome\Application\chrome.exe",
    "$env:ProgramFiles(x86)\Google\Chrome\Application\chrome.exe",
    "$env:LocalAppData\Google\Chrome\Application\chrome.exe"
)

$chromeExe = $null
foreach ($path in $chromePaths) {
    if (Test-Path $path) {
        $chromeExe = $path
        break
    }
}

if ($chromeExe) {
    Write-Host "✅ Chrome found at: $chromeExe" -ForegroundColor Green
    
    # Open Supabase dashboard (adjust URL as needed)
    Write-Host "🌐 Opening Supabase dashboard..." -ForegroundColor Yellow
    Start-Process $chromeExe "https://supabase.com/dashboard"
    
    Start-Sleep -Seconds 2
    
    Write-Host ""
    Write-Host "📋 COPY THE SQL BELOW AND PASTE IN YOUR DATABASE SQL EDITOR:" -ForegroundColor Cyan
    Write-Host "=" * 60 -ForegroundColor Gray
    
} else {
    Write-Host "⚠️  Chrome not found. Opening with default browser..." -ForegroundColor Yellow
    Start-Process "https://supabase.com/dashboard"
}

Write-Host ""
Write-Host "🔍 Looking for SQL seeder file..." -ForegroundColor Yellow

$sqlFile = "simple_timer_seeder.sql"
if (Test-Path $sqlFile) {
    Write-Host "✅ Found: $sqlFile" -ForegroundColor Green
    
    # Read and display SQL content
    $sqlContent = Get-Content $sqlFile -Raw
    
    Write-Host ""
    Write-Host "📄 SQL CONTENT TO COPY:" -ForegroundColor Magenta
    Write-Host "=" * 60 -ForegroundColor Gray
    Write-Host $sqlContent -ForegroundColor White
    Write-Host "=" * 60 -ForegroundColor Gray
    
    # Copy to clipboard if possible
    try {
        $sqlContent | Set-Clipboard
        Write-Host ""
        Write-Host "✅ SQL copied to clipboard! Just paste (Ctrl+V) in your database editor." -ForegroundColor Green
    } catch {
        Write-Host ""
        Write-Host "ℹ️  Please manually copy the SQL above." -ForegroundColor Yellow
    }
    
} else {
    Write-Host "❌ SQL file not found: $sqlFile" -ForegroundColor Red
    Write-Host "Please make sure you're in the correct directory." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "📝 STEPS TO EXECUTE:" -ForegroundColor Cyan
Write-Host "1. Go to your Supabase project dashboard" -ForegroundColor White
Write-Host "2. Click on 'SQL Editor' in the left sidebar" -ForegroundColor White
Write-Host "3. Paste the SQL content above" -ForegroundColor White
Write-Host "4. Click 'Run' to execute the seeder" -ForegroundColor White
Write-Host "5. Verify results with sample queries" -ForegroundColor White

Write-Host ""
Write-Host "🔍 VERIFICATION QUERY:" -ForegroundColor Magenta
Write-Host "SELECT COUNT(*) as total_instructions," -ForegroundColor Cyan
Write-Host "       COUNT(CASE WHEN timer_minutes > 0 THEN 1 END) as with_timer" -ForegroundColor Cyan
Write-Host "FROM recipe_instructions;" -ForegroundColor Cyan

Write-Host ""
Write-Host "🎉 Ready to populate your recipe timers!" -ForegroundColor Green
Write-Host ""

# Keep window open
Write-Host "Press any key to close..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
