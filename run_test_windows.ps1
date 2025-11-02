# Run Appium server and Ruby test (Windows PowerShell)
# Requirements: Appium CLI in PATH (`npm i -g appium`), Ruby in PATH, device/emulator connected.

Write-Host "==> Starting Appium..."
$appiumOut = Join-Path $PSScriptRoot "appium.out.log"
$appiumErr = Join-Path $PSScriptRoot "appium.err.log"
$appiumArgs = "-a 127.0.0.1 -p 4723"

try {
  $null = Get-Command appium -ErrorAction Stop
} catch {
  throw "Appium not found in PATH. Install with 'npm i -g appium' and restart PowerShell."
}

# Lanzar via cmd.exe para soportar comandos .cmd/.ps1 y redirección nativa
$cmdLine = "/c appium $appiumArgs 1> `"$appiumOut`" 2> `"$appiumErr`""
$appiumProc = Start-Process -FilePath "cmd.exe" -ArgumentList $cmdLine -PassThru -WindowStyle Hidden

if (-not $appiumProc) { throw "Failed to start Appium. Ensure 'appium' is installed and in PATH." }
Write-Host "-> Appium started with PID $($appiumProc.Id)"

# Esperar a que Appium responda en /status
$ready = $false
$deadline = (Get-Date).AddSeconds(45)
while ((Get-Date) -lt $deadline) {
  try {
    $resp = Invoke-WebRequest -UseBasicParsing -Uri "http://127.0.0.1:4723/status" -TimeoutSec 2
    if ($resp.StatusCode -eq 200) { $ready = $true; break }
  } catch {}
  Start-Sleep -Milliseconds 500
}
if (-not $ready) {
  Write-Host "Appium did not become ready on 127.0.0.1:4723 within timeout. Last stdout/stderr lines:" -ForegroundColor Yellow
  if (Test-Path $appiumOut) { Write-Host "-- STDOUT (tail) --"; Get-Content $appiumOut -Tail 30 | ForEach-Object { Write-Host $_ } }
  if (Test-Path $appiumErr) { Write-Host "-- STDERR (tail) --"; Get-Content $appiumErr -Tail 30 | ForEach-Object { Write-Host $_ } }
  if ($appiumProc -and -not $appiumProc.HasExited) { Stop-Process -Id $appiumProc.Id -Force }
  throw "Appium not ready"
}

try {
  Write-Host "==> Running Ruby test..."
  $ruby = Get-Command ruby -ErrorAction SilentlyContinue
  if (-not $ruby) { throw "Ruby is not installed or not in PATH." }

  # Use bundler if available
  if (Test-Path .\Gemfile) {
    $bundle = Get-Command bundle -ErrorAction SilentlyContinue
    if ($bundle) {
      & bundle exec ruby .\mercadolibre_test.rb
    } else {
      ruby .\mercadolibre_test.rb
    }
  } else {
    ruby .\mercadolibre_test.rb
  }
}
finally {
  if ($appiumProc -and -not $appiumProc.HasExited) {
    Write-Host "==> Stopping Appium (PID $($appiumProc.Id))"
    Stop-Process -Id $appiumProc.Id -Force
  }
}
