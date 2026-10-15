# Windows PowerShell launcher for Linux containers in Docker Desktop.
param(
    [Parameter(Mandatory=$true)]
    [ValidatePattern('^(0?[1-9]|10)$')]
    [string]$Lab
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$captures = Join-Path $PSScriptRoot 'captures'
New-Item -Path $captures -ItemType Directory -Force | Out-Null
& docker image inspect 'wireshark-node-labs:isolated' *> $null
if ($LASTEXITCODE -ne 0) {
    throw 'Build the image first: docker build -t wireshark-node-labs:isolated .'
}
& docker run --rm --network none --cap-drop ALL --cap-add NET_RAW --security-opt no-new-privileges --read-only --tmpfs "/tmp:rw,nosuid,nodev,size=64m" --pids-limit 64 --mount "type=bind,source=$captures,target=/captures" wireshark-node-labs:isolated $Lab
if ($LASTEXITCODE -ne 0) { throw "Isolated lab $Lab failed." }
