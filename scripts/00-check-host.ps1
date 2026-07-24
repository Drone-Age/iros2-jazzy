$ErrorActionPreference = "Stop"

docker version
if ($LASTEXITCODE -ne 0) {
    throw "Docker Engine is not available. Start Docker Desktop."
}

docker buildx version
if ($LASTEXITCODE -ne 0) {
    throw "Docker Buildx is not available."
}

$builder = docker buildx inspect --bootstrap
if ($LASTEXITCODE -ne 0) {
    throw "Unable to inspect the active Buildx builder."
}

if (($builder -join "`n") -notmatch "linux/arm64") {
    throw "The active Buildx builder does not advertise linux/arm64."
}

Write-Host "Host check passed: linux/arm64 builds are available."
