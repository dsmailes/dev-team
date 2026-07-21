# Commands

Record commands that have been verified in this project.

## Setup

```sh
# command
```

## Build

```sh
# command
```

## Shared Build And Device Resources

```sh
# Optional user-owned root. Verify the mounted volume before using it.
export DEV_TEAM_BUILD_ROOT=/Volumes/ExternalSSD/builds

# Derive a distinct path for each project and ticket; Xcode example only.
xcodebuild -derivedDataPath "$DEV_TEAM_BUILD_ROOT/<project>/<ticket>/DerivedData" [arguments]

# Hold the host-wide lease only around simulator/device work.
scripts/with-host-resource-lease.sh --timeout 600 simulator -- xcodebuild test [arguments]
```

- Do not silently fall back to default DerivedData when `DEV_TEAM_BUILD_ROOT` is configured but unavailable.
- Inspect an existing lease's `owner` file before manually removing a confirmed inactive lease.

## Test

```sh
# command
```

## Lint And Format

```sh
# command
```

## Run

```sh
# command
```

## Verification Notes

- Date:
- Command:
- Result:
- Notes:
