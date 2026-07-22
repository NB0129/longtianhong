#!/usr/bin/env bash
set -euo pipefail

UPSTREAM_URL="https://github.com/godot-sdk-integrations/godot-ios-plugins.git"
UPSTREAM_COMMIT="caafb2c7fbfb5c72a64f163c76449274fa49abaa"
GODOT_TAG="4.6.2-stable"
GODOT_COMMIT="001aa128b1cd80dc4e47e823c360bccf45ed6bad"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
BUILD_ROOT="${MACHIATE_IOS_PLUGIN_BUILD_ROOT:-$(mktemp -d "${TMPDIR:-/tmp}/machiate-gamecenter.XXXXXX")}"
SOURCE_ROOT="${BUILD_ROOT}/godot-ios-plugins"
OUTPUT_ROOT="${PROJECT_ROOT}/ios/plugins/gamecenter"
PATCH_PATH="${SCRIPT_DIR}/0001-modern-score-api.patch"

if [[ "${OUTPUT_ROOT}" != "${PROJECT_ROOT}/ios/plugins/gamecenter" ]]; then
	echo "Refusing unexpected output path: ${OUTPUT_ROOT}" >&2
	exit 1
fi
if [[ -L "${OUTPUT_ROOT}" ]]; then
	echo "Refusing symlinked output path: ${OUTPUT_ROOT}" >&2
	exit 1
fi
for command_name in git scons xcodebuild xcrun shasum; do
	command -v "${command_name}" >/dev/null 2>&1 || {
		echo "Missing required command: ${command_name}" >&2
		exit 1
	}
done
if [[ -e "${SOURCE_ROOT}" ]]; then
	echo "Refusing existing source path: ${SOURCE_ROOT}" >&2
	exit 1
fi

git clone --recursive "${UPSTREAM_URL}" "${SOURCE_ROOT}"
git -C "${SOURCE_ROOT}" checkout --detach "${UPSTREAM_COMMIT}"
git -C "${SOURCE_ROOT}" submodule update --init --recursive
[[ "$(git -C "${SOURCE_ROOT}" rev-parse HEAD)" == "${UPSTREAM_COMMIT}" ]]
git -C "${SOURCE_ROOT}/godot" fetch origin "${GODOT_COMMIT}"
git -C "${SOURCE_ROOT}/godot" checkout --detach "${GODOT_COMMIT}"
[[ "$(git -C "${SOURCE_ROOT}/godot" rev-parse HEAD)" == "${GODOT_COMMIT}" ]]
git -C "${SOURCE_ROOT}" apply --check --whitespace=error-all "${PATCH_PATH}"
git -C "${SOURCE_ROOT}" apply --whitespace=error-all "${PATCH_PATH}"

(
	cd "${SOURCE_ROOT}/godot"
	# Godot 4.6 no longer accepts the old release_debug engine target. Let the
	# official template_debug build finish so every generated header is present.
	scons platform=ios target=template_debug arch=arm64
)

(
	cd "${SOURCE_ROOT}"
	./scripts/generate_xcframework.sh gamecenter release_debug 4.0
	./scripts/generate_xcframework.sh gamecenter release 4.0
	mv ./bin/gamecenter.release_debug.xcframework ./bin/gamecenter.debug.xcframework
)

rm -rf "${OUTPUT_ROOT}"
mkdir -p "${OUTPUT_ROOT}"
cp -R "${SOURCE_ROOT}/bin/gamecenter.debug.xcframework" "${OUTPUT_ROOT}/"
cp -R "${SOURCE_ROOT}/bin/gamecenter.release.xcframework" "${OUTPUT_ROOT}/"
cp "${SOURCE_ROOT}/plugins/gamecenter/gamecenter.gdip" "${OUTPUT_ROOT}/"
cp "${SOURCE_ROOT}/LICENCE" "${OUTPUT_ROOT}/LICENSE.godot-ios-plugins"

{
	echo "upstream=${UPSTREAM_URL}"
	echo "upstream_commit=${UPSTREAM_COMMIT}"
	echo "godot_tag=${GODOT_TAG}"
	echo "godot_commit=${GODOT_COMMIT}"
	echo "patch_sha256=$(shasum -a 256 "${PATCH_PATH}" | awk '{print $1}')"
	echo "xcode_version=$(xcodebuild -version | tr '\n' ' ')"
	echo "built_utc=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
} > "${OUTPUT_ROOT}/PROVENANCE.txt"

(
	cd "${OUTPUT_ROOT}"
	find . -type f ! -name SHA256SUMS.txt -print | LC_ALL=C sort | while IFS= read -r file; do
		shasum -a 256 "${file}"
	done
) > "${OUTPUT_ROOT}/SHA256SUMS.txt"
(
	cd "${OUTPUT_ROOT}"
	shasum -a 256 -c SHA256SUMS.txt
)
echo "Built Game Center plugin at ${OUTPUT_ROOT}"
