param(
    [string]$Version = (Get-Content -LiteralPath "VERSION" -Raw).Trim(),
    [string]$OutputDirectory = "artifacts"
)

$ErrorActionPreference = "Stop"
$buildDate = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
$vcsRef = (git rev-parse HEAD).Trim()

New-Item -ItemType Directory -Force -Path $OutputDirectory | Out-Null

docker buildx build `
    --platform linux/arm64 `
    --target artifact `
    --build-arg "IROS2_VERSION=$Version" `
    --build-arg "BUILD_DATE=$buildDate" `
    --build-arg "VCS_REF=$vcsRef" `
    --output "type=local,dest=$OutputDirectory" `
    --progress plain `
    .

if ($LASTEXITCODE -ne 0) {
    throw "IROS2_0 package build failed."
}

Get-ChildItem -LiteralPath $OutputDirectory
