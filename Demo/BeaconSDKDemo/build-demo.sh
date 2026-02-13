#!/bin/bash
# Build script that temporarily hides Package.swift to avoid SPM/CocoaPods conflict

set -e

SDK_ROOT="../../"
PACKAGE_FILE="$SDK_ROOT/Package.swift"

# Hide Package.swift
if [ -f "$PACKAGE_FILE" ]; then
    mv "$PACKAGE_FILE" "${PACKAGE_FILE}.hidden"
    echo "Temporarily hidden Package.swift"
fi

# Clean derived data
rm -rf ~/Library/Developer/Xcode/DerivedData/BeaconSDKDemo-*

# Build
xcodebuild -workspace BeaconSDKDemo.xcworkspace \
    -scheme BeaconSDKDemo \
    -sdk iphonesimulator \
    -destination 'platform=iOS Simulator,id=04F813A3-D921-4458-AB11-D5D0ABFDBF5E' \
    build \
    CODE_SIGNING_ALLOWED=NO

BUILD_RESULT=$?

# Restore Package.swift
if [ -f "${PACKAGE_FILE}.hidden" ]; then
    mv "${PACKAGE_FILE}.hidden" "$PACKAGE_FILE"
    echo "Restored Package.swift"
fi

exit $BUILD_RESULT
