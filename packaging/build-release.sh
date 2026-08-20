#!/usr/bin/env bash
#
# Build a Release UTCMenuClock.app and produce modern distribution artifacts:
#   - .pkg installer (pkgbuild + productbuild, replaces legacy PackageMaker)
#   - .zip archive (unsigned universal app bundle)
#
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SCHEME="UTCMenuClock - Release"
CONFIGURATION="Release"
DERIVED_DATA="${ROOT}/packaging/DerivedData"
OUTPUT_DIR="${ROOT}/packaging/output"
RESOURCES_DIR="${ROOT}/packaging"
COMPONENT_ID="net.retina.utcmenuclock.UTCMenuClock.pkg"
APP_NAME="UTCMenuClock.app"

COMPONENT_PKG="${OUTPUT_DIR}/UTCMenuClock-component.pkg"
DIST_WORK="${OUTPUT_DIR}/distribution-resources"

echo "==> Building ${APP_NAME}"

xcodebuild \
    -project "${ROOT}/UTCMenuClock.xcodeproj" \
    -scheme "${SCHEME}" \
    -configuration "${CONFIGURATION}" \
    -derivedDataPath "${DERIVED_DATA}" \
    build

APP_PATH="${DERIVED_DATA}/Build/Products/${CONFIGURATION}/${APP_NAME}"
if [[ ! -d "${APP_PATH}" ]]; then
    echo "error: expected app bundle at ${APP_PATH}" >&2
    exit 1
fi

VERSION="$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "${APP_PATH}/Contents/Info.plist")"
BUILD="$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" "${APP_PATH}/Contents/Info.plist")"
INSTALLER_PKG="${OUTPUT_DIR}/UTCMenuClock_${VERSION}_installer.pkg"
ZIP_PATH="${OUTPUT_DIR}/UTCMenuClock_v${VERSION}_universal.zip"

echo "==> Packaging ${APP_NAME} ${VERSION} (${BUILD})"

mkdir -p "${OUTPUT_DIR}"
rm -f "${COMPONENT_PKG}" "${INSTALLER_PKG}" "${ZIP_PATH}"
rm -rf "${DIST_WORK}"
mkdir -p "${DIST_WORK}"

cp "${RESOURCES_DIR}/welcome.html" "${DIST_WORK}/"
cp "${RESOURCES_DIR}/conclusion.html" "${DIST_WORK}/"

echo "==> Creating component package"
pkgbuild \
    --component "${APP_PATH}" \
    --install-location /Applications \
    --identifier "${COMPONENT_ID}" \
    --version "${VERSION}" \
    "${COMPONENT_PKG}"

echo "==> Creating installer package"
productbuild \
    --distribution "${RESOURCES_DIR}/Distribution.xml" \
    --resources "${DIST_WORK}" \
    --package-path "${OUTPUT_DIR}" \
    --version "${VERSION}" \
    "${INSTALLER_PKG}"

echo "==> Creating zip archive"
ditto -c -k --sequesterRsrc --keepParent "${APP_PATH}" "${ZIP_PATH}"

echo
echo "Build complete:"
echo "  App:       ${APP_PATH}"
echo "  Installer: ${INSTALLER_PKG}"
echo "  Zip:       ${ZIP_PATH}"
