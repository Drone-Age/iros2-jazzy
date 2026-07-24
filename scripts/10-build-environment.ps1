$ErrorActionPreference = "Stop"

docker buildx build `
    --platform linux/arm64 `
    --target environment `
    --tag iros2-jazzy:build-environment `
    --load `
    .

if ($LASTEXITCODE -ne 0) {
    throw "IROS2 build environment failed."
}
