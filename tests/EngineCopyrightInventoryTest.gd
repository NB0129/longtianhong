extends SceneTree


func _initialize() -> void:
	var entries: Array[Dictionary] = []
	for component: Dictionary in Engine.get_copyright_info():
		var component_name := str(component.get("name", "")).strip_edges()
		var parts_value: Variant = component.get("parts", [])
		if not parts_value is Array:
			continue
		for part_value: Variant in parts_value:
			if not part_value is Dictionary:
				continue
			var owners: Variant = (part_value as Dictionary).get("copyright", [])
			if not owners is Array:
				continue
			for owner: Variant in owners:
				var line := "Copyright (c) " + str(owner)
				entries.append({"source": "component", "component": component_name, "line": line, "characters": line.length()})
	var license_info := Engine.get_license_info()
	for license_name_variant: Variant in license_info.keys():
		var license_name := str(license_name_variant)
		for line_variant in str(license_info[license_name_variant]).split("\n", true):
			var line := str(line_variant).strip_edges()
			var lowered := line.to_lower()
			if lowered.contains("copyright") or lowered.contains("http://") or lowered.contains("https://"):
				entries.append({"source": "license", "component": license_name, "line": line, "characters": line.length()})
	entries.sort_custom(func(first: Dictionary, second: Dictionary) -> bool: return int(first["characters"]) > int(second["characters"]))
	print("PASS engine_copyright_inventory top=" + JSON.stringify(entries.slice(0, mini(60, entries.size()))))
	quit(0)
