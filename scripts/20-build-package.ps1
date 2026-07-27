param(
    [string]$Version = (Get-Content -LiteralPath "VERSION" -Raw).Trim(),
    [string]$OutputDirectory = "artifacts",
    [ValidateSet("amd64", "arm64")]
    # Release order is intentional: native Windows-host architecture first.
    [string[]]$Architectures = @("amd64", "arm64")
)

$ErrorActionPreference = "Stop"
$buildDate = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
$vcsRef = (git rev-parse HEAD).Trim()

function Remove-BuildOutput {
    param([Parameter(Mandatory)][string]$Path)

    for ($attempt = 1; $attempt -le 10; $attempt++) {
        try {
            Remove-Item -LiteralPath $Path -Recurse -Force -ErrorAction Stop
            return
        }
        catch {
            if ($attempt -eq 10) {
                Write-Warning "Temporary build output remains locked and was kept: $Path"
                return
            }
            Start-Sleep -Seconds 1
        }
    }
}

New-Item -ItemType Directory -Force -Path $OutputDirectory | Out-Null

$releaseArchitectureOrder = @("amd64", "arm64")
$selectedArchitectures = $releaseArchitectureOrder |
    Where-Object { $Architectures -contains $_ }

foreach ($architecture in $selectedArchitectures) {
    Write-Host "Building release architecture: $architecture"
    $architectureOutput = Join-Path $OutputDirectory ".build-$architecture-$PID"
    New-Item -ItemType Directory -Force -Path $architectureOutput | Out-Null

    docker buildx build `
        --platform "linux/$architecture" `
        --target artifact `
        --build-arg "IROS2_VERSION=$Version" `
        --build-arg "BUILD_DATE=$buildDate" `
        --build-arg "VCS_REF=$vcsRef" `
        --output "type=local,dest=$architectureOutput" `
        --progress plain `
        .

    if ($LASTEXITCODE -ne 0) {
        throw "IROS2_0 $architecture package build failed."
    }

    Get-ChildItem -LiteralPath $architectureOutput -Filter "*.deb" |
        Copy-Item -Destination $OutputDirectory -Force
    Get-ChildItem -LiteralPath $architectureOutput -Filter "*.deb.sha256" |
        Copy-Item -Destination $OutputDirectory -Force
    Remove-BuildOutput -Path $architectureOutput
}

$debFiles = Get-ChildItem -LiteralPath $OutputDirectory -Filter "*.deb" |
    Sort-Object Name
$checksumLines = foreach ($deb in $debFiles) {
    $hash = (Get-FileHash -Algorithm SHA256 -LiteralPath $deb.FullName).Hash.ToLowerInvariant()
    "$hash  $($deb.Name)"
}
Set-Content -LiteralPath (Join-Path $OutputDirectory "SHA256SUMS") `
    -Value $checksumLines -Encoding ascii

Get-ChildItem -LiteralPath $OutputDirectory
