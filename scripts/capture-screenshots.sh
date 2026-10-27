#!/usr/bin/env bash
# Captures the README screenshots from the SystemDesignLab example app on an iPhone simulator.
#
# The script builds and installs the app, opens each lab with `-lab <name>` (which also puts it
# in the state the README describes), and takes a simulator screenshot in light and dark
# appearance with a fixed status bar. The lab server is in-process and seeded, so the screens
# are the same on every run.
#
# Usage: scripts/capture-screenshots.sh [simulator name or UDID]
# Without an argument it uses the first available iPhone simulator. Output: docs/images/
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
device="${1:-}"
if [[ -z "$device" ]]; then
  device="$(xcrun simctl list devices available | grep -m1 -oE 'iPhone [^(]+' | sed 's/ *$//')"
fi
if [[ -z "$device" ]]; then
  echo "No available iPhone simulator found." >&2
  exit 1
fi

bundle_id="io.github.muhittincamdali.SystemDesignLab"
labs=(feed outbox sync estimator)
output_dir="$repo_root/docs/images"
build_dir="$repo_root/.build/screenshots"
mkdir -p "$output_dir" "$build_dir"

destination="platform=iOS Simulator,name=$device"
if [[ "$device" =~ ^[0-9A-F-]{36}$ ]]; then
  destination="platform=iOS Simulator,id=$device"
fi

echo "Building SystemDesignLab for '$device'"
xcodebuild build \
  -project "$repo_root/Examples/SystemDesignLab/SystemDesignLab.xcodeproj" \
  -scheme SystemDesignLab \
  -destination "$destination" \
  -derivedDataPath "$build_dir" \
  -quiet
app="$(find "$build_dir/Build/Products" -maxdepth 2 -name 'SystemDesignLab.app' -path '*iphonesimulator*' | head -1)"

xcrun simctl boot "$device" 2>/dev/null || true
xcrun simctl bootstatus "$device" -b >/dev/null
xcrun simctl status_bar "$device" override --time 9:41 --batteryState charged --batteryLevel 100 \
  --cellularBars 4 --wifiBars 3 --operatorName ""
xcrun simctl install "$device" "$app"

for appearance in light dark; do
  xcrun simctl ui "$device" appearance "$appearance"
  for lab in "${labs[@]}"; do
    xcrun simctl launch --terminate-running-process "$device" "$bundle_id" -lab "$lab" \
      -AppleLanguages "(en)" -AppleLocale en_US >/dev/null
    sleep 5 # navigation push, first page (250 ms simulated latency) and seeding
    file="$output_dir/lab-$lab-$appearance.png"
    xcrun simctl io "$device" screenshot --type=png "$file" >/dev/null 2>&1
    # Half the screen width keeps the README light.
    width="$(sips -g pixelWidth "$file" | awk '/pixelWidth/ {print $2}')"
    sips --resampleWidth "$((width / 2))" "$file" >/dev/null
    echo "$file"
  done
done

xcrun simctl status_bar "$device" clear
xcrun simctl terminate "$device" "$bundle_id" 2>/dev/null || true
