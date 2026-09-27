[CmdletBinding(SupportsShouldProcess)]
param(
    [ValidateSet('enfos', 'enfos_sametc')]
    [string]$Map = 'enfos',
    [string]$DotaRoot = 'C:/Program Files (x86)/Steam/steamapps/common/dota 2 beta'
)

$ErrorActionPreference = 'Stop'
$dotaBin = Join-Path $DotaRoot 'game/bin/win64'
$dotaExe = Join-Path $dotaBin 'dota2.exe'
if (-not (Test-Path -LiteralPath $dotaExe)) { throw "Dota executable not found: $dotaExe" }
if (Get-Process dota2 -ErrorAction SilentlyContinue) {
    throw 'Dota is already running. Use its console to reload the local test; do not launch a second instance.'
}
& node (Join-Path $PSScriptRoot 'check_map.mjs')
if ($LASTEXITCODE -ne 0) { throw 'Map integrity check failed; test launch cancelled.' }
$testArgs = @(
    '-novid', '-tools', '-addon', 'enfos_sametc', '-console', '-condebug',
    '-insecure', '-dev', '-uidev', '-vconport', '29000',
    '+sv_cheats', '1', '+developer', '1',
    '+dota_launch_custom_game', 'enfos_sametc', $Map
)
# Run from a normal user terminal. A restricted agent sandbox can deny NVIDIA
# profile access (NVAPI_ACCESS_DENIED). No driver/profile/ACL changes are needed.
if ($PSCmdlet.ShouldProcess($dotaExe, "Launch local enfos_sametc test on $Map")) {
    $testProcess = Start-Process -FilePath $dotaExe -WorkingDirectory $dotaBin `
        -ArgumentList $testArgs -WindowStyle Hidden -PassThru
    Write-Output "Started local test: PID $($testProcess.Id), map $Map, VConsole 29000."
}
