param(
    [Parameter(Mandatory = $true)]
    [string]$HostName,
    [string]$GitRef = "HEAD",
    [string]$SshKey,
    [Parameter(Mandatory = $true)]
    [string]$GpgKey,
    [string]$ResumeRunId,
    [string]$ArtifactsDirectory = "artifacts"
)

$ErrorActionPreference = "Stop"
$repository = "https://github.com/Drone-Age/iros2_0.git"
$commit = (git rev-parse "$GitRef^{commit}").Trim()
if ($LASTEXITCODE -ne 0 -or $commit -notmatch "^[0-9a-f]{40}$") {
    throw "GitRef does not resolve to a commit."
}
git merge-base --is-ancestor $commit origin/main
if ($LASTEXITCODE -ne 0) {
    throw "Release commit must be reachable from origin/main."
}
if ($HostName -notmatch '^[A-Za-z0-9._@:-]+$') {
    throw "HostName contains unsupported characters."
}
if ($GpgKey -and $GpgKey -notmatch '^[A-Za-z0-9]+$') {
    throw "GpgKey contains unsupported characters."
}

$runId = if ($ResumeRunId) { $ResumeRunId } else { "iros2j-" + $commit.Substring(0, 12) }
if ($runId -notmatch '^[A-Za-z0-9._-]+$') {
    throw "Run ID contains unsupported characters."
}
$remoteRoot = ".iros2j-release-runs/$runId"
$sshOptions = @("-o", "BatchMode=yes")
$scpOptions = @("-o", "BatchMode=yes")
if ($SshKey) {
    $resolvedKey = (Resolve-Path -LiteralPath $SshKey).Path
    $sshOptions += @("-i", $resolvedKey)
    $scpOptions += @("-i", $resolvedKey)
}

$gpgEnvironment = "IROS2_GPG_KEY='$GpgKey'"
$start = @"
set -eu
mkdir -p '$remoteRoot'
if [ ! -d '$remoteRoot/repo/.git' ]; then
  git clone '$repository' '$remoteRoot/repo'
fi
git -C '$remoteRoot/repo' fetch origin --tags
git -C '$remoteRoot/repo' checkout --detach '$commit'
if [ -f '$remoteRoot/exit-code' ]; then
  exit 0
fi
if [ -f '$remoteRoot/pid' ] && kill -0 `$(cat '$remoteRoot/pid') 2>/dev/null; then
  exit 0
fi
(
  set +e
  cd '$remoteRoot/repo'
  env IROS2_INSTALL_DEPENDENCIES=1 $gpgEnvironment bash scripts/native/release-rpi.sh
  rc=`$?
  echo "`$rc" > '$remoteRoot/exit-code'
  exit "`$rc"
) > '$remoteRoot/run.log' 2>&1 < /dev/null &
echo `$! > '$remoteRoot/pid'
"@
$start | & ssh @sshOptions $HostName "tr -d '\r' | bash -s"
if ($LASTEXITCODE -ne 0) {
    throw "Failed to start or resume native release run."
}

Write-Host "Native run ID: $runId"
while ($true) {
    $stateScript = @"
if [ -f '$remoteRoot/exit-code' ]; then
  printf 'complete %s\n' "`$(cat '$remoteRoot/exit-code')"
elif [ -f '$remoteRoot/pid' ] && kill -0 `$(cat '$remoteRoot/pid') 2>/dev/null; then
  printf 'running\n'
else
  printf 'stopped\n'
fi
tail -n 5 '$remoteRoot/run.log' 2>/dev/null || true
"@
    $state = $stateScript | & ssh @sshOptions $HostName "tr -d '\r' | bash -s"
    $state | Write-Host
    if ($state[0] -like "complete *") {
        $exitCode = [int]($state[0] -split " ")[1]
        if ($exitCode -ne 0) {
            throw "Native release failed with exit code $exitCode. Resume run $runId after correcting the cause."
        }
        break
    }
    if ($state[0] -eq "stopped") {
        throw "Native run stopped without an exit record. Resume run $runId."
    }
    Start-Sleep -Seconds 20
}

New-Item -ItemType Directory -Force -Path $ArtifactsDirectory | Out-Null
& scp @scpOptions -r "${HostName}:$remoteRoot/repo/artifacts/*" $ArtifactsDirectory
if ($LASTEXITCODE -ne 0) {
    throw "Failed to retrieve native release artifacts."
}
Write-Host "Native release artifacts retrieved into $ArtifactsDirectory."
