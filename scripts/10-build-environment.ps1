param(
    [ValidateSet("amd64", "arm64")]
    [string]$Architecture = "amd64"
)

$ErrorActionPreference = "Stop"
docker buildx build `
    --platform "linux/$Architecture" `
    --target environment `
    --tag "iros2-0:build-environment-$Architecture" `
    --load `
    .

if ($LASTEXITCODE -ne 0) {
    throw "IROS2_0 build environment failed."
}
