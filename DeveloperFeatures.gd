extends RefCounted

# Default-deny switches for intentionally local developer builds.
# Keep both false for normal debug exports and all release exports.
const ENABLE_DEVELOPER_SHORTCUTS := false
const ENABLE_MOCK_PURCHASES := false


static func developer_shortcuts_enabled() -> bool:
	return OS.is_debug_build() and ENABLE_DEVELOPER_SHORTCUTS


static func mock_purchases_enabled() -> bool:
	return OS.is_debug_build() and ENABLE_MOCK_PURCHASES
