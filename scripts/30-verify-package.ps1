param(
    [string]$ArtifactDirectory = "artifacts"
)

$ErrorActionPreference = "Stop"
$artifactPath = (Resolve-Path -LiteralPath $ArtifactDirectory).Path
$packages = @(Get-ChildItem -LiteralPath $artifactPath -Filter "*.deb")

if ($packages.Count -ne 1) {
    throw "Expected exactly one DEB package in $artifactPath."
}

Push-Location $artifactPath
try {
    $expected = (Get-Content SHA256SUMS -Raw).Split(" ")[0].Trim()
    $actual = (Get-FileHash -Algorithm SHA256 $packages[0].FullName).Hash.ToLowerInvariant()
    if ($expected -ne $actual) {
        throw "SHA-256 verification failed."
    }
}
finally {
    Pop-Location
}

docker run --rm `
    --platform linux/arm64 `
    --mount "type=bind,source=$artifactPath,target=/artifacts,readonly" `
    debian:trixie-slim `
    bash -lc "apt-get update && apt-get install -y /artifacts/*.deb && source /opt/iros2/jazzy/setup.bash && test `$ROS_DISTRO = jazzy && ros2 --help >/dev/null"

if ($LASTEXITCODE -ne 0) {
    throw "Package installation or ROS 2 smoke-test failed."
}

Write-Host "Package checksum, installation and ROS 2 smoke-test passed."
