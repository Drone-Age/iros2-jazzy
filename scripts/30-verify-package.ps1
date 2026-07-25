$ErrorActionPreference = "Stop"

Write-Warning @"
Release verification is native-only. This entry point now delegates to the
SSH/native verifier and does not start Docker.
"@

& (Join-Path $PSScriptRoot "release\verify-via-ssh.ps1")
if ($LASTEXITCODE -ne 0) {
    throw "Native release verification via SSH failed."
}
