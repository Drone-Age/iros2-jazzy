param(
    [string]$Version = (Get-Content -LiteralPath "VERSION" -Raw).Trim(),
    [string]$Repository = "Drone-Age/iros2_0",
    [string]$ArtifactsDirectory = "artifacts"
)

$ErrorActionPreference = "Stop"
$tag = "v$Version"
$packageVersion = "$Version-1+deb13"
# Release order is fixed: publish AMD64 first, then ARM64.
$architectures = @("amd64", "arm64")
$assetNames = @()
foreach ($architecture in $architectures) {
    $assetNames += "iros2-0_${packageVersion}_${architecture}.deb"
    $assetNames += "iros2-0_latest_${architecture}.deb"
    $assetNames += "iros2-0_latest_${architecture}.deb.sha256"
}
$assetNames += "SHA256SUMS"

$assetPaths = foreach ($name in $assetNames) {
    $path = Join-Path $ArtifactsDirectory $name
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "Required release asset is missing: $path"
    }
    (Resolve-Path -LiteralPath $path).Path
}

foreach ($architecture in $architectures) {
    Write-Host "Validating release architecture: $architecture"
    $stableAsset = "iros2-0_latest_${architecture}.deb"
    $stableChecksum = "${stableAsset}.sha256"
    $expectedHash = (
        Get-Content -LiteralPath (Join-Path $ArtifactsDirectory $stableChecksum) -Raw
    ).Split(" ", [System.StringSplitOptions]::RemoveEmptyEntries)[0]
    $actualHash = (
        Get-FileHash -Algorithm SHA256 -LiteralPath (
            Join-Path $ArtifactsDirectory $stableAsset
        )
    ).Hash.ToLowerInvariant()

    if ($actualHash -ne $expectedHash.ToLowerInvariant()) {
        throw "$architecture stable asset checksum mismatch."
    }
}

$ghCandidates = @(
    "C:\Program Files\GitHub CLI\gh.exe",
    (Join-Path $env:LOCALAPPDATA "Programs\GitHub CLI\gh.exe"),
    (Join-Path $env:LOCALAPPDATA "Microsoft\WinGet\Links\gh.exe")
)
$gh = $ghCandidates |
    Where-Object { Test-Path -LiteralPath $_ } |
    Select-Object -First 1
if (-not $gh) {
    throw "GitHub CLI was not found."
}

& $gh auth status
if ($LASTEXITCODE -ne 0) {
    throw "GitHub CLI is not authenticated."
}

$previousErrorActionPreference = $ErrorActionPreference
$ErrorActionPreference = "SilentlyContinue"
& $gh release view $tag --repo $Repository *> $null
$releaseViewExitCode = $LASTEXITCODE
$ErrorActionPreference = $previousErrorActionPreference
if ($releaseViewExitCode -eq 0) {
    throw "Release $tag already exists."
}

$notes = @"
## IROS2_0 $tag

Debian 13 release built and published in this order:
1. AMD64 systems.
2. ARM64 devices such as Raspberry Pi 5.

Assets include versioned Debian packages for both architectures, stable
latest-download aliases, and SHA-256 checksums.
"@

& $gh release create $tag @assetPaths `
    --repo $Repository `
    --target main `
    --title "IROS2_0 $tag" `
    --notes $notes `
    --latest
if ($LASTEXITCODE -ne 0) {
    throw "GitHub Release creation failed."
}

Write-Host "Published https://github.com/$Repository/releases/tag/$tag"
