$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$backendDir = Join-Path $root 'backend'

$backend = Start-Process `
  -FilePath 'dart' `
  -ArgumentList @('run', 'bin/server.dart') `
  -WorkingDirectory $backendDir `
  -PassThru `
  -WindowStyle Hidden

try {
  Start-Sleep -Seconds 2
  flutter run -d web-server --web-hostname 127.0.0.1 --web-port 8080
} finally {
  if ($backend -and -not $backend.HasExited) {
    Stop-Process -Id $backend.Id
  }
}
