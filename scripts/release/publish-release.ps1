param(
    [string]$Version = (Get-Content -LiteralPath "VERSION" -Raw).Trim(),
    [string]$Repository = "Drone-Age/iros2_0",
    [string]$ArtifactsDirectory = "artifacts"
)

$ErrorActionPreference = "Stop"
$tag = "v$Version"
$packageVersion = "$Version-1+deb13"
$versionedAsset = "iros2-0_${packageVersion}_arm64.deb"
$stableAsset = "iros2-0_latest_arm64.deb"
$stableChecksum = "${stableAsset}.sha256"
$assetNames = @(
    $versionedAsset,
    $stableAsset,
    $stableChecksum,
    "SHA256SUMS"
)

$assetPaths = foreach ($name in $assetNames) {
    $path = Join-Path $ArtifactsDirectory $name
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "Required release asset is missing: $path"
    }
    (Resolve-Path -LiteralPath $path).Path
}

$expectedHash = (
    Get-Content -LiteralPath (Join-Path $ArtifactsDirectory $stableChecksum) -Raw
).Split(" ", [System.StringSplitOptions]::RemoveEmptyEntries)[0]
$actualHash = (
    Get-FileHash -Algorithm SHA256 -LiteralPath (
        Join-Path $ArtifactsDirectory $stableAsset
    )
).Hash.ToLowerInvariant()

if ($actualHash -ne $expectedHash.ToLowerInvariant()) {
    throw "Stable asset checksum mismatch."
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

& $gh release view $tag --repo $Repository *> $null
if ($LASTEXITCODE -eq 0) {
    throw "Release $tag already exists."
}

$notes = @"
## IROS2_0 $tag

Native Debian 13 ARM64 release for Raspberry Pi 5.

Assets include the versioned Debian package, a stable latest-download alias,
and SHA-256 checksums.
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
