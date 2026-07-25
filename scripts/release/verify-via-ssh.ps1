$ErrorActionPreference = "Stop"

function Require-Environment([string]$Name) {
    $value = [Environment]::GetEnvironmentVariable($Name)
    if ([string]::IsNullOrWhiteSpace($value)) {
        throw "Environment variable $Name is required."
    }
    return $value
}

function Assert-SafeValue([string]$Name, [string]$Value) {
    if ($Value -notmatch '^[A-Za-z0-9._/+:-]+$') {
        throw "$Name contains unsupported characters."
    }
}

$hostName = Require-Environment "IROS2_SSH_HOST"
$sshUser = [Environment]::GetEnvironmentVariable("IROS2_SSH_USER")
$sshPort = [Environment]::GetEnvironmentVariable("IROS2_SSH_PORT")
$sshKey = [Environment]::GetEnvironmentVariable("IROS2_SSH_KEY")
$releaseTag = Require-Environment "IROS2_RELEASE_TAG"
$githubRepo = [Environment]::GetEnvironmentVariable("IROS2_GITHUB_REPO")
$packageVersion = [Environment]::GetEnvironmentVariable("IROS2_PACKAGE_VERSION")

if ([string]::IsNullOrWhiteSpace($sshUser)) { $sshUser = "rpi" }
if ([string]::IsNullOrWhiteSpace($sshPort)) { $sshPort = "22" }
if ([string]::IsNullOrWhiteSpace($githubRepo)) {
    $githubRepo = "Drone-Age/iros2_0"
}
if ([string]::IsNullOrWhiteSpace($packageVersion)) {
    $packageVersion = $releaseTag.TrimStart("v") + "-1+deb13"
}

Assert-SafeValue "IROS2_SSH_HOST" $hostName
Assert-SafeValue "IROS2_SSH_USER" $sshUser
Assert-SafeValue "IROS2_SSH_PORT" $sshPort
Assert-SafeValue "IROS2_RELEASE_TAG" $releaseTag
Assert-SafeValue "IROS2_GITHUB_REPO" $githubRepo
Assert-SafeValue "IROS2_PACKAGE_VERSION" $packageVersion

$target = "${sshUser}@${hostName}"
$sshOptions = @("-o", "BatchMode=yes", "-p", $sshPort)
$scpOptions = @("-o", "BatchMode=yes", "-P", $sshPort)
if (-not [string]::IsNullOrWhiteSpace($sshKey)) {
    $resolvedKey = (Resolve-Path -LiteralPath $sshKey).Path
    $sshOptions += @("-i", $resolvedKey)
    $scpOptions += @("-i", $resolvedKey)
}

$nativeScript = Join-Path $PSScriptRoot "verify-native.sh"
& scp @scpOptions $nativeScript "${target}:/tmp/iros2-verify-native.sh"
if ($LASTEXITCODE -ne 0) { throw "Failed to upload native verifier." }

$remoteCommand = @(
    "chmod +x /tmp/iros2-verify-native.sh &&",
    "env",
    "IROS2_GITHUB_REPO='$githubRepo'",
    "IROS2_RELEASE_TAG='$releaseTag'",
    "IROS2_PACKAGE_VERSION='$packageVersion'",
    "bash /tmp/iros2-verify-native.sh"
) -join " "

& ssh @sshOptions $target $remoteCommand
if ($LASTEXITCODE -ne 0) { throw "Remote native verification failed." }

Write-Host "SSH/offscreen native verification passed."

