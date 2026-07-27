param(
    [string]$Version = (Get-Content -LiteralPath "VERSION" -Raw).Trim(),
    [string]$Repository = "Drone-Age/iros2_0",
    [string]$ArtifactsDirectory = "artifacts",
    [string]$Commit = "HEAD"
)

$ErrorActionPreference = "Stop"
$tag = "v2.$Version"
$manifestPath = "manifests/iros2j-$Version.json"
$notesPath = "docs/releases/$tag.md"
$lockPath = "manifests/iros2j-jazzy.lock.repos"
$resolvedCommit = (git rev-parse "$Commit^{commit}").Trim()

if ($LASTEXITCODE -ne 0 -or $resolvedCommit -notmatch "^[0-9a-f]{40}$") {
    throw "Cannot resolve release commit: $Commit"
}
if ((git status --porcelain --untracked-files=no)) {
    throw "Tracked working tree changes must be committed before publication."
}

python scripts/release/metadata_gate.py $manifestPath
if ($LASTEXITCODE -ne 0) {
    throw "Release metadata gate failed."
}
python scripts/release/verify-native-gate.py `
    --gate (Join-Path $ArtifactsDirectory "native-gate.json") `
    --manifest $manifestPath `
    --artifacts $ArtifactsDirectory `
    --commit $resolvedCommit
if ($LASTEXITCODE -ne 0) {
    throw "Native gate evidence does not match the release."
}
$manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
if ($manifest.release.status -ne "released") {
    throw "Manifest status must be released before publication."
}
if ($manifest.release.tag -ne $tag) {
    throw "Manifest tag does not match $tag."
}

$assetNames = @(
    "iros2j-apt_trixie_arm64.tar.gz",
    "iros2j-apt_trixie_arm64.tar.gz.sha256",
    "SHA256SUMS",
    "package-inventory.json",
    "iros2j-$Version.spdx.json",
    "native-gate.json"
)
$assetPaths = foreach ($name in $assetNames) {
    $path = Join-Path $ArtifactsDirectory $name
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "Required release asset is missing: $path"
    }
    (Resolve-Path -LiteralPath $path).Path
}
$assetPaths += (Resolve-Path -LiteralPath $manifestPath).Path
$assetPaths += (Resolve-Path -LiteralPath $lockPath).Path

$checksumPath = Join-Path $ArtifactsDirectory "iros2j-apt_trixie_arm64.tar.gz.sha256"
$expectedHash = (
    Get-Content -LiteralPath $checksumPath -Raw
).Split(" ", [System.StringSplitOptions]::RemoveEmptyEntries)[0].ToLowerInvariant()
$actualHash = (
    Get-FileHash -Algorithm SHA256 -LiteralPath (
        Join-Path $ArtifactsDirectory "iros2j-apt_trixie_arm64.tar.gz"
    )
).Hash.ToLowerInvariant()
if ($actualHash -ne $expectedHash) {
    throw "APT repository archive checksum mismatch."
}

gh auth status
if ($LASTEXITCODE -ne 0) {
    throw "GitHub CLI is not authenticated."
}
$previousErrorActionPreference = $ErrorActionPreference
$ErrorActionPreference = "Continue"
gh release view $tag --repo $Repository *> $null
$releaseExists = $LASTEXITCODE -eq 0
git ls-remote --exit-code --tags origin "refs/tags/$tag" *> $null
$tagExists = $LASTEXITCODE -eq 0
$ErrorActionPreference = $previousErrorActionPreference
if ($releaseExists) {
    throw "Release $tag already exists."
}
if ($tagExists) {
    throw "Tag $tag already exists on origin."
}

gh release create $tag @assetPaths `
    --repo $Repository `
    --target $resolvedCommit `
    --title "iros2j $Version for Debian 13 ARM64" `
    --notes-file $notesPath `
    --latest
if ($LASTEXITCODE -ne 0) {
    throw "GitHub Release creation failed."
}

Write-Host "Published https://github.com/$Repository/releases/tag/$tag"
