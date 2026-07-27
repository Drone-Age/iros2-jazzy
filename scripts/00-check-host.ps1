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

$platforms = $builder -join "`n"
foreach ($platform in @("linux/amd64", "linux/arm64")) {
    if ($platforms -notmatch [regex]::Escape($platform)) {
        throw "The active Buildx builder does not advertise $platform."
    }
}

Write-Host "Host check passed: linux/amd64 and linux/arm64 builds are available."
